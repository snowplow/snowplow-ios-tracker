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

/// Represents the configuration for fetching configurations from a remote source.
/// For details on the correct format of a remote configuration see the official documentation.
@objc(SPRemoteConfiguration)
public class RemoteConfiguration: NSObject {
    /// URL of the remote configuration.
    @objc
    private(set) public var endpoint: String
    /// The method used to send the request.
    private(set) public var method: HttpMethodOptions?
    
    /// - Parameters:
    ///   - endpoint: URL of the remote configuration.
    ///                 The URL can include the schema/protocol (e.g.: `http://remote-config-url.xyz`).
    ///                 In case the URL doesn't include the schema/protocol, the HTTPS protocol is
    ///                 automatically selected.
    @objc
    public init(endpoint: String) {
        let url = URL(string: endpoint)
        if url?.scheme != nil && ["https", "http"].contains(url?.scheme ?? "") {
            self.endpoint = endpoint
        } else {
            self.endpoint = "https://\(endpoint)"
        }
    }

    /// - Parameters:
    ///   - endpoint: URL of the remote configuration.
    ///                 The URL can include the schema/protocol (e.g.: `http://remote-config-url.xyz`).
    ///                 In case the URL doesn't include the schema/protocol, the HTTPS protocol is
    ///                 automatically selected.
    ///   - method: The method used to send the requests (GET or POST).
    @objc
    public convenience init(endpoint: String, method: HttpMethodOptions) {
        self.init(endpoint: endpoint)
        self.method = method
    }
}
