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
 Provided to certain Ecommerce events. The Cart properties will be sent with the event as a Cart entity.
 Entity schema: `iglu:com.snowplowanalytics.snowplow.ecommerce/cart/jsonschema/1-0-0`
 */
@objc(SPCartEntity)
public class CartEntity: NSObject {
    /// The total value of the cart after this interaction.
    @objc
    public var totalValue: Decimal

    /// The currency used for this cart (ISO 4217).
    @objc
    public var currency: String

    /// The unique ID representing this cart.
    @objc
    public var cartId: String?
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "total_value": totalValue,
            "currency": currency
        ]
        if let cartId = cartId { data["cart_id"] = cartId }
        
        return SelfDescribingJson(schema: ecommerceCartSchema, andData: data)
    }
    
    /// - Parameter totalValue: The total value of the cart after this interaction.
    /// - Parameter currency: The currency used for this cart (ISO 4217).
    /// - Parameter cartId: The unique ID representing this cart.
    @objc
    public init(
            totalValue: Decimal,
            currency: String,
            cartId: String? = nil) {
        self.totalValue = totalValue
        self.currency = currency
        self.cartId = cartId
    }
}
