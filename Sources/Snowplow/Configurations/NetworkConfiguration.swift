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

/// Represents the network communication configuration allowing the tracker to be able to send events to the Snowplow collector.
@objc(SPNetworkConfiguration)
public class NetworkConfiguration: SerializableConfiguration, ConfigurationProtocol {
    private var _endpoint: String?
    /// URL (without schema/protocol) used to send events to the collector.
    @objc
    private(set) public var endpoint: String? {
        get { return _endpoint ?? sourceConfig?.endpoint }
        set { _endpoint = newValue }
    }
    
    private var _method: HttpMethodOptions?
    /// Method used to send events to the collector.
    @objc
    private(set) public var method: HttpMethodOptions {
        get { return _method ?? sourceConfig?.method ?? EmitterDefaults.httpMethod }
        set { _method = newValue }
    }
    
    private var _protocol: ProtocolOptions?
    /// Protocol used to send events to the collector.
    @objc
    private(set) public var `protocol`: ProtocolOptions {
        get { return _protocol ?? sourceConfig?.protocol ?? EmitterDefaults.httpProtocol }
        set { _protocol = newValue }
    }
    
    private var _networkConnection: NetworkConnection?
    /// See `NetworkConfiguration(NetworkConnection)`
    @objc
    public var networkConnection: NetworkConnection? {
        get { return _networkConnection ?? sourceConfig?.networkConnection }
        set { _networkConnection = newValue }
    }
    
    private var _customPostPath: String?
    /// A custom path which will be added to the endpoint URL to specify the
    /// complete URL of the collector when paired with the POST method.
    @objc
    public var customPostPath: String? {
        get { return _customPostPath ?? sourceConfig?.customPostPath }
        set { _customPostPath = newValue }
    }
    
    private var _requestHeaders: [String : String]?
    ///  Custom headers for http requests.
    @objc
    public var requestHeaders: [String : String]? {
        get { return _requestHeaders ?? sourceConfig?.requestHeaders }
        set { _requestHeaders = newValue }
    }
    
    // MARK: - Internal
    
    /// Fallback configuration to read from in case requested values are not present in this configuraiton.
    internal var sourceConfig: NetworkConfiguration?

    // TODO: add -> @property () NSInteger timeout;
    
    internal override init() {
    }

    /// Allow endpoint and method only.
    @objc
    public convenience init?(dictionary: [String : Any]) {
        if let endpoint = dictionary["endpoint"] as? String {
            let method = dictionary["method"] as? String
            let httpMethod = (method == "get") ? HttpMethodOptions.get : HttpMethodOptions.post
            self.init(endpoint: endpoint, method: httpMethod)
        } else {
            return nil
        }
    }

    /// - Parameters:
    ///   - endpoint: URL of the collector that is going to receive the events tracked by the tracker.
    ///                 The URL can include the schema/protocol (e.g.: `http://collector-url.com`).
    ///                 In case the URL doesn't include the schema/protocol, the HTTPS protocol is
    ///                 automatically selected.
    ///   - method: The method used to send the requests (GET or POST).
    @objc
    public init(endpoint: String, method: HttpMethodOptions = EmitterDefaults.httpMethod) {
        let url = URL(string: endpoint)
        if url?.scheme == "https" {
            self._protocol = ProtocolOptions.https
            self._endpoint = endpoint
        } else if url?.scheme == "http" {
            self._protocol = ProtocolOptions.http
            self._endpoint = endpoint
        } else {
            self._protocol = ProtocolOptions.https
            self._endpoint = "https://\(endpoint)"
        }
        self._method = method
    }

    /// - Parameter networkConnection: The NetworkConnection component which will control the
    ///                          communication between the tracker and the collector.
    @objc
    public init(networkConnection: NetworkConnection?) {
        self._networkConnection = networkConnection
    }
    
    // MARK: - Builders
    
    /// A custom path which will be added to the endpoint URL to specify the
    /// complete URL of the collector when paired with the POST method.
    @objc
    public func customPostPath(_ path: String?) -> Self {
        self.customPostPath = path
        return self
    }
    
    ///  Custom headers for http requests.
    @objc
    public func requestHeaders(_ headers: [String : String]?) -> Self {
        self.requestHeaders = headers
        return self
    }

    // MARK: - NSCopying

    @objc
    public override func copy(with zone: NSZone? = nil) -> Any {
        var copy: NetworkConfiguration?
        if let connection = networkConnection {
            copy = NetworkConfiguration(networkConnection: connection)
        } else {
            copy = NetworkConfiguration(endpoint: endpoint ?? "", method: method )
        }
        copy?.customPostPath = customPostPath
        return copy!
    }

    // MARK: - NSSecureCoding
    
    @objc
    public override class var supportsSecureCoding: Bool { return true }

    @objc
    public override func encode(with coder: NSCoder) {
        coder.encode(endpoint, forKey: "endpoint")
        coder.encode(self.protocol.rawValue, forKey: "protocol")
        coder.encode(method.rawValue, forKey: "method")
        coder.encode(customPostPath, forKey: "customPostPath")
        coder.encode(requestHeaders, forKey: "requestHeaders")
    }

    required init?(coder: NSCoder) {
        _endpoint = coder.decodeObject(forKey: "endpoint") as? String
        _protocol = ProtocolOptions(rawValue: coder.decodeInteger(forKey: "protocol"))
        _method = HttpMethodOptions(rawValue: coder.decodeInteger(forKey: "method"))
        _customPostPath = coder.decodeObject(forKey: "customPostPath") as? String
        _requestHeaders = coder.decodeObject(forKey: "requestHeaders") as? [String : String]
    }
}
