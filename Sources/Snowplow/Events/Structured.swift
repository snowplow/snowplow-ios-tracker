//
//  Structured.swift
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

/// A structured event.
@objc(SPStructured)
public class Structured: PrimitiveAbstract {
    @objc
    public var category: String
    @objc
    public var action: String
    @objc
    public var label: String?
    @objc
    public var property: String?
    @objc
    public var value: NSNumber?

    @objc
    public init(category: String, action: String) {
        self.category = category
        self.action = action
    }

    @objc
    override public var eventName: String {
        return kSPEventStructured
    }

    override public var payload: [String : NSObject] {
        var payload: [String : NSObject] = [:]
        payload[kSPStuctCategory] = category as NSObject
        payload[kSPStuctAction] = action as NSObject
        if let label = label { payload[kSPStuctLabel] = label as NSObject }
        if let property = property { payload[kSPStuctProperty] = property as NSObject }
        if let value = value {
            payload[kSPStuctValue] = String(format: "%.17g", value.doubleValue) as NSObject
        }
        return payload
    }
}
