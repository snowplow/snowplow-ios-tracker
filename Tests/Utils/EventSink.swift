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
@testable import SnowplowTracker

class EventSink: ConfigurationProtocol, PluginIdentifiable, PluginFilterCallable {
    
    var identifier = "EventSink"
    var filterConfiguration: SnowplowTracker.PluginFilterConfiguration?
    private(set) var trackedEvents: [InspectableEvent] = []
    
    init(callback: ((InspectableEvent) -> Void)? = nil) {
        filterConfiguration = PluginFilterConfiguration { event in
            self.trackedEvents.append(event)
            if let callback = callback {
                callback(event)
            }
            return false
        }
    }
    
    func toStateMachine() -> StateMachineProtocol {
        return PluginStateMachine(
            identifier: identifier,
            entitiesConfiguration: nil,
            afterTrackConfiguration: nil,
            filterConfiguration: (schemas: nil, closure: filterConfiguration!.closure)
        )
    }
}
