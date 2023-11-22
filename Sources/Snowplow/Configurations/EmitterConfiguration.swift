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

@objc(SPEmitterConfigurationProtocol)
public protocol EmitterConfigurationProtocol: AnyObject {
    /// Sets whether the buffer should send events instantly or after the buffer
    /// has reached it's limit. By default, this is set to BufferOption single.
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
    /// Whether to retry sending events that failed to be sent to the collector.
    /// If disabled, events that failed to be sent will be dropped regardless of other configuration (such as the customRetryForStatusCodes).
    @objc
    var retryFailedRequests: Bool { get set }
}

/// It allows the tracker configuration from the emission perspective.
/// The EmitterConfiguration can be used to setup details about how the tracker should treat the events
/// to emit to the collector.
@objc(SPEmitterConfiguration)
public class EmitterConfiguration: SerializableConfiguration, EmitterConfigurationProtocol, ConfigurationProtocol {
    private var _bufferOption: BufferOption?
    /// Sets whether the buffer should send events instantly or after the buffer
    /// has reached it's limit. By default, this is set to BufferOption Default.
    @objc
    public var bufferOption: BufferOption {
        get { return _bufferOption ?? sourceConfig?.bufferOption ?? EmitterDefaults.bufferOption }
        set { _bufferOption = newValue }
    }

    private var _emitRange: Int?
    /// Maximum number of events collected from the EventStore to be sent in a request.
    @objc
    public var emitRange: Int {
        get { return _emitRange ?? sourceConfig?.emitRange ?? EmitterDefaults.emitRange }
        set { _emitRange = newValue }
    }

    private var _threadPoolSize: Int?
    /// Maximum number of threads working in parallel in the tracker to send requests.
    @objc
    public var threadPoolSize: Int {
        get { return _threadPoolSize ?? sourceConfig?.threadPoolSize ?? EmitterDefaults.emitThreadPoolSize }
        set { _threadPoolSize = newValue }
    }

    private var _byteLimitGet: Int?
    /// Maximum amount of bytes allowed to be sent in a payload in a GET request.
    @objc
    public var byteLimitGet: Int {
        get { return _byteLimitGet ?? sourceConfig?.byteLimitGet ?? EmitterDefaults.byteLimitGet }
        set { _byteLimitGet = newValue }
    }

    private var _byteLimitPost: Int?
    /// Maximum amount of bytes allowed to be sent in a payload in a POST request.
    @objc
    public var byteLimitPost: Int {
        get { return _byteLimitPost ?? sourceConfig?.byteLimitPost ?? EmitterDefaults.byteLimitPost }
        set { _byteLimitPost = newValue }
    }

    private var _requestCallback: RequestCallback?
    /// Callback called for each request performed by the tracker to the collector.
    @objc
    public var requestCallback: RequestCallback? {
        get { return _requestCallback ?? sourceConfig?.requestCallback }
        set { _requestCallback = newValue }
    }

    private var _customRetryForStatusCodes: [Int : Bool]?
    /// Custom retry rules for HTTP status codes returned from the Collector.
    /// The dictionary is a mapping of integers (status codes) to booleans (true for retry and false for not retry).
    @objc
    public var customRetryForStatusCodes: [Int : Bool]? {
        get { return _customRetryForStatusCodes ?? sourceConfig?.customRetryForStatusCodes }
        set { _customRetryForStatusCodes = newValue }
    }

    private var _serverAnonymisation: Bool?
    /// Whether to anonymise server-side user identifiers including the `network_userid` and `user_ipaddress`
    @objc
    public var serverAnonymisation: Bool {
        get { return _serverAnonymisation ?? sourceConfig?.serverAnonymisation ?? EmitterDefaults.serverAnonymisation }
        set { _serverAnonymisation = newValue }
    }

    private var _eventStore: EventStore?
    /// Custom component with full ownership for persisting events before to be sent to the collector.
    /// If it's not set the tracker will use a SQLite database as default EventStore.
    @objc
    public var eventStore: EventStore? {
        get { return _eventStore ?? sourceConfig?.eventStore }
        set { _eventStore = newValue }
    }
    
    private var _retryFailedRequests: Bool?
    /// Whether to retry sending events that failed to be sent to the collector.
    /// If disabled, events that failed to be sent will be dropped regardless of other configuration (such as the customRetryForStatusCodes).
    @objc
    public var retryFailedRequests: Bool {
        get { return _retryFailedRequests ?? sourceConfig?.retryFailedRequests ?? EmitterDefaults.retryFailedRequests }
        set { _retryFailedRequests = newValue }
    }
    
