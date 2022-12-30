//
//  NetworkConfiguration.swift
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

/// Represents the network communication configuration allowing the tracker to be able to send events to the Snowplow collector.
@objc(SPNetworkConfiguration)
public class NetworkConfiguration: SerializableConfiguration, ConfigurationProtocol {
    /// URL (without schema/protocol) used to send events to the collector.
    @objc
    private(set) public var endpoint: String?
    /// Method used to send events to the collector.
    @objc
    private(set) public var method: HttpMethodOptions
    /// Method used to send events to the collector.
    /// Protocol used to send events to the collector.
    @objc
    private(set) public var `protocol`: ProtocolOptions
    /// See `NetworkConfiguration(NetworkConnection)`
    @objc
    public var networkConnection: NetworkConnection?
    /// A custom path which will be added to the endpoint URL to specify the
    /// complete URL of the collector when paired with the POST method.
    @objc
    public var customPostPath: String?
    ///  Custom headers for http requests.
    @objc
    public var requestHeaders: [String : String]?

    // TODO: add -> @property () NSInteger timeout;

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
            self.protocol = ProtocolOptions.https
            self.endpoint = endpoint
        } else if url?.scheme == "http" {
            self.protocol = ProtocolOptions.http
            self.endpoint = endpoint
        } else {
            self.protocol = ProtocolOptions.https
            self.endpoint = "https://\(endpoint)"
        }
        self.method = method
        networkConnection = nil
        customPostPath = nil
    }

    /// - Parameter networkConnection: The NetworkConnection component which will control the
    ///                          communication between the tracker and the collector.
    @objc
    public init(networkConnection: NetworkConnection?) {
        endpoint = nil
        self.protocol = .https
        method = .post
        self.networkConnection = networkConnection
        customPostPath = nil
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
        endpoint = coder.decodeObject(forKey: "endpoint") as? String
        self.protocol = ProtocolOptions(rawValue: coder.decodeInteger(forKey: "protocol")) ?? .https
        method = HttpMethodOptions(rawValue: coder.decodeInteger(forKey: "method")) ?? .post
        customPostPath = coder.decodeObject(forKey: "customPostPath") as? String
        requestHeaders = coder.decodeObject(forKey: "requestHeaders") as? [String : String]
    }
}
