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

class TrackerEvent : InspectableEvent, StateMachineEvent {
    /// Self-describing event data or primitive event payload
    private(set) var payload: [String: Any]
    
    /// Self-describing event schema
    private(set) var schema: String?
    
    /// Primitive event name
    private(set) var eventName: String?
    
    /// Event ID
    private(set) var eventId: UUID
    
    /// List of custom as well as automatically assigned context entities
    private(set) var entities: [SelfDescribingJson]
    
    private(set) var state: TrackerStateSnapshot
    
    var timestamp: Int64
    
    var trueTimestamp: Date?
    
    private(set) var isPrimitive: Bool
    
    private(set) var isService: Bool
    
    init(event: Event, state: TrackerStateSnapshot? = nil) {
        eventId = UUID()
        timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        trueTimestamp = event.trueTimestamp
        entities = event.entities
        payload = event.payload
        self.state = state ?? TrackerState()
        
        isService = (event is TrackerError)
        if let abstractEvent = event as? PrimitiveAbstract {
            eventName = abstractEvent.eventName
            isPrimitive = true
        } else {
            schema = (event as! SelfDescribingAbstract).schema
            isPrimitive = false
        }
    }
    
    func addPayloadValues(_ payload: [String : Any]) -> Bool {
        var result = true
        for (key, obj) in payload {
            if self.payload[key] == nil {
                self.payload[key] = obj
            } else {
                result = false
            }
        }
        return result
    }
    
    func addContextEntity(_ entity: SelfDescribingJson) {
        entities.append(entity)
    }
    
    func wrapContexts(to payload: Payload, base64Encoded: Bool) {
        if entities.count == 0 {
            return
        }
        
        let dict = SelfDescribingJson.dictionary(
            schema: kSPContextSchema,
            data: entities.map { $0.dictionary })
        
        payload.addDictionaryToPayload(
            dict,
            base64Encoded: base64Encoded,
            typeWhenEncoded: kSPContextEncoded,
            typeWhenNotEncoded: kSPContext)
    }
    
    func wrapProperties(to payload: Payload, base64Encoded: Bool) {
        if isPrimitive {
            payload.addDictionaryToPayload(self.payload)
        } else {
            wrapSelfDescribing(to: payload, base64Encoded: base64Encoded)
        }
    }
    
    private func wrapSelfDescribing(to payload: Payload, base64Encoded: Bool) {
        guard let schema = schema else { return }
        
        let data = SelfDescribingJson(schema: schema, andData: self.payload)
        let unstructuredEventPayload = SelfDescribingJson.dictionary(
            schema: kSPUnstructSchema,
            data: data.dictionary)
        payload.addDictionaryToPayload(
            unstructuredEventPayload,
            base64Encoded: base64Encoded,
            typeWhenEncoded: kSPUnstructuredEncoded,
            typeWhenNotEncoded: kSPUnstructured)
    }
}
