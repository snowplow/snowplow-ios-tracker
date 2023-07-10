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

/**
 Provided to certain Ecommerce events. The Product properties will be sent with the event as a Product entity.
 Entity schema: `iglu:com.snowplowanalytics.snowplow.ecommerce/product/jsonschema/1-0-0`
 */
@objc(SPProductEntity)
public class ProductEntity: NSObject {
    /// The SKU or product ID.
    @objc
    public var id: String

    /// The category the product belongs to. Use a consistent separator to express multiple levels. E.g. Woman/Shoes/Sneakers.
    @objc
    public var category: String

    /// The currency in which the product is being priced (ISO 4217).
    @objc
    public var currency: String

    /// The price of the product at the current time.
    @objc
    public var price: Decimal

    /// The recommended or list price of a product.
    public var listPrice: Decimal?

    /// The name or title of the product.
    @objc
    public var name: String?

    /// The quantity of the product taking part in the action. Used for Cart events.
    public var quantity: Int?

    /// The size of the product.
    @objc
    public var size: String?

    /// The variant of the product.
    @objc
    public var variant: String?

    /// The brand of the product.
    @objc
    public var brand: String?

    /// The inventory status of the product (e.g. in stock, out of stock, preorder, backorder, etc).
    @objc
    public var inventoryStatus: String?

    /// The position the product was presented in a list of products (search results, product list page, etc).
    public var position: Int?

    /// Identifier, name, or url for the creative presented on the associated promotion.
    @objc
    public var creativeId: String?
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "id": id,
            "category": category,
            "currency": currency,
            "price": price
        ]
        if let listPrice = listPrice { data["list_price"] = listPrice }
        if let name = name { data["name"] = name }
        if let quantity = quantity { data["quantity"] = quantity }
        if let size = size { data["size"] = size }
        if let variant = variant { data["variant"] = variant }
        if let brand = brand { data["brand"] = brand }
        if let inventoryStatus = inventoryStatus { data["inventory_status"] = inventoryStatus }
        if let position = position { data["position"] = position }
        if let creativeId = creativeId { data["creative_id"] = creativeId }
        
        return SelfDescribingJson(schema: ecommerceProductSchema, andData: data)
    }
    
    /// - Parameter id: The SKU or product ID.
    /// - Parameter category: The category the product belongs to. Use a consistent separator to express multiple levels. E.g. Woman/Shoes/Sneakers.
    /// - Parameter currency: The currency in which the product is being priced (ISO 4217).
    /// - Parameter price: The price of the product at the current time.
    /// - Parameter listPrice: The recommended or list price of a product.
    /// - Parameter name: The name or title of the product.
    /// - Parameter quantity: The quantity of the product taking part in the action. Used for Cart events.
    /// - Parameter size: The size of the product.
    /// - Parameter variant: The variant of the product.
    /// - Parameter brand: The brand of the product.
    /// - Parameter inventoryStatus: The inventory status of the product (e.g. in stock, out of stock, preorder, backorder, etc).
    /// - Parameter position: The position the product was presented in a list of products (search results, product list page, etc).
    /// - Parameter creativeId: Identifier, name, or url for the creative presented on the associated promotion.
    public init(
                id: String,
                category: String,
                currency: String,
                price: Decimal,
                listPrice: Decimal? = nil,
                name: String? = nil,
                quantity: Int? = nil,
                size: String? = nil,
                variant: String? = nil,
                brand: String? = nil,
                inventoryStatus: String? = nil,
                position: Int? = nil,
                creativeId: String? = nil) {
        self.id = id
        self.category = category
        self.currency = currency
        self.price = price
        self.listPrice = listPrice
        self.name = name
        self.quantity = quantity
        self.size = size
        self.variant = variant
        self.brand = brand
        self.inventoryStatus = inventoryStatus
        self.position = position
        self.creativeId = creativeId
    }
    
    /// - Parameter id: The SKU or product ID.
    /// - Parameter category: The category the product belongs to. Use a consistent separator to express multiple levels. E.g. Woman/Shoes/Sneakers.
    /// - Parameter currency: The currency in which the product is being priced (ISO 4217).
    /// - Parameter price: The price of the product at the current time.
    /// - Parameter name: The name or title of the product.
    /// - Parameter size: The size of the product.
    /// - Parameter variant: The variant of the product.
    /// - Parameter brand: The brand of the product.
    /// - Parameter inventoryStatus: The inventory status of the product (e.g. in stock, out of stock, preorder, backorder, etc).
    /// - Parameter creativeId: Identifier, name, or url for the creative presented on the associated promotion.
    @objc
    public init(
                id: String,
                category: String,
                currency: String,
                price: Decimal,
                name: String? = nil,
                size: String? = nil,
                variant: String? = nil,
                brand: String? = nil,
                inventoryStatus: String? = nil,
                creativeId: String? = nil) {
        self.id = id
        self.category = category
        self.currency = currency
        self.price = price
        self.name = name
        self.size = size
        self.variant = variant
        self.brand = brand
        self.inventoryStatus = inventoryStatus
        self.creativeId = creativeId
    }
    
    /// The recommended or list price of a product.
    @objc
    public func listPrice(_ listPrice: Decimal) -> Self {
        self.listPrice = listPrice
        return self
    }
    
    /// The quantity of the product taking part in the action. Used for Cart events.
    @objc
    public func quantity(_ quantity: Int) -> Self {
        self.quantity = quantity
        return self
    }
    
    /// The position the product was presented in a list of products (search results, product list page, etc).
    @objc
    public func position(_ position: Int) -> Self {
        self.position = position
        return self
    }
}