    // MARK: - Internal
    
    /// Fallback configuration to read from in case requested values are not present in this configuraiton.
    internal var sourceConfig: EmitterConfiguration?
    
    private var _isPaused: Bool?
    internal var isPaused: Bool {
        get { return _isPaused ?? sourceConfig?.isPaused ?? false }
        set { _isPaused = newValue }
    }

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
    
    @objc
    internal convenience init?(dictionary: [String : Any]) {
        self.init()
        if let bufferOption = dictionary["bufferOption"] as? String {
            self._bufferOption = BufferOption.fromString(value: bufferOption)
        }
        self._emitRange = dictionary["emitRange"] as? Int
        self._threadPoolSize = dictionary["threadPoolSize"] as? Int
        self._byteLimitGet = dictionary["byteLimitGet"] as? Int
        self._byteLimitPost = dictionary["byteLimitPost"] as? Int
        if let retryCodes = dictionary["customRetryForStatusCodes"] as? [String : Bool] {
            self._customRetryForStatusCodes = Dictionary(
                uniqueKeysWithValues: retryCodes
                    .filter { Int($0.key) != nil }
                    .map { (Int($0.key)!, $0.value) }
            )
        }
        self._serverAnonymisation = dictionary["serverAnonymisation"] as? Bool
        self._retryFailedRequests = dictionary["retryFailedRequests"] as? Bool
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
    public func serverAnonymisation(_ serverAnonymisation: Bool) -> Self {
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
    
    /// Whether to retry sending events that failed to be sent to the collector.
    /// If disabled, events that failed to be sent will be dropped regardless of other configuration (such as the customRetryForStatusCodes).
    @objc
    public func retryFailedRequests(_ retryFailedRequests: Bool) -> Self {
        self.retryFailedRequests = retryFailedRequests
        return self
    }
    
    // MARK: - NSCopying

    @objc
    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = EmitterConfiguration()
        copy.bufferOption = bufferOption
        copy.emitRange = emitRange
        copy.threadPoolSize = threadPoolSize
        copy.byteLimitGet = byteLimitGet
        copy.byteLimitPost = byteLimitPost
        copy.requestCallback = requestCallback
        copy.customRetryForStatusCodes = customRetryForStatusCodes
        copy.serverAnonymisation = serverAnonymisation
        copy.eventStore = eventStore
        copy.retryFailedRequests = retryFailedRequests
        return copy
    }

    // MARK: - NSSecureCoding
    
    @objc
    public override class var supportsSecureCoding: Bool { return true }

    @objc
    public override func encode(with coder: NSCoder) {
        coder.encode(bufferOption.rawValue, forKey: "bufferOption")
        coder.encode(emitRange, forKey: "emitRange")
        coder.encode(threadPoolSize, forKey: "threadPoolSize")
        coder.encode(byteLimitGet, forKey: "byteLimitGet")
        coder.encode(byteLimitPost, forKey: "byteLimitPost")
        coder.encode(customRetryForStatusCodes, forKey: "customRetryForStatusCodes")
        coder.encode(serverAnonymisation, forKey: "serverAnonymisation")
        coder.encode(retryFailedRequests, forKey: "retryFailedRequests")
    }

    required init?(coder: NSCoder) {
        super.init()
        if let bufferOption = BufferOption(rawValue: coder.decodeInteger(forKey: "bufferOption")) {
            self.bufferOption = bufferOption
        }
        emitRange = coder.decodeInteger(forKey: "emitRange")
        threadPoolSize = coder.decodeInteger(forKey: "threadPoolSize")
        byteLimitGet = coder.decodeInteger(forKey: "byteLimitGet")
        byteLimitPost = coder.decodeInteger(forKey: "byteLimitPost")
        if let retryCodes = coder.decodeObject(forKey: "customRetryForStatusCodes") as? [Int: Bool] {
            customRetryForStatusCodes = retryCodes
        }
        serverAnonymisation = coder.decodeBool(forKey: "serverAnonymisation")
        if coder.containsValue(forKey: "retryFailedRequests") {
            retryFailedRequests = coder.decodeBool(forKey: "retryFailedRequests")
        }
    }
}
