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

/** Track a product or products being added to cart. */
@objc(SPAddToCartEvent)
public class AddToCartEvent: SelfDescribingAbstract {
    /// List of product(s) that were added to the cart.
    @objc
    public var products: [ProductEntity]

    /// State of the cart after the addition.
    @objc
    public var cart: CartEntity
    
    override var schema: String {
        return ecommerceActionSchema
    }
    
    override var payload: [String : Any] {
        let data: [String: Any] = ["type": "add_to_cart"]
        return data
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get {
            var entities = [SelfDescribingJson]()
            for product in products {
                entities.append(product.entity)
            }
            entities.append(cart.entity)
            return entities
        }
    }
    
    /// - Parameter products: List of product(s) that were added to the cart.
    /// - Parameter cart: State of the cart after this addition.
    @objc
    public init(products: [ProductEntity], cart: CartEntity) {
        self.products = products
        self.cart = cart
    }
}
