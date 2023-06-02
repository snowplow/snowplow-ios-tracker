// Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.

import Foundation

class LifecycleStateMachine: StateMachineProtocol {
    static var identifier: String { return "Lifecycle" }
    var identifier: String { return LifecycleStateMachine.identifier }

    var subscribedEventSchemasForTransitions: [String] {
        return [kSPBackgroundSchema, kSPForegroundSchema]
    }

    func transition(from event: Event, state currentState: State?) -> State? {
        if let e = event as? Foreground {
            return LifecycleState(asForegroundWithIndex: e.index)
        }
        if let e = event as? Background {
            return LifecycleState(asBackgroundWithIndex: e.index)
        }
        return nil
    }

    var subscribedEventSchemasForEntitiesGeneration: [String] {
        return ["*"]
    }

    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]? {
        if state == nil {
            let entity = LifecycleEntity(isVisible: true)
            entity.index = 0
            return [entity]
        }
        if let s = state as? LifecycleState {
            let entity = LifecycleEntity(isVisible: s.isForeground)
            entity.index = NSNumber(value: s.index)
            return [entity]
        }
        return nil
    }

    var subscribedEventSchemasForPayloadUpdating: [String] {
        return []
    }

    func payloadValues(from event: InspectableEvent, state: State?) -> [String : Any]? {
        return nil
    }

    var subscribedEventSchemasForAfterTrackCallback: [String] {
        return []
    }

    func afterTrack(event: InspectableEvent) {
    }
    
    var subscribedEventSchemasForFiltering: [String] {
        return []
    }
    
    func filter(event: InspectableEvent, state: State?) -> Bool? {
        return nil
    }
}
