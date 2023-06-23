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
 Provided to certain Ecommerce events. The Promotion properties will be sent with the event as a Promotion entity.
 Entity schema: `iglu:com.snowplowanalytics.snowplow.ecommerce/promotion/jsonschema/1-0-0`
 */
@objc(SPPromotionEntity)
public class PromotionEntity: NSObject {
    /// The ID of the promotion.
    public var id: String

    /// The name of the promotion.
    public var name: String?

    /// List of SKUs or product IDs showcased in the promotion.
    public var productIds: [String]?

    /// The position the promotion was presented in a list of promotions such as a banner or slider, e.g. 2.
    public var position: Int?

    /// Identifier, name, or url for the creative presented on the promotion.
    public var creativeId: String?

    /// Type of the promotion delivery mechanism. E.g. popup, banner, intra-content.
    public var type: String?

    /// The UI slot in which the promotional content was added to.
    public var slot: String?
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "id": id
        ]
        if let name = name { data["name"] = name }
        if let productIds = productIds { data["product_ids"] = productIds }
        if let position = position { data["position"] = position }
        if let creativeId = creativeId { data["creative_id"] = creativeId }
        if let type = type { data["type"] = type }
        if let slot = slot { data["slot"] = slot }
        
        return SelfDescribingJson(schema: ecommercePromotionSchema, andData: data)
    }
    
    /// - Parameter id: The ID of the promotion.
    /// - Parameter name: The name of the promotion.
    /// - Parameter productIds: List of SKUs or product IDs showcased in the promotion.
    /// - Parameter position: The position the promotion was presented in a list of promotions such as a banner or slider, e.g. 2.
    /// - Parameter creativeId: Identifier, name, or url for the creative presented on the promotion.
    /// - Parameter type: Type of the promotion delivery mechanism. E.g. popup, banner, intra-content.
    /// - Parameter slot: The UI slot in which the promotional content was added to.
    public init(
                id: String,
                name: String?,
                productIds: [String]?,
                position: Int?,
                creativeId: String? = nil,
                type: String? = nil,
                slot: String? = nil) {
        self.id = id
        self.name = name
        self.productIds = productIds
        self.position = position
        self.creativeId = creativeId
        self.type = type
        self.slot = slot
    }
}
