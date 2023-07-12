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

/** Track a product list click or selection event. */
@objc(SPProductListClickEvent)
public class ProductListClickEvent: SelfDescribingAbstract {
    /// Information about the product that was selected.
    @objc
    public var product: ProductEntity
    
    /// The list name.
    @objc
    public var name: String?
    
    override var schema: String {
        return ecommerceActionSchema
    }
    
    override var payload: [String : Any] {
        var data: [String: Any] = ["type": "list_click"]
        if let name = name { data["name"] = name }
        return data
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get { [product.entity] }
    }
    
    /// - Parameter promotion: Information about the product that was selected.
    /// - Parameter name: The list name.
    @objc
    public init(product: ProductEntity, name: String? = nil) {
        self.product = product
        self.name = name
    }
}
