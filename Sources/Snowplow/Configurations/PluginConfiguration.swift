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

/// Closure used in after track plugin callbacks.
public typealias PluginAfterTrackClosure = (InspectableEvent) -> Void
/// Closure used in plugin callbacks to generate entities.
public typealias PluginEntitiesClosure = (InspectableEvent) -> [SelfDescribingJson]
/// Closure used in plugin callbacks to decide whether to track the given event or not.
public typealias PluginFilterClosure = (InspectableEvent) -> Bool
/// Closure used in before-track plugin callbacks to overwrite or add payload key-value pairs.
///
/// - Returns: A dictionary of payload keys and values to overwrite or add, or `nil` to make no
///   changes. Keys are raw tracker key names (e.g. `url`, `se_ca`), not final collector field
///   names. Returning a key with a value overwrites it in the payload; key removal is not
///   supported in v1.
///
/// - Important: The closure runs on the tracker's internal dispatch queue. A blocking closure
///   will stall event tracking.
public typealias PluginBeforeTrackClosure = (InspectableEvent) -> [String: Any]?

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

/// Provides a Swift-only closure to inspect and mutate the event payload before it is sent to
/// the collector. Use this to overwrite or add payload fields, e.g. for consent-based field
/// stripping.
///
/// - Note: Swift-only — no Objective-C bridging.
/// - Important: The closure runs on the tracker's internal dispatch queue. A blocking closure
///   will stall event tracking.
/// - Note: v1 semantics: overwrite/add only. Key removal is not supported in this release.
/// - Note: Payload keys are raw tracker key names (e.g. `url`, `se_ca`), not final collector
///   field names.
public class PluginBeforeTrackConfiguration {
    var schemas: [String]?
    var closure: PluginBeforeTrackClosure

    /// Create the before track closure configuration.
    /// - Parameters:
    ///   - schemas: Optional list of event schemas to call the closure for. If nil, the closure
    ///     is called for all events.
    ///   - closure: Closure that returns payload key-value pairs to overwrite or add.
    public init(schemas: [String]? = nil, closure: @escaping PluginBeforeTrackClosure) {
        self.schemas = schemas
        self.closure = closure
    }

