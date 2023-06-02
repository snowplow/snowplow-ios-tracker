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

class DeepLinkStateMachine: StateMachineProtocol {
    /*
     States: Init, DeepLink, ReadyForOutput
     Events: DL (DeepLinkReceived), SV (ScreenView)
     Transitions:
      - Init (DL) DeepLink
      - DeepLink (SV) ReadyForOutput
      - ReadyForOutput (DL) DeepLink
      - ReadyForOutput (SV) Init
     Entity Generation:
      - ReadyForOutput
     */
    
    static var identifier: String { return "DeepLinkContext" }
    var identifier: String { return DeepLinkStateMachine.identifier }

    var subscribedEventSchemasForTransitions: [String] {
        return [DeepLinkReceived.schema, kSPScreenViewSchema]
    }

    var subscribedEventSchemasForEntitiesGeneration: [String] {
        return [kSPScreenViewSchema]
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

    func transition(from event: Event, state: State?) -> State? {
        if let dlEvent = event as? DeepLinkReceived {
            return DeepLinkState(url: dlEvent.url, referrer: dlEvent.referrer)
        } else {
            if let dlState = state as? DeepLinkState {
                if dlState.readyForOutput {
                    return nil
                }
                let currentState = DeepLinkState(url: dlState.url, referrer: dlState.referrer)
                currentState.readyForOutput = true
                return currentState
            }
        }
        return nil
    }

    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]? {
        if let deepLinkState = state as? DeepLinkState {
            if !(deepLinkState.readyForOutput) {
                return nil
            }
            let entity = DeepLinkEntity(url: deepLinkState.url)
            entity.referrer = deepLinkState.referrer
            return [entity]
        }
        return nil
    }
    
    func filter(event: InspectableEvent, state: State?) -> Bool? {
        return nil
    }

    func payloadValues(from event: InspectableEvent, state: State?) -> [String : Any]? {
        return nil
    }
    
    func afterTrack(event: InspectableEvent) {
    }
}
