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

/// Entity that indicates a deep-link has been received and processed.
///
/// Schema: `iglu:com.snowplowanalytics.mobile/deep_link/jsonschema/1-0-0`
@objc(SPDeepLinkEntity)
public class DeepLinkEntity: SelfDescribingJson {
    @objc
    static let schema = "iglu:com.snowplowanalytics.mobile/deep_link/jsonschema/1-0-0"
    @objc
    static let paramReferrer = "referrer"
    @objc
    static let paramUrl = "url"
    
    /// URL in the received deep-link
    @objc
    public var url: String
    /// Referrer URL, source of this deep-link
    @objc
    public var referrer: String?

    @objc
    public init(url: String) {
        self.url = url
        super.init(schema: DeepLinkEntity.schema, andData: [:])
    }

    @objc
    override public var data: [String : Any] {
        get {
            var data: [String: Any] = [:]
            data[DeepLinkEntity.paramUrl] = url
            data[DeepLinkEntity.paramReferrer] = referrer
            return data
        }
        set {}
    }
    
    // MARK: - Builders
    
    /// Referrer URL, source of this deep-link
    @objc
    public func referrer(_ referrer: String?) -> Self {
        self.referrer = referrer
        return self
    }
}
