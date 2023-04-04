// Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.

import Foundation

/// A deep-link received in the app.
///
/// Schema: `iglu:com.snowplowanalytics.mobile/deep_link_received/jsonschema/1-0-0`
@objc(SPDeepLinkReceived)
public class DeepLinkReceived: SelfDescribingAbstract {
    /// Referrer URL, source of this deep-link.
    @objc
    public var referrer: String?
    /// URL in the received deep-link.
    @objc
    public var url: String

    /// Creates a deep-link received event.
    /// - Parameter url: URL in the received deep-link.
    @objc
    public init(url: String) {
        self.url = url
    }

    @objc
    class var schema: String {
        return "iglu:com.snowplowanalytics.mobile/deep_link_received/jsonschema/1-0-0"
    }

    @objc
    class var paramUrl: String {
        return "url"
    }

    @objc
    class var paramReferrer: String {
        return "referrer"
    }

    override var schema: String {
        return DeepLinkReceived.schema
    }

    override var payload: [String : Any] {
        var payload: [String : Any] = [:]
        if let referrer = referrer {
            payload[DeepLinkReceived.paramReferrer] = referrer
        }
        payload[DeepLinkReceived.paramUrl] = url
        return payload
    }
    
    // MARK: - Builders
    
    /// Referrer URL, source of this deep-link.
    @objc
    public func referrer(_ referrer: String?) -> Self {
        self.referrer = referrer
        return self
    }
}
