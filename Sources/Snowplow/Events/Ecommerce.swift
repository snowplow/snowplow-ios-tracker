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

/// @deprecated Use the ecommerce package instead.
@available(*, deprecated, message: "Use the ecommerce package instead.")
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
    /// Shipping cost.
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

    override var payload: [String : Any] {
        var payload: [String : Any] = [:]
        payload[kSPEcommTotal] = String(format: "%.02f", totalValue)
        if let taxValue = taxValue {
            payload[kSPEcommTax] = String(format: "%.02f", taxValue.doubleValue)
        }
        if let shipping = shipping {
            payload[kSPEcommShipping] = String(format: "%.02f", shipping.doubleValue)
        }
        payload[kSPEcommId] = orderId
        payload[kSPEcommAffiliation] = affiliation
        payload[kSPEcommCity] = city
        payload[kSPEcommState] = state
        payload[kSPEcommCountry] = country
        payload[kSPEcommCurrency] = currency
        return payload
    }

    override func endProcessing(withTracker tracker: Tracker?) {
        for item in items {
            item.orderId = orderId
            _ = tracker?.track(item)
        }
    }
    
    // MARK: - Builders
    
    @objc
    public func affiliation(_ affiliation: String?) -> Self {
        self.affiliation = affiliation
        return self
    }
    
    /// Taxes applied to the purchase.
    @objc
    public func taxValue(_ taxValue: NSNumber?) -> Self {
        self.taxValue = taxValue
        return self
    }
    
    /// Shipping cost.
    @objc
    public func shipping(_ shipping: NSNumber?) -> Self {
        self.shipping = shipping
        return self
    }
    
    /// City for shipping.
    @objc
    public func city(_ city: String?) -> Self {
        self.city = city
        return self
    }
    
    /// State for shipping.
    @objc
    public func state(_ state: String?) -> Self {
        self.state = state
        return self
    }
    
    /// Country for shipping.
    @objc
    public func country(_ country: String?) -> Self {
        self.country = country
        return self
    }
    
    /// Currency used for totalValue and taxValue.
    @objc
    public func currency(_ currency: String?) -> Self {
        self.currency = currency
        return self
    }
}
