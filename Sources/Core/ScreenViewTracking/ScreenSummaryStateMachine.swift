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

class ScreenSummaryStateMachine: StateMachineProtocol {
    static var identifier: String { return "ScreenSummaryContext" }
    var identifier: String { return ScreenSummaryStateMachine.identifier }
    
    var subscribedEventSchemasForEventsBefore: [String] {
        return [kSPScreenViewSchema]
    }

    var subscribedEventSchemasForTransitions: [String] {
        return [kSPScreenViewSchema, kSPScreenEndSchema, kSPForegroundSchema, kSPBackgroundSchema, kSPListItemViewSchema]
    }

    var subscribedEventSchemasForEntitiesGeneration: [String] {
        return [kSPScreenEndSchema, kSPForegroundSchema, kSPBackgroundSchema]
    }

    var subscribedEventSchemasForPayloadUpdating: [String] {
        return []
    }

    var subscribedEventSchemasForAfterTrackCallback: [String] {
        return []
    }
    
    var subscribedEventSchemasForFiltering: [String] {
        return [kSPListItemViewSchema, kSPScreenEndSchema]
    }
    
    func eventsBefore(event: Event) -> [Event]? {
        return [ScreenEnd()]
    }

    func transition(from event: Event, state currentState: State?) -> State? {
        if event is ScreenView {
            return ScreenSummaryState()
        }
        else if let state = currentState as? ScreenSummaryState {
            switch event {
            case is Foreground:
                state.updateTransitionToForeground()
            case is Background:
                state.updateTransitionToBackground()
            case is ScreenEnd:
                state.updateForScreenEnd()
            case let itemView as ListItemView:
                state.updateWithListItemView(itemView)
            default:
                break
            }
        }
        return currentState
    }

    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]? {
        guard let state = state as? ScreenSummaryState else { return nil }
        
        return [
            SelfDescribingJson(schema: kSPScreenSummarySchema, andData: state.data)
        ]
    }

    func payloadValues(from event: InspectableEvent, state: State?) -> [String : Any]? {
        return nil
    }

    func filter(event: InspectableEvent, state: State?) -> Bool? {
        if event.schema == kSPScreenEndSchema {
            return state != nil
        }
        // do not track list item view events
        return false
    }

    func afterTrack(event: InspectableEvent) {
    }
}
