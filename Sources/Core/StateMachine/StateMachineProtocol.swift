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

protocol StateMachineProtocol {
    var identifier: String { get }
    var subscribedEventSchemasForTransitions: [String] { get }
    var subscribedEventSchemasForEntitiesGeneration: [String] { get }
    var subscribedEventSchemasForPayloadUpdating: [String] { get }
    var subscribedEventSchemasForAfterTrackCallback: [String] { get }
    var subscribedEventSchemasForFiltering: [String] { get }
    
    /// Only available for self-describing events (inheriting from SelfDescribingAbstract)
    func transition(from event: Event, state: State?) -> State?
    
    /// Available for both self-describing and primitive events (when using `*` as the schema)
    func filter(event: InspectableEvent, state: State?) -> Bool?
    
    /// Available for both self-describing and primitive events (when using `*` as the schema)
    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]?
    
    /// Only available for self-describing events (inheriting from SelfDescribingAbstract)
    func payloadValues(from event: InspectableEvent, state: State?) -> [String : Any]?
    
    /// Available for both self-describing and primitive events (when using `*` as the schema)
    func afterTrack(event: InspectableEvent)
}
