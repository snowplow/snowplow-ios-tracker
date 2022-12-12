//
//  Ecommerce.swift
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

@objc(SPEcommerce)
public class Ecommerce : PrimitiveAbstract {
    /// Identifier of the order.
    @objc
    public var orderId: String
    /// Total amount of the order.
    @objc
    public var totalValue: Double
    /// Items purchased.
    @objc
    public var items: [EcommerceItem]
    /// Identifies an affiliation.
    @objc
    public var affiliation: String?
    /// Taxes applied to the purchase.
    @objc
    public var taxValue: NSNumber?
    /// Shipping number.
    @objc
    public var shipping: NSNumber?
    /// City for shipping.
    @objc
    public var city: String?
    /// State for shipping.
    @objc
    public var state: String?
    /// Country for shipping.
    @objc
    public var country: String?
    /// Currency used for totalValue and taxValue.
    @objc
    public var currency: String?

    @objc
    public init(orderId: String, totalValue: Double, items: [EcommerceItem]?) {
        self.orderId = orderId
        self.totalValue = totalValue
        self.items = items ?? []
    }

    override var eventName: String {
        return kSPEventEcomm
    }

    override var payload: [String : NSObject] {
        var payload: [String : NSObject] = [:]
        payload[kSPEcommTotal] = String(format: "%.02f", totalValue) as NSObject
        if let taxValue = taxValue {
            payload[kSPEcommTax] = String(format: "%.02f", taxValue.doubleValue) as NSObject
        }
        if let shipping = shipping {
            payload[kSPEcommShipping] = String(format: "%.02f", shipping.doubleValue) as NSObject
        }
        payload[kSPEcommId] = orderId as NSObject
        payload[kSPEcommAffiliation] = affiliation as NSObject?
        payload[kSPEcommCity] = city as NSObject?
        payload[kSPEcommState] = state as NSObject?
        payload[kSPEcommCountry] = country as NSObject?
        payload[kSPEcommCurrency] = currency as NSObject?
        return payload
    }

    override func endProcessing(withTracker tracker: Tracker?) {
        for item in items {
            item.orderId = orderId
            _ = tracker?.track(item)
        }
    }
}
