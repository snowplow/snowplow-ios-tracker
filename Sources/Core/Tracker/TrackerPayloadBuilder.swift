//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.

import Foundation

class TrackerPayloadBuilder {
    
    func payload(event: TrackerEvent, tracker: TrackerData, stateManager: StateManager) -> Payload? {
        let payload = Payload()
        payload.allowDiagnostic = !event.isService

        // Payload properties
        setApplicationInstallEventTimestamp(event)
        addBasicProperties(to: payload, event: event, tracker: tracker)
        addStateMachinePayloadValues(event: event, stateManager: stateManager)
        
        // Context entities
        addBasicContexts(event: event, tracker: tracker)
        addStateMachineEntities(event: event, stateManager: stateManager)
        
        event.wrapProperties(to: payload, base64Encoded: tracker.base64Encoded)
        event.wrapContexts(to: payload, base64Encoded: tracker.base64Encoded)
        
        // Decide whether to track the event or not
        if !stateManager.filter(event: event) {
            return nil
        }

        // Workaround for campaign attribution
        if !event.isPrimitive {
            // TODO: To remove when Atomic table refactoring is finished
            workaround(forCampaignAttributionEnrichment: payload, event: event)
        }
        return payload
    }

    private func trackerPayloadData(tracker: TrackerData) -> [String : String] {
        var trackerVersion = kSPVersion
        if tracker.trackerVersionSuffix.count != 0 {
            var allowedCharSet = CharacterSet.alphanumerics
            allowedCharSet.formUnion(CharacterSet(charactersIn: ".-"))
            let suffix = tracker.trackerVersionSuffix.components(separatedBy: allowedCharSet.inverted).joined(separator: "")
            if suffix.count != 0 {
                trackerVersion = "\(trackerVersion) \(suffix)"
            }
        }
        return [
            kSPTrackerVersion: trackerVersion,
            kSPNamespace: tracker.trackerNamespace,
            kSPAppId: tracker.appId
        ]
    }
    
    private func addBasicProperties(to payload: Payload, event: TrackerEvent, tracker: TrackerData) {
        // Event ID
        payload.addValueToPayload(event.eventId.uuidString, forKey: kSPEid)
        // Timestamps
        payload.addValueToPayload(String(format: "%lld", event.timestamp), forKey: kSPTimestamp)
        if let trueTimestamp = event.trueTimestamp {
            let ttInMilliSeconds = Int64(trueTimestamp.timeIntervalSince1970 * 1000)
            payload.addValueToPayload(String(format: "%lld", ttInMilliSeconds), forKey: kSPTrueTimestamp)
        }
        // Tracker info (version, namespace, app ID)
        payload.addDictionaryToPayload(trackerPayloadData(tracker: tracker))
        // Subject
        if let subject = tracker.subject {
            let subjectDict = subject.standardDict(userAnonymisation: tracker.userAnonymisation)
            payload.addDictionaryToPayload(subjectDict)
        }
        // Platform
        payload.addValueToPayload(devicePlatformToString(tracker.devicePlatform), forKey: kSPPlatform)
        // Event name
        if event.isPrimitive {
            payload.addValueToPayload(event.eventName, forKey: kSPEvent)
        } else {
            payload.addValueToPayload(kSPEventUnstructured, forKey: kSPEvent)
        }
    }
    
    private func setApplicationInstallEventTimestamp(_ event: TrackerEvent) {
        // Application_install event needs the timestamp to the real installation event.
        if (event.schema == kSPApplicationInstallSchema) {
            if let trueTimestamp = event.trueTimestamp {
                event.timestamp = Int64(trueTimestamp.timeIntervalSince1970 * 1000)
                event.trueTimestamp = nil
            }
        }
    }

    /*
     This is needed because the campaign-attribution-enrichment (in the pipeline) is able to parse
     the `url` and `referrer` only if they are part of a PageView event.
     The PageView event is an atomic event but the DeepLinkReceived and ScreenView are SelfDescribing events.
     For this reason we copy these two fields in the atomic fields in order to let the enrichment
     to process correctly the fields even if the event is not a PageView and it's a SelfDescribing event.
     This is a hack that should be removed once the atomic event table is dismissed and all the events
     will be SelfDescribing.
     */
    private func workaround(forCampaignAttributionEnrichment payload: Payload, event: TrackerEvent) {
        var url: String?
        var referrer: String?

        if event.schema == DeepLinkReceived.schema {
            url = event.payload[DeepLinkReceived.paramUrl] as? String
            referrer = event.payload[DeepLinkReceived.paramReferrer] as? String
        } else if event.schema == kSPScreenViewSchema {
            for entity in event.entities {
                if entity.schema == DeepLinkEntity.schema {
                    let data = entity.data
                    url = data[DeepLinkEntity.paramUrl] as? String
                    referrer = data[DeepLinkEntity.paramReferrer] as? String
                    break
                }
            }
        }

        if let url = url {
            payload.addValueToPayload(Utilities.truncateUrlScheme(url), forKey: kSPPageUrl)
        }
        if let referrer = referrer {
            payload.addValueToPayload(Utilities.truncateUrlScheme(referrer), forKey: kSPPageRefr)
        }
    }

    private func addBasicContexts(event: TrackerEvent, tracker: TrackerData) {
#if os(iOS)
        let platformContextSchema = kSPMobileContextSchema
#else
        let platformContextSchema = kSPDesktopContextSchema
#endif

        if let subject = tracker.subject {
            if let platformDict = subject.platformDict(
                userAnonymisation: tracker.userAnonymisation,
                advertisingIdentifierRetriever: tracker.advertisingIdentifierRetriever)?.dictionary {
                event.addContextEntity(SelfDescribingJson(schema: platformContextSchema, andDictionary: platformDict))
            }
            if let geoLocationDict = subject.geoLocationDict {
                event.addContextEntity(SelfDescribingJson(schema: kSPGeoContextSchema, andDictionary: geoLocationDict))
            }
        }

        if tracker.applicationContext {
            if let contextJson = Utilities.applicationContext {
                event.addContextEntity(contextJson)
            }
        }

        if event.isService {
            return
        }

        // Add session
        if let session = tracker.session {
            if let sessionDict = session.getDictWithEventId(event.eventId.uuidString,
                                                            eventTimestamp: event.timestamp,
                                                            userAnonymisation: tracker.userAnonymisation) {
                event.addContextEntity(SelfDescribingJson(schema: kSPSessionContextSchema, andDictionary: sessionDict))
            } else {
                logDiagnostic(message: String(format: "Unable to get session context for eventId: %@", event.eventId.uuidString))
            }
        }

        // Add GDPR context
        if let gdprContext = tracker.gdprContext?.context {
            event.addContextEntity(gdprContext)
        }
    }

    private func addStateMachinePayloadValues(event: TrackerEvent, stateManager: StateManager) {
        _ = stateManager.addPayloadValues(to: event)
    }

    private func addStateMachineEntities(event: TrackerEvent, stateManager: StateManager) {
        let stateManagerEntities = stateManager.entities(forProcessedEvent: event)
        for entity in stateManagerEntities {
            event.addContextEntity(entity)
        }
    }
    
}
