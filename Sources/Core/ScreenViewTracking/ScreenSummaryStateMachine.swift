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

class ScreenSummaryStateMachine: StateMachineProtocol {
    static var identifier: String { return "ScreenSummaryContext" }
    var identifier: String { return ScreenSummaryStateMachine.identifier }
    
    var subscribedEventSchemasForEventsBefore: [String] {
        return [kSPScreenViewSchema]
    }

    var subscribedEventSchemasForTransitions: [String] {
        return [kSPScreenViewSchema, kSPScreenEndSchema, kSPEndScreenViewSchema, kSPForegroundSchema, kSPBackgroundSchema, kSPListItemViewSchema, kSPScrollChangedSchema]
    }

    var subscribedEventSchemasForEntitiesGeneration: [String] {
        return [kSPScreenEndSchema, kSPEndScreenViewSchema, kSPForegroundSchema, kSPBackgroundSchema]
    }

    var subscribedEventSchemasForPayloadUpdating: [String] {
        return []
    }

    var subscribedEventSchemasForAfterTrackCallback: [String] {
        return []
    }
    
    var subscribedEventSchemasForFiltering: [String] {
        return [kSPListItemViewSchema, kSPScrollChangedSchema, kSPScreenEndSchema, kSPEndScreenViewSchema]
    }

    func eventsBefore(event: Event) -> [Event]? {
        return [ScreenEnd()]
    }

    func transition(from event: Event, state currentState: State?) -> State? {
        if let screenView = event as? ScreenView {
            let state = ScreenSummaryState()
            state.screenId = screenView.screenId.uuidString
            return state
        }
        else if let state = currentState as? ScreenSummaryState {
            // Once a screen has been manually ended, its engagement metrics are finalized —
            // ignore any further updates (Foreground/Background transitions, the automatic
            // pre-ScreenView ScreenEnd, list/scroll metrics) until a real ScreenView replaces
            // this state entirely. Without this guard, those events would keep mutating
            // foreground_sec/background_sec on the ended screen, reintroducing the bug this
            // feature exists to fix.
            if state.isEnded {
                return currentState
            }
            switch event {
            case is Foreground:
                state.updateTransitionToForeground()
            case is Background:
                state.updateTransitionToBackground()
            case is ScreenEnd:
                state.updateForScreenEnd()
            case let endScreenView as EndScreenView:
                // Ignore a manual end that doesn't match the currently active screen — a
                // delayed/stale call shouldn't close out the engagement duration of a screen
                // the user has since natively navigated to.
                if endScreenView.screenId == nil || endScreenView.screenId?.uuidString == state.screenId {
                    state.updateForScreenEnd()
                    state.markEnded()
                }
            case let itemView as ListItemView:
                state.updateWithListItemView(itemView)
            case let scrollChanged as ScrollChanged:
                state.updateWithScrollChanged(scrollChanged)
            default:
                break
            }
        }
        return currentState
    }

    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]? {
        guard let state = state as? ScreenSummaryState else { return nil }
        // Once a screen has been manually ended, stop attaching its (now-frozen) summary to
        // later events (the EndScreenView event itself still gets it, as the finalized summary
        // for that screen).
        if state.isEnded && event.schema != kSPEndScreenViewSchema {
            return nil
        }

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
        if event.schema == kSPEndScreenViewSchema {
            guard let state = state as? ScreenSummaryState, let screenId = state.screenId else { return false }
            if let suppliedScreenId = event.payload[kSPSvScreenId] as? String, suppliedScreenId != screenId {
                return false
            }
            return true
        }
        // do not track list item view or scroll changed events
        return false
    }

    func afterTrack(event: InspectableEvent) {
    }
}
