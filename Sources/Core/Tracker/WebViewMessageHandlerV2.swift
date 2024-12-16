//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

#if os(iOS) || os(macOS) || os(visionOS)
import WebKit

/// Handler for messages from the JavaScript library embedded in WebViews.
/// This V2 interface works with the WebView tracker v0.3.0+.
///
/// The handler parses messages from the JavaScript library calls and forwards the tracked events to be tracked by the mobile tracker.
class WebViewMessageHandlerV2: NSObject, WKScriptMessageHandler {
    /// Callback called when the message handler receives a new message.
    ///
    /// The message dictionary should contain three properties:
    /// 1. "event" with a dictionary containing the event information (structure depends on the tracked event)
    /// 2. "context" (optional) with a list of self-describing JSONs
    /// 3. "trackers" (optional) with a list of tracker namespaces to track the event with
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        receivedMessage(message)
    }
    
    func receivedMessage(_ message: WKScriptMessage) {
        if let body = message.body as? [AnyHashable : Any],
           let atomicProperties = body["atomicProperties"] as? String {
            
            guard let atomicData = atomicProperties.data(using: .utf8) else { return }
            guard let atomicJson = try? JSONSerialization.jsonObject(with: atomicData) as? [String : Any] else {
                logError(message: "WebView: Received event payload is not serializable to JSON, skipping.")
                return
            }
            
            let selfDescribingEventData = body["selfDescribingEventData"] as? String? ?? nil
            var selfDescribingDataJson: [AnyHashable : Any] = [:]
            
            if (selfDescribingEventData != nil) {
                let data = selfDescribingEventData?.data(using: .utf8) ?? Data()
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable : Any] else {
                    logError(message: "WebView: Received event payload is not serializable to JSON, skipping.")
                    return
                }
                selfDescribingDataJson = json
            }
            
            let entitiesData = body["entities"] as? String? ?? nil
            var entitiesJson: [[AnyHashable : Any]] = []
                        
            if (entitiesData != nil) {
                let data = selfDescribingEventData?.data(using: .utf8) ?? Data()
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [[AnyHashable : Any]] else {
                    logError(message: "WebView: Received event payload is not serializable to JSON, skipping.")
                    return
                }
                entitiesJson = json
            }
            
            let trackers = body["trackers"] as? [String] ?? []
            
            let event = WebViewReader(
                selfDescribingEventData: createSelfDescribingJson(selfDescribingDataJson),
                eventName: atomicJson["eventName"] as? String? ?? nil,
                trackerVersion: atomicJson["trackerVersion"] as? String? ?? nil,
                useragent: atomicJson["useragent"] as? String? ?? nil,
                pageUrl: atomicJson["pageUrl"] as? String? ?? nil,
                pageTitle: atomicJson["pageTitle"] as? String? ?? nil,
                referrer: atomicJson["referrer"] as? String? ?? nil,
                category: atomicJson["category"] as? String? ?? nil,
                action: atomicJson["action"] as? String? ?? nil,
                label: atomicJson["label"] as? String? ?? nil,
                property: atomicJson["property"] as? String? ?? nil,
                value: atomicJson["value"] as? Double,
                pingXOffsetMin: atomicJson["pingXOffsetMin"] as? Int ?? nil,
                pingXOffsetMax: atomicJson["pingXOffsetMax"] as? Int ?? nil,
                pingYOffsetMin: atomicJson["pingYOffsetMin"] as? Int ?? nil,
                pingYOffsetMax: atomicJson["pingYOffsetMax"] as? Int ?? nil
            )
            
            track(event, withEntities: entitiesJson, andTrackers: trackers)
        }
    }
    
    func track(_ event: Event, withEntities entities: [[AnyHashable : Any]], andTrackers trackers: [String]) {
        event.entities = parseEntities(entities)
        
        if trackers.count > 0 {
            for namespace in trackers {
                if let tracker = Snowplow.tracker(namespace: namespace) {
                    _ = tracker.track(event)
                }
            }
        } else {
            _ = Snowplow.defaultTracker()?.track(event)
        }
    }
    
    func createSelfDescribingJson(_ map: [AnyHashable : Any]) -> SelfDescribingJson? {
        if let schema = map["schema"] as? String,
           let payload = map["data"] as? [String : Any] {
            return SelfDescribingJson(schema: schema, andDictionary: payload)
        }
        return nil
    }
    
    func parseEntities(_ entities: [[AnyHashable : Any]]) -> [SelfDescribingJson] {
        var contextEntities: [SelfDescribingJson] = []
        
        for entityJson in entities {
            if let entity = createSelfDescribingJson(entityJson) {
                contextEntities.append(entity)
            }
        }
        return contextEntities
    }
    
    func parseSelfDescribingEventData(_ eventData: [AnyHashable : Any]) -> SelfDescribingJson? {
        //         TODO this function not used?
        return createSelfDescribingJson(eventData)
    }
    
    
    //
    //
    //
    //    func trackSelfDescribing(_ event: [AnyHashable : Any], withContext context: [[AnyHashable : Any]], andTrackers trackers: [String]) {
    //        if let schema = event["schema"] as? String,
    //           let payload = event["data"] as? [String : Any] {
    //            let selfDescribing = SelfDescribing(schema: schema, payload: payload)
    //            track(selfDescribing, withEntities: context, andTrackers: trackers)
    //        }
    //    }
    //
    //    func trackStructEvent(_ event: [AnyHashable : Any], withContext context: [[AnyHashable : Any]], andTrackers trackers: [String]) {
    //        let category = event["category"] as? String
    //        let action = event["action"] as? String
    //        let label = event["label"] as? String
    //        let property = event["property"] as? String
    //        let value = event["value"] as? NSNumber
    //
    //        if let category = category, let action = action {
    //            let structured = Structured(category: category, action: action)
    //            if let label = label {
    //                structured.label = label
    //            }
    //            if let property = property {
    //                structured.property = property
    //            }
    //            if let value = value {
    //                structured.value = value
    //            }
    //            track(structured, withEntities: context, andTrackers: trackers)
    //        }
    //    }
    //
    //    func trackPageView(_ event: [AnyHashable : Any], withContext context: [[AnyHashable : Any]], andTrackers trackers: [String]) {
    //        let url = event["url"] as? String
    //        let title = event["title"] as? String
    //        let referrer = event["referrer"] as? String
    //
    //        if let url = url {
    //            let pageView = PageView(pageUrl: url)
    //            if let title = title {
    //                pageView.pageTitle = title
    //            }
    //            if let referrer = referrer {
    //                pageView.referrer = referrer
    //            }
    //            track(pageView, withEntities: context, andTrackers: trackers)
    //        }
    //    }
    //
    //    func trackScreenView(_ event: [AnyHashable : Any], withContext context: [[AnyHashable : Any]], andTrackers trackers: [String]) {
    //        let name = event["name"] as? String
    //        let screenId = event["id"] as? String
    //        let type = event["type"] as? String
    //        let previousName = event["previousName"] as? String
    //        let previousId = event["previousId"] as? String
    //        let previousType = event["previousType"] as? String
    //        let transitionType = event["transitionType"] as? String
    //
    //        if let name = name, let screenId = screenId {
    //            let screenUuid = UUID(uuidString: screenId)
    //            let screenView = ScreenView(name: name, screenId: screenUuid)
    //            if let type = type {
    //                screenView.type = type
    //            }
    //            if let previousName = previousName {
    //                screenView.previousName = previousName
    //            }
    //            if let previousId = previousId {
    //                screenView.previousId = previousId
    //            }
    //            if let previousType = previousType {
    //                screenView.previousType = previousType
    //            }
    //            if let transitionType = transitionType {
    //                screenView.transitionType = transitionType
    //            }
    //            track(screenView, withEntities: context, andTrackers: trackers)
    //        }
    //    }
    //}
}


#endif
