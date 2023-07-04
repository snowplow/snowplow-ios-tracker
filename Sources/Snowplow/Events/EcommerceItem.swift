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
@objc(SPEcommerceItem)
public class EcommerceItem : PrimitiveAbstract {
    /// Stock Keeping Unit of the item.
    @objc
    public var sku: String
    /// Price of the item.
    @objc
    public var price: Double
    /// Quantity of the item.
    @objc
    public var quantity: Int
    /// Name of the item.
    @objc
    public var name: String?
    /// Category of the item.
    @objc
    public var category: String?
    /// Currency used for the price of the item.
    @objc
    public var currency: String?
    /// OrderID of the order that contains this item.
    @objc
    public var orderId: String?

    @objc
    public init(sku: String, price: Double, quantity: Int) {
        self.sku = sku
        self.price = price
        self.quantity = quantity
    }

    override var eventName: String {
        return kSPEventEcommItem
    }

    override var payload: [String : Any] {
        var payload: [String : Any] = [:]
        payload[kSPEcommItemId] = orderId
        payload[kSPEcommItemSku] = sku
        payload[kSPEcommItemName] = name
        payload[kSPEcommItemCategory] = category
        payload[kSPEcommItemCurrency] = currency
        payload[kSPEcommItemPrice] = String(format: "%.02f", price)
        payload[kSPEcommItemQuantity] = String(format: "%ld", quantity)
        return payload
    }
    
    // MARK: - Builders
    
    /// Name of the item.
    @objc
    public func name(_ name: String?) -> Self {
        self.name = name
        return self
    }

    /// Category of the item.
    @objc
    public func category(_ category: String?) -> Self {
        self.category = category
        return self
    }
    
    /// Currency used for the price of the item.
    @objc
    public func currency(_ currency: String?) -> Self {
        self.currency = currency
        return self
    }
    
    /// OrderID of the order that contains this item.
    @objc
    public func orderId(_ orderId: String?) -> Self {
        self.orderId = orderId
        return self
    }
}
