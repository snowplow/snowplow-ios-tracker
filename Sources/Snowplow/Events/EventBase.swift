//  Copyright (c) 2023 Snowplow Analytics Ltd. All rights reserved.
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

/// This class has the basic functionality needed to represent all events
@objc(SPEvent)
public class Event: NSObject {
    /// The user event timestamp in milliseconds (epoch time).
    @objc
    public var trueTimestamp: Date?
    
    private var _entities: [SelfDescribingJson] = []
    /// The context entities attached to the event.
    @objc
    public var entities: [SelfDescribingJson] {
        get {
            if (isProcessing) {
                if let entitiesForProcessing = entitiesForProcessing {
                    return _entities + entitiesForProcessing
                }
            }
            return _entities
        }
        set {
            _entities = newValue
        }
    }
    
    /// The context entities attached to the event.
    @objc
    @available(*, deprecated, renamed: "entities")
    public var contexts: [SelfDescribingJson] {
        get { return entities }
        set { entities = newValue }
    }
    
    /// Used for events whose properties are added as entities, e.g. Ecommerce events
    @objc
    internal var entitiesForProcessing: [SelfDescribingJson]? {
        get { return nil }
    }
    
    /// The payload of the event.
    var payload: [String : Any] {
        NSException(
            name: .internalInconsistencyException,
            reason: "You must override \(NSStringFromSelector(#function)) in a subclass",
            userInfo: nil).raise()
        abort()
    }

    private var isProcessing = false
    /// Hook method called just before the event processing in order to execute special operations.
    /// @note Internal use only - Don't use in production, it can change without notice.
    func beginProcessing(withTracker tracker: Tracker) {
        isProcessing = true
    }

    /// Hook method called just after the event processing in order to execute special operations.
    /// @note Internal use only - Don't use in production, it can change without notice.
    func endProcessing(withTracker tracker: Tracker) {
        isProcessing = false
    }
    
    // MARK: - Builders
    
    /// The user event timestamp in milliseconds (epoch time).
    @objc
    public func trueTimestamp(_ timestamp: Date?) -> Self {
        self.trueTimestamp = timestamp
        return self
    }
    
    /// Replace the context entities attached to the event with a new list of entities.
    @objc
    public func entities(_ entities: [SelfDescribingJson]) -> Self {
        self.entities = entities
        return self
    }
    
    /// Replace the context entities attached to the event with a new list of entities.
    @objc
    @available(*, deprecated, renamed: "entities")
    public func contexts(_ entities: [SelfDescribingJson]) -> Self {
        self.entities = entities
        return self
    }
}

/// The properties for all the self-describing events.
@objc(SPSelfDescribingAbstract)
public class SelfDescribingAbstract: Event {
    /// The schema of the event.
    @objc
    var schema: String {
        NSException(
            name: .internalInconsistencyException,
            reason: "You must override \(NSStringFromSelector(#function)) in a subclass",
            userInfo: nil).raise()
        abort()
    }
}

/// The properties for all the self-describing events.
@objc(SPPrimitiveAbstract)
public class PrimitiveAbstract: Event {
    /// The name of the event.
    var eventName: String {
        NSException(
            name: .internalInconsistencyException,
            reason: "You must override \(NSStringFromSelector(#function)) in a subclass",
            userInfo: nil).raise()
        abort()
    }
}
