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

/** Track a promotion click or selection. */
@objc(SPPromotionClickEvent)
public class PromotionClickEvent: SelfDescribingAbstract {
    /// The promotion selected.
    @objc
    public var promotion: PromotionEntity
    
    override var schema: String {
        return ecommerceActionSchema
    }
    
    override var payload: [String : Any] {
        let data: [String: Any] = ["type": "promo_click"]
        return data
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get { [promotion.entity] }
    }
    
    /// - Parameter promotion: The promotion selected.
    @objc
    public init(promotion: PromotionEntity) {
        self.promotion = promotion
    }
}
