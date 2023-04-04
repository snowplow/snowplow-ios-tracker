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

/// Closure used in after track plugin callbacks.
public typealias PluginAfterTrackClosure = (InspectableEvent) -> Void
/// Closure used in plugin callbacks to generate entities.
public typealias PluginEntitiesClosure = (InspectableEvent) -> [SelfDescribingJson]

/// Provides a block closure to be called after events are tracked.
/// Optionally, you can specify the event schemas for which the block should be called.
@objc(SPPluginAfterTrackConfiguration)
public class PluginAfterTrackConfiguration: NSObject {
    var schemas: [String]?
    var closure: PluginAfterTrackClosure

    /// Create the after track closure configuration
    /// - Parameters:
    ///    - schemas: Optional list of event schemas to call the block for. If null, the block is called for all events.
    ///    - closure: Block to call after events are tracked.
    public init(schemas: [String]? = nil, closure: @escaping PluginAfterTrackClosure) {
        self.schemas = schemas
        self.closure = closure
    }

    func toTuple() -> (schemas: [String]?, closure: PluginAfterTrackClosure)? {
        return (schemas: schemas, closure: closure)
    }
}

/// Provides a block closure that returns a list of context entities and is called when events are tracked.
/// Optionally, you can specify the event schemas for which the block should be called.
@objc(SPPluginEntitiesConfiguration)
public class PluginEntitiesConfiguration: NSObject {
    var schemas: [String]?
    var closure: PluginEntitiesClosure

    /// Create the entities closure configuration
    /// - Parameters:
    ///    - schemas: Optional list of event schemas to call the block for. If null, the block is called for all events.
    ///    - closure: Block that produces entities, called when events are tracked.
    public init(schemas: [String]? = nil, closure: @escaping PluginEntitiesClosure) {
        self.schemas = schemas
        self.closure = closure
    }

    func toTuple() -> (schemas: [String]?, closure: PluginEntitiesClosure)? {
        return (schemas: schemas, closure: closure)
    }
}

/// Protocol for tracker plugin definition.
/// Specifies configurations for the closures called when and after events are tracked.
@objc(SPPluginConfigurationProtocol)
public protocol PluginConfigurationProtocol {
    /// Unique identifier of the plugin within the tracker.
    var identifier: String { get }
    /// Closure configuration that is called after events are tracked.
    var afterTrackConfiguration: PluginAfterTrackConfiguration? { get }
    /// Closure configuration that is called when events are tracked to generate context entities to enrich the events.
    var entitiesConfiguration: PluginEntitiesConfiguration? { get }
}

extension PluginConfigurationProtocol {
    func toStateMachine() -> StateMachineProtocol {
        return PluginStateMachine(
            identifier: identifier,
            entitiesConfiguration: entitiesConfiguration?.toTuple(),
            afterTrackConfiguration: afterTrackConfiguration?.toTuple())
    }
}

/// Configuration for a custom tracker plugin.
/// Enables you to add closures to be called when and after events are tracked in the tracker.
@objc(SPPluginConfiguration)
public class PluginConfiguration: NSObject, PluginConfigurationProtocol, ConfigurationProtocol {
    /// Unique identifier of the plugin within the tracker.
    public private(set) var identifier: String
    /// Closure configuration that is called after events are tracked.
    /// Read-only, use `afterTrack(schemas:closure:)` to initialize.
    public private(set) var afterTrackConfiguration: PluginAfterTrackConfiguration?
    /// Closure configuration that is called when events are tracked to generate context entities to enrich the events.
    /// Read-only, use `entities(schemas:closure:)` to initialize.
    public private(set) var entitiesConfiguration: PluginEntitiesConfiguration?

    /// Create a plugin configuration.
    /// - Parameters:
    ///    - identifier: Unique identifier of the plugin within the tracker.
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - Builders

    /// Add a closure that generates entities for a given tracked event.
    /// - Parameters:
    ///   - schemas: Optional list of event schemas to call the closure for. If null, the closure is called for all events.
    ///   - closure: Closure that produces entities, called when events are tracked.
    public func entities(schemas: [String]? = nil, closure: @escaping PluginEntitiesClosure) -> Self {
        self.entitiesConfiguration = PluginEntitiesConfiguration(
            schemas: schemas,
            closure: closure
        )
        return self
    }

    /// Add a closure that is called after the events are tracked.
    /// The closure is called after the events are added to event queue in Emitter, not necessarily after they are sent to the Collector.
    /// - Parameters:
    ///   - schemas: Optional list of event schemas to call the closure for. If null, the closure is called for all events.
    ///   - closure: Closure block to call after events are tracked.
    public func afterTrack(schemas: [String]? = nil, closure: @escaping PluginAfterTrackClosure) -> Self {
        self.afterTrackConfiguration = PluginAfterTrackConfiguration(
            schemas: schemas,
            closure: closure
        )
        return self
    }
}
