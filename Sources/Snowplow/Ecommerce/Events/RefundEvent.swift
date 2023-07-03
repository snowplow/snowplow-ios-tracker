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
 Track a refund event. Use the same transaction ID as for the original Transaction event.
 Provide a list of products to specify certain products to be refunded, otherwise the whole transaction
 will be marked as refunded.
 */
@objc(SPEcommRefundEvent)
public class RefundEvent: SelfDescribingAbstract {
    /// The ID of the relevant transaction.
    @objc
    public var transactionId: String
    
    /// The monetary amount refunded.
    @objc
    public var refundAmount: Double

    /// The currency in which the product is being priced (ISO 4217).
    @objc
    public var currency: String
    
    /// Reason for refunding the whole or part of the transaction.
    @objc
    public var refundReason: String?
    
    /// Products in the transaction.
    @objc
    public var products: [ProductEntity]?
    
    override var schema: String {
        return ecommerceActionSchema
    }
    
    override var payload: [String : Any] {
        var data: [String: Any] = ["type": "refund"]
        return data
    }
    
    override public var entitiesForProcessing: [SelfDescribingJson]? {
        get {
            var entities = [SelfDescribingJson]()
            
            var data: [String : Any] = [
                "transaction_id": transactionId,
                "refund_amount": refundAmount,
                "currency": currency
            ]
            if let refundReason = refundReason { data["refund_reason"] = refundReason }
            let refundEntity = SelfDescribingJson(schema: ecommerceRefundSchema, andData: data)
            
            entities.append(refundEntity)
            if let products = products {
                for product in products {
                    entities.append(product.entity)
                }
            }

            return entities
        }
    }
    
    /// - Parameter transactionId The ID of the relevant transaction.
    /// - Parameter currency The currency in which the product(s) are being priced (ISO 4217).
    /// - Parameter refundAmount The monetary amount refunded.
    /// - Parameter refundReason Reason for refunding the whole or part of the transaction.
    /// - Parameter products The products to be refunded.
    @objc
    public init(
        transactionId: String,
        refundAmount: Double,
        currency: String,
        refundReason: String? = nil,
        products: [ProductEntity]? = nil
    ) {
        self.transactionId = transactionId
        self.refundAmount = refundAmount
        self.currency = currency
        self.refundReason = refundReason
        self.products = products
    }
}
