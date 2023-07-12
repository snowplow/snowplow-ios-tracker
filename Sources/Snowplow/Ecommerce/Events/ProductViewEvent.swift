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

/** Track a product view/detail. */
@objc(SPProductViewEvent)
public class ProductViewEvent: SelfDescribingAbstract {
    /// The product that was viewed in a product detail page.
    @objc
    public var product: ProductEntity
    
    override var schema: String {
        return ecommerceActionSchema
    }
    
    override var payload: [String : Any] {
        let data: [String: Any] = ["type": "product_view"]
        return data
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get { [product.entity] }
    }
    
    /// - Parameter product: The product that was viewed in a product detail page.
    @objc
    public init(product: ProductEntity) {
        self.product = product
    }
}
