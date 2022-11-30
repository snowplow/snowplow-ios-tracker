//
//  Background.swift
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

/// A background transition event.
@objc(SPBackground)
public class Background: SelfDescribingAbstract {
    /// Index indicating the current transition.
    @objc
    public var index: Int

    /// Creates a brackground transition event.
    /// - Parameter index: indicate the current transition.
    @objc
    public init(index: Int) {
        self.index = index
    }

    override public var schema: String {
        return kSPBackgroundSchema
    }

    override public var payload: [String : NSObject] {
        var payload: [AnyHashable : Any] = [:]
        payload[kSPBackgroundIndex] = NSNumber(value: index)
        return payload as? [String : NSObject] ?? [:]
    }
}
