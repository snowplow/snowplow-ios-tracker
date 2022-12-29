//
//  SPTrackerEvent.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

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
}
