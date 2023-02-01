//
//  PluginStateMachine.swift
//  Snowplow
//
// Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
// License: Apache License Version 2.0
//

import Foundation

typealias EntitiesConfiguration = (schemas: [String]?, closure: (InspectableEvent) -> ([SelfDescribingJson]))
typealias AfterTrackConfiguration = (schemas: [String]?, closure: (InspectableEvent) -> ())

class PluginStateMachine: StateMachineProtocol {
    var identifier: String
    private var entitiesConfiguration: EntitiesConfiguration?
    private var afterTrackConfiguration: AfterTrackConfiguration?

    init(
        identifier: String,
        entitiesConfiguration: EntitiesConfiguration?,
        afterTrackConfiguration: AfterTrackConfiguration?
    ) {
        self.identifier = identifier
        self.entitiesConfiguration = entitiesConfiguration
        self.afterTrackConfiguration = afterTrackConfiguration
    }

    var subscribedEventSchemasForTransitions: [String] {
        return []
    }

    func transition(from event: Event, state currentState: State?) -> State? {
        return nil
    }

    var subscribedEventSchemasForEntitiesGeneration: [String] {
        if let entitiesConfiguration = entitiesConfiguration {
            if let schemas = entitiesConfiguration.schemas {
                return schemas
            } else {
                return ["*"]
            }
        }
        return []
    }

    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]? {
        if let entitiesConfiguration = entitiesConfiguration {
            return entitiesConfiguration.closure(event)
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
        if let afterTrackConfiguration = afterTrackConfiguration {
            if let schemas = afterTrackConfiguration.schemas {
                return schemas
            } else {
                return ["*"]
            }
        }
        return []
    }

    func afterTrack(event: InspectableEvent) {
        if let afterTrackConfiguration = afterTrackConfiguration {
            afterTrackConfiguration.closure(event)
        }
    }
}