    func toTuple() -> (schemas: [String]?, closure: PluginBeforeTrackClosure) {
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

/// Provides a closure that is called to decide whether to track a given event or not.
/// - Parameters:
///   - schemas: Optional list of event schemas to call the closure for. If null, the closure is called for all events.
///   - closure: Closure block that returns true if the event should be tracked and false otherwise.
@objc(SPPluginFilterConfiguration)
public class PluginFilterConfiguration : NSObject {
    var schemas: [String]?
    var closure: PluginFilterClosure
    
    /// Creates the closure configuration
    /// - Parameters:
    ///   - schemas: Optional list of event schemas to call the closure for. If null, the closure is called for all events.
    ///   - closure: Closure block that returns true if the event should be tracked and false otherwise.
    public init(schemas: [String]? = nil, closure: @escaping PluginFilterClosure) {
        self.schemas = schemas
        self.closure = closure
    }
    
    func toTuple() -> (schemas: [String]?, closure: PluginFilterClosure) {
        return (schemas: schemas, closure: closure)
    }
}

/// Identifies a tracker plugin with a unique identifier. Required for all plugins.
@objc(SPPluginIdentifiable)
public protocol PluginIdentifiable {
    /// Unique identifier of the plugin within the tracker.
    var identifier: String { get }
}

extension PluginIdentifiable {
    func toStateMachine() -> StateMachineProtocol {
        var entitiesConfiguration: PluginEntitiesConfiguration?
        if let entitiesCallable = self as? PluginEntitiesCallable {
            entitiesConfiguration = entitiesCallable.entitiesConfiguration
        }
        var afterTrackConfiguration: PluginAfterTrackConfiguration?
        if let afterTrackCallable = self as? PluginAfterTrackCallable {
            afterTrackConfiguration = afterTrackCallable.afterTrackConfiguration
        }
        var filterConfiguration: PluginFilterConfiguration?
        if let filterCallable = self as? PluginFilterCallable {
            filterConfiguration = filterCallable.filterConfiguration
        }
        var beforeTrackConfiguration: PluginBeforeTrackConfiguration?
        if let beforeTrackCallable = self as? PluginBeforeTrackCallable {
            beforeTrackConfiguration = beforeTrackCallable.beforeTrackConfiguration
        }
        return PluginStateMachine(
            identifier: identifier,
            entitiesConfiguration: entitiesConfiguration?.toTuple(),
            afterTrackConfiguration: afterTrackConfiguration?.toTuple(),
            filterConfiguration: filterConfiguration?.toTuple(),
            beforeTrackConfiguration: beforeTrackConfiguration?.toTuple())
    }
}

/// Protocol for a plugin that provides a closure to call after events are tracked.
@objc(SPPluginAfterTrackCallable)
public protocol PluginAfterTrackCallable {
    /// Closure configuration that is called after events are tracked.
    var afterTrackConfiguration: PluginAfterTrackConfiguration? { get }
}

/// Protocol for a plugin that provides a closure to generate context entities to enrich events.
@objc(SPPluginEntitiesCallable)
public protocol PluginEntitiesCallable {
    /// Closure configuration that is called when events are tracked to generate context entities to enrich the events.
    var entitiesConfiguration: PluginEntitiesConfiguration? { get }
}

/// Protocol for a plugin that provides a closure to decide whether to track events or not.
@objc(SPPluginFilterCallable)
public protocol PluginFilterCallable {
    /// Closure configuration that is called when events are tracked to decide whether to track them or not.
    var filterConfiguration: PluginFilterConfiguration? { get }
}

/// Protocol for a plugin that provides a Swift-only closure to inspect and mutate the event
/// payload before it is sent to the collector.
public protocol PluginBeforeTrackCallable {
    /// Closure configuration that is called before events are sent to mutate the payload.
    var beforeTrackConfiguration: PluginBeforeTrackConfiguration? { get }
}

/// Protocol for tracker plugin definition.
/// Specifies configurations for the closures called when and after events are tracked.
@available(*, deprecated, message: "Use PluginIdentifiable, PluginAfterTrackCallable and PluginEntitiesCallable protocols instead")
@objc(SPPluginConfigurationProtocol)
public protocol PluginConfigurationProtocol : PluginIdentifiable, PluginAfterTrackCallable, PluginEntitiesCallable {
}

/// Configuration for a custom tracker plugin.
/// Enables you to add closures to be called when and after events are tracked in the tracker.
@objc(SPPluginConfiguration)
public class PluginConfiguration: NSObject, PluginIdentifiable, PluginAfterTrackCallable, PluginEntitiesCallable, PluginFilterCallable, PluginBeforeTrackCallable, ConfigurationProtocol {
    /// Unique identifier of the plugin within the tracker.
    public private(set) var identifier: String
    /// Closure configuration that is called after events are tracked.
    /// Read-only, use `afterTrack(schemas:closure:)` to initialize.
    public private(set) var afterTrackConfiguration: PluginAfterTrackConfiguration?
    /// Closure configuration that is called when events are tracked to generate context entities to enrich the events.
    /// Read-only, use `entities(schemas:closure:)` to initialize.
    public private(set) var entitiesConfiguration: PluginEntitiesConfiguration?
    /// Closure configuration that is called to decide whether to track a given event or not.
    public private(set) var filterConfiguration: PluginFilterConfiguration?
    /// Closure configuration that is called before events are sent to the collector to overwrite
    /// or add payload fields.
    /// Read-only, use `beforeTrack(schemas:closure:)` to initialize.
    public private(set) var beforeTrackConfiguration: PluginBeforeTrackConfiguration?

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
    
    /// Add a closure that is called to decide whether to track a given event or not.
    /// - Parameters:
    ///   - schemas: Optional list of event schemas to call the closure for. If null, the closure is called for all events.
    ///   - closure: Closure block that returns true if the event should be tracked and false otherwise.
    public func filter(schemas: [String]? = nil, closure: @escaping PluginFilterClosure) -> Self {
        self.filterConfiguration = PluginFilterConfiguration(
            schemas: schemas,
            closure: closure
        )
        return self
    }

    /// Add a Swift-only closure that is called before each event is sent to the collector,
    /// allowing you to overwrite or add payload fields.
    ///
    /// - Parameters:
    ///   - schemas: Optional list of event schemas to call the closure for. If nil, the closure
    ///     is called for all events.
    ///   - closure: Closure that returns a dictionary of payload keys and values to overwrite or
    ///     add, or nil to make no changes. Keys are raw tracker key names (e.g. `url`, `se_ca`),
    ///     not final collector field names. v1: overwrite/add only — key removal is not
    ///     supported.
    ///
    /// - Important: The closure runs on the tracker's internal dispatch queue. A blocking
    ///   closure will stall event tracking.
    public func beforeTrack(schemas: [String]? = nil, closure: @escaping PluginBeforeTrackClosure) -> Self {
        self.beforeTrackConfiguration = PluginBeforeTrackConfiguration(
            schemas: schemas,
            closure: closure
        )
        return self
    }
}
