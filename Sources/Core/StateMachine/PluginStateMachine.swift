// Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

typealias EntitiesConfiguration = (schemas: [String]?, closure: (InspectableEvent) -> ([SelfDescribingJson]))
typealias AfterTrackConfiguration = (schemas: [String]?, closure: (InspectableEvent) -> ())
typealias FilterConfiguration = (schemas: [String]?, closure: (InspectableEvent) -> Bool)
typealias BeforeTrackConfiguration = (schemas: [String]?, closure: (InspectableEvent) -> [String: Any]?)

class PluginStateMachine: StateMachineProtocol {
    var identifier: String
    private var entitiesConfiguration: EntitiesConfiguration?
    private var afterTrackConfiguration: AfterTrackConfiguration?
    private var filterConfiguration: FilterConfiguration?
    private var beforeTrackConfiguration: BeforeTrackConfiguration?

    init(
        identifier: String,
        entitiesConfiguration: EntitiesConfiguration?,
        afterTrackConfiguration: AfterTrackConfiguration?,
        filterConfiguration: FilterConfiguration?,
        beforeTrackConfiguration: BeforeTrackConfiguration? = nil
    ) {
        self.identifier = identifier
        self.entitiesConfiguration = entitiesConfiguration
        self.afterTrackConfiguration = afterTrackConfiguration
        self.filterConfiguration = filterConfiguration
        self.beforeTrackConfiguration = beforeTrackConfiguration
    }

    var subscribedEventSchemasForEventsBefore: [String] {
        return []
    }
    
    func eventsBefore(event: Event) -> [Event]? {
        return nil
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
        if let beforeTrackConfiguration = beforeTrackConfiguration {
            if let schemas = beforeTrackConfiguration.schemas {
                return schemas
            } else {
                return ["*"]
            }
        }
        return []
    }

    func payloadValues(from event: InspectableEvent, state: State?) -> [String : Any]? {
        return beforeTrackConfiguration?.closure(event)
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
    
    var subscribedEventSchemasForFiltering: [String] {
        if let filterConfiguration = filterConfiguration {
            if let schemas = filterConfiguration.schemas {
                return schemas
            } else {
                return ["*"]
            }
        }
        return []
    }
    
    func filter(event: InspectableEvent, state: State?) -> Bool? {
        if let filterConfiguration = filterConfiguration {
            return filterConfiguration.closure(event)
        }
        return nil
    }
}
