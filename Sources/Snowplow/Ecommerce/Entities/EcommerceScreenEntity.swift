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
 Attach Ecommerce Screen (Page) details to events. It is designed to help with grouping insights by 
 screen/page type, e.g. Product description, Product list, Home.
 Entity schema: `iglu:com.snowplowanalytics.snowplow.ecommerce/page/jsonschema/1-0-0`
 */
@objc(SPEcommerceScreenEntity)
public class EcommerceScreenEntity: NSObject {
    /// The type of screen that was visited, e.g. homepage, product details, cart, checkout, etc.
    @objc
    public var type: String

    /// The language that the screen is based in.
    @objc
    public var language: String?

    /// The locale version of the app that is running.
    @objc
    public var locale: String?
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = ["type": type]
        if let language = language { data["language"] = language }
        if let locale = locale { data["locale"] = locale }
        
        return SelfDescribingJson(schema: ecommercePageSchema, andData: data)
    }
    
    /// - Parameter type: The type of screen that was visited, e.g. homepage, product details, cart, checkout, etc.
    /// - Parameter language: The language that the screen is based in.
    /// - Parameter locale: The locale version of the app that is running.
    @objc
    public init(
            type: String,
            language: String? = nil,
            locale: String? = nil
    ) {
        self.type = type
        self.language = language
        self.locale = locale
    }
}
