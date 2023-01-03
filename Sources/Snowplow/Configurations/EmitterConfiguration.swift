//
//  EmitterConfiguration.swift
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Foundation

@objc(SPEmitterConfigurationProtocol)
public protocol EmitterConfigurationProtocol: AnyObject {
    /// Sets whether the buffer should send events instantly or after the buffer
    /// has reached it's limit. By default, this is set to BufferOption Default.
    @objc
    var bufferOption: BufferOption { get set }
    /// Maximum number of events collected from the EventStore to be sent in a request.
    @objc
    var emitRange: Int { get set }
    /// Maximum number of threads working in parallel in the tracker to send requests.
    @objc
    var threadPoolSize: Int { get set }
    /// Maximum amount of bytes allowed to be sent in a payload in a GET request.
    @objc
    var byteLimitGet: Int { get set }
    /// Maximum amount of bytes allowed to be sent in a payload in a POST request.
    @objc
    var byteLimitPost: Int { get set }
    /// Callback called for each request performed by the tracker to the collector.
    @objc
    var requestCallback: RequestCallback? { get set }
    ///  Custom retry rules for HTTP status codes returned from the Collector.
    ///  The dictionary is a mapping of integers (status codes) to booleans (true for retry and false for not retry).
    @objc
    var customRetryForStatusCodes: [Int : Bool]? { get set }
    /// Whether to anonymise server-side user identifiers including the `network_userid` and `user_ipaddress`
    @objc
    var serverAnonymisation: Bool { get set }
}

/// It allows the tracker configuration from the emission perspective.
/// The EmitterConfiguration can be used to setup details about how the tracker should treat the events
/// to emit to the collector.
@objc(SPEmitterConfiguration)
public class EmitterConfiguration: NSObject, EmitterConfigurationProtocol, ConfigurationProtocol {
    /// Sets whether the buffer should send events instantly or after the buffer
    /// has reached it's limit. By default, this is set to BufferOption Default.
    @objc
    public var bufferOption: BufferOption = EmitterDefaults.bufferOption

    /// Maximum number of events collected from the EventStore to be sent in a request.
    @objc
    public var emitRange: Int = EmitterDefaults.emitRange

    /// Maximum number of threads working in parallel in the tracker to send requests.
    @objc
    public var threadPoolSize: Int = EmitterDefaults.emitThreadPoolSize

    /// Maximum amount of bytes allowed to be sent in a payload in a GET request.
    @objc
    public var byteLimitGet: Int = EmitterDefaults.byteLimitGet

    /// Maximum amount of bytes allowed to be sent in a payload in a POST request.
    @objc
    public var byteLimitPost: Int = EmitterDefaults.byteLimitPost

    /// Callback called for each request performed by the tracker to the collector.
    @objc
    public var requestCallback: RequestCallback?

    /// Custom retry rules for HTTP status codes returned from the Collector.
    /// The dictionary is a mapping of integers (status codes) to booleans (true for retry and false for not retry).
    @objc
    public var customRetryForStatusCodes: [Int : Bool]?

    /// Whether to anonymise server-side user identifiers including the `network_userid` and `user_ipaddress`
    @objc
    public var serverAnonymisation: Bool = EmitterDefaults.serverAnonymisation

    /// Custom component with full ownership for persisting events before to be sent to the collector.
    /// If it's not set the tracker will use a SQLite database as default EventStore.
    @objc
    public var eventStore: EventStore?

    /// It sets a default EmitterConfiguration.
    /// Default values:
    ///         bufferOption = BufferOption.Single;
    ///         emitRange = 150;
    ///         threadPoolSize = 15;
    ///         byteLimitGet = 40000;
    ///         byteLimitPost = 40000;
    ///         serverAnonymisation = false;
    @objc
    public override init() {
        super.init()
    }
    
    // MARK: - Builders
    
    /// Sets whether the buffer should send events instantly or after the buffer
    /// has reached it's limit. By default, this is set to BufferOption Default.
    @objc
    public func bufferOption(_ option: BufferOption) -> Self {
        self.bufferOption = option
        return self
    }

    /// Maximum number of events collected from the EventStore to be sent in a request.
    @objc
    public func emitRange(_ range: Int) -> Self {
        self.emitRange = range
        return self
    }

    /// Maximum number of threads working in parallel in the tracker to send requests.
    @objc
    public func threadPoolSize(_ size: Int) -> Self {
        self.threadPoolSize = size
        return self
    }

    /// Maximum amount of bytes allowed to be sent in a payload in a GET request.
    @objc
    public func byteLimitGet(_ limit: Int) -> Self {
        self.byteLimitGet = limit
        return self
    }

    /// Maximum amount of bytes allowed to be sent in a payload in a POST request.
    @objc
    public func byteLimitPost(_ limit: Int) -> Self {
        self.byteLimitPost = limit
        return self
    }

    /// Callback called for each request performed by the tracker to the collector.
    @objc
    public func requestCallback(_ callback: RequestCallback?) -> Self {
        self.requestCallback = callback
        return self
    }

    /// Custom retry rules for HTTP status codes returned from the Collector.
    /// The dictionary is a mapping of integers (status codes) to booleans (true for retry and false for not retry).
    @objc
    public func customRetryForStatusCodes(_ rules: [Int : Bool]?) -> Self {
        self.customRetryForStatusCodes = rules
        return self
    }

    /// Whether to anonymise server-side user identifiers including the `network_userid` and `user_ipaddress`
    @objc
    public func serverAnonymisation( serverAnonymisation: Bool) -> Self {
        self.serverAnonymisation = serverAnonymisation
        return self
    }

    /// Custom component with full ownership for persisting events before to be sent to the collector.
    /// If it's not set the tracker will use a SQLite database as default EventStore.
    @objc
    public func eventStore(_ eventStore: EventStore?) -> Self {
        self.eventStore = eventStore
        return self
    }
}
