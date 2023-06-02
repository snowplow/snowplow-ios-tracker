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

class ScreenStateMachine: StateMachineProtocol {
    static var identifier: String { return "ScreenContext" }
    var identifier: String { return ScreenStateMachine.identifier }

    var subscribedEventSchemasForTransitions: [String] {
        return [kSPScreenViewSchema]
    }

    var subscribedEventSchemasForEntitiesGeneration: [String] {
        return ["*"]
    }

    var subscribedEventSchemasForPayloadUpdating: [String] {
        return [kSPScreenViewSchema]
    }

    var subscribedEventSchemasForAfterTrackCallback: [String] {
        return []
    }
    
    var subscribedEventSchemasForFiltering: [String] {
        return []
    }

    func transition(from event: Event, state currentState: State?) -> State? {
        if let screenView = event as? ScreenView {
            let newState: ScreenState = screenState(from: screenView)
            newState.previousState = currentState as? ScreenState
            return newState
        }
        return nil
    }

    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]? {
        if let state = state as? ScreenState,
           let entity = screenContext(from: state) {
            return [entity]
        }
        return nil
    }

    func payloadValues(from event: InspectableEvent, state: State?) -> [String : Any]? {
        if let state = state as? ScreenState {
            let previousState = state.previousState
            var addedValues: [String : Any] = [:]
            addedValues[kSPSvPreviousName] = previousState?.name
            addedValues[kSPSvPreviousType] = previousState?.type
            addedValues[kSPSvPreviousScreenId] = previousState?.screenId
            return addedValues
        }
        return nil
    }

    func filter(event: InspectableEvent, state: State?) -> Bool? {
        return nil
    }

    // Private methods

    func screenState(from screenView: ScreenView) -> ScreenState {
        return ScreenState(
            name: screenView.name,
            type: screenView.type,
            screenId: screenView.screenId.uuidString,
            transitionType: screenView.transitionType,
            topViewControllerClassName: screenView.topViewControllerClassName,
            viewControllerClassName: screenView.viewControllerClassName)
    }

    func screenContext(from screenState: ScreenState) -> SelfDescribingJson? {
        if let contextPayload = screenState.payload {
            return SelfDescribingJson(schema: kSPScreenContextSchema, andPayload: contextPayload)
        }
        return nil
    }
    
    func afterTrack(event: InspectableEvent) {
    }
}
