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

class ImmersiveSpaceStateMachine: StateMachineProtocol {
    
    static var identifier: String { return "ImmersiveSpace" }
    var identifier: String { return ImmersiveSpaceStateMachine.identifier }
    
    var subscribedEventSchemasForEventsBefore: [String] {
        return []
    }

    var subscribedEventSchemasForTransitions: [String] {
        return [swiftuiOpenImmersiveSpaceSchema, swiftuiDismissImmersiveSpaceSchema]
    }

    var subscribedEventSchemasForEntitiesGeneration: [String] {
        return ["*"]
    }

    var subscribedEventSchemasForPayloadUpdating: [String] {
        return []
    }

    var subscribedEventSchemasForAfterTrackCallback: [String] {
        return []
    }

    var subscribedEventSchemasForFiltering: [String] {
        return []
    }
    
    func eventsBefore(event: Event) -> [Event]? {
        return nil
    }
    
    func transition(from event: Event, state: State?) -> State? {
        if let e = event as? OpenImmersiveSpaceEvent {
            let newState = ImmersiveSpaceState(
                id: e.id,
                uuid: e.uuid,
                immersionStyle: e.immersionStyle,
                upperLimbVisibility: e.upperLimbVisibility
            )
            
            if state == nil { return newState }
            
            if let s = state as? ImmersiveSpaceState {
                if s.dismissEventTracked == true {
                    return newState
                }
                // Returns the existing state if sequential Open events are tracked by mistake
                let currentState = ImmersiveSpaceState(
                    id: s.id,
                    uuid: s.uuid,
                    immersionStyle: s.immersionStyle,
                    upperLimbVisibility: s.upperLimbVisibility
                )
                return currentState
            }
        } else {
            if state == nil { return nil }
            
            if let s = state as? ImmersiveSpaceState {
                if s.dismissEventTracked {
                    return nil
                }
                // state persists for the first Dismiss event after an Open
                let currentState = ImmersiveSpaceState(
                    id: s.id,
                    uuid: s.uuid,
                    immersionStyle: s.immersionStyle,
                    upperLimbVisibility: s.upperLimbVisibility
                )
                currentState.dismissEventTracked = true
                return currentState
            }
        }
        return nil
    }
    
    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]? {
        if state == nil {
            return nil
        }
        
        // the open event already has the entity
        if event.schema == swiftuiOpenImmersiveSpaceSchema {
            return nil
        }

        if let s = state as? ImmersiveSpaceState {
            if s.dismissEventTracked == true && event.schema != swiftuiDismissImmersiveSpaceSchema {
                return nil
            }
            let entity = ImmersiveSpaceEntity(
                id: s.id,
                uuid: s.uuid,
                immersionStyle: s.immersionStyle,
                upperLimbVisibility: s.upperLimbVisibility
            )
            return [entity]
        }
        return nil
    }
    
    func payloadValues(from event: InspectableEvent, state: State?) -> [String : Any]? {
        return nil
    }
    
    func afterTrack(event: InspectableEvent) {
    }
    
    func filter(event: InspectableEvent, state: State?) -> Bool? {
        return nil
    }
}
