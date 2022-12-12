//
//  Timing.swift
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

/// A timing event.
///
/// Schema: `iglu:com.snowplowanalytics.snowplow/timing/jsonschema/1-0-0`
@objc(SPTiming)
public class Timing: SelfDescribingAbstract {
    /// The timing category
    @objc
    public var category: String
    /// The timing variable
    @objc
    public var variable: String
    /// The time
    @objc
    public var timing: Int
    /// The timing label
    @objc
    public var label: String?

    /// Creates a timing event
    /// - Parameter category: The timing category
    /// - Parameter variable: The timing variable
    /// - Parameter timing: The time
    @objc
    public init(category: String, variable: String, timing: Int) {
        self.category = category
        self.variable = variable
        self.timing = timing
    }

    override var schema: String {
        return kSPUserTimingsSchema
    }

    override var payload: [String : NSObject] {
        var payload: [String : NSObject] = [:]
        payload[kSPUtCategory] = category as NSObject
        payload[kSPUtVariable] = variable as NSObject
        payload[kSPUtTiming] = NSNumber(value: timing)
        if let label = label { payload[kSPUtLabel] = label as NSObject }
        return payload
    }
}
