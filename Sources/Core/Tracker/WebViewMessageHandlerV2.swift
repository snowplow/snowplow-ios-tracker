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
            
//            guard let atomicData = atomicProperties.data(using: .utf8) else { return }
//            guard let atomicJson = try? JSONSerialization.jsonObject(with: atomicData) as? [String : Any] else {
//                logError(message: "WebView: Received event payload is not serializable to JSON, skipping.")
//                return
//            }
            guard let atomicJson = parseAtomicPropertiesFromMessage(atomicProperties) else { return }
            
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
                let data = entitiesData?.data(using: .utf8) ?? Data()
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
    
    func parseAtomicPropertiesFromMessage(_ messageString: String?) -> [String : Any]? {
        let atomicData = messageString?.data(using: .utf8)
        
        var atomicJson: [String : Any]? = [:]
        if let data = atomicData {
            atomicJson = try? JSONSerialization.jsonObject(with: data) as? [String : Any]
        }
        if (atomicData == nil) || (atomicJson == nil) {
            logError(message: "WebView: Received event payload is not serializable to JSON, skipping.")
            return nil
        }
        return atomicJson
    }
}


#endif
