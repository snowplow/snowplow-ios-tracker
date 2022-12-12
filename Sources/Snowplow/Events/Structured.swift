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
    /// Name for the group of objects you want to track e.g. "media", "ecomm".
    @objc
    public var category: String
    /// Defines the type of user interaction for the web object.
    ///
    /// E.g., "play-video", "add-to-basket".
    @objc
    public var action: String
    /// Identifies the specific object being actioned.
    ///
    /// E.g., ID of the video being played, or the SKU or the product added-to-basket.
    @objc
    public var label: String?
    /// Describes the object or the action performed on it.
    ///
    /// This might be the quantity of an item added to basket
    @objc
    public var property: String?
    /// Quantifies or further describes the user action.
    ///
    /// This might be the price of an item added-to-basket, or the starting time of the video where play was just pressed.
    @objc
    public var value: NSNumber?

    @objc
    public init(category: String, action: String) {
        self.category = category
        self.action = action
    }

    @objc
    override var eventName: String {
        return kSPEventStructured
    }

    override var payload: [String : NSObject] {
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
