//
// SPDeepLinkEntity.swift
// Snowplow
//
// Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
// License: Apache License Version 2.0
//

import Foundation

/// Entity that indicates a deep-link has been received and processed.
@objc(SPDeepLinkEntity)
public class DeepLinkEntity: SelfDescribingJson {
    @objc
    public static let schema = "iglu:com.snowplowanalytics.mobile/deep_link/jsonschema/1-0-0"
    @objc
    public static let paramReferrer = "referrer"
    @objc
    public static let paramUrl = "url"
    
    @objc
    public var url: String
    @objc
    public var referrer: String?

    @objc
    public init(url: String) {
        self.url = url
        super.init(schema: DeepLinkEntity.schema, andData: nil)
    }

    @objc
    override public var data: NSObject? {
        get {
            var data: [String: NSObject] = [:]
            data[DeepLinkEntity.paramUrl] = url as NSObject
            data[DeepLinkEntity.paramReferrer] = referrer as NSObject?
            return data as NSObject
        }
        set {}
    }
}
