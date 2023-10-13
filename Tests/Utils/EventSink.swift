//
//  File.swift
//  
//
//  Created by Matus Tomlein on 13/10/2023.
//

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
