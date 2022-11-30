//
//  EcommerceItem.swift
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

    @objc
    override public var eventName: String {
        return kSPEventEcommItem
    }

    override public var payload: [String : NSObject] {
        var payload: [String : NSObject] = [:]
        payload[kSPEcommItemId] = orderId as NSObject?
        payload[kSPEcommItemSku] = sku as NSObject
        payload[kSPEcommItemName] = name as NSObject?
        payload[kSPEcommItemCategory] = category as NSObject?
        payload[kSPEcommItemCurrency] = currency as NSObject?
        payload[kSPEcommItemPrice] = String(format: "%.02f", price) as NSObject
        payload[kSPEcommItemQuantity] = String(format: "%ld", quantity) as NSObject
        return payload
    }
}
