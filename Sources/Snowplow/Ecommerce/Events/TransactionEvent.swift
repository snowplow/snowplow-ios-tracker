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

/// Track a transaction event.
/// Entity schema: `iglu:com.snowplowanalytics.snowplow.ecommerce/transaction/jsonschema/1-0-0`
@objc(SPEcommTransactionEvent)
public class TransactionEvent: SelfDescribingAbstract {
    /// The ID of the transaction.
    @objc
    public var transactionId: String
    
    /// The total value of the transaction.
    @objc
    public var revenue: Double
    
    /// The currency used for the transaction (ISO 4217).
    @objc
    public var currency: String
    
    /// The payment method used for the transaction.
    @objc
    public var paymentMethod: String
    
    /// Total quantity of items in the transaction.
    @objc
    public var totalQuantity: Int
    
    /// Total amount of tax on the transaction.
    public var tax: Double?
    
    /// Total cost of shipping on the transaction.
    public var shipping: Double?
    
    /// Discount code used.
    @objc
    public var discountCode: String?
    
    /// Discount amount taken off.
    public var discountAmount: Double?
    
    /// Whether the transaction is a credit order or not.
    public var creditOrder: Bool?
    
    /// Products in the transaction.
    @objc
    public var products: [ProductEntity]?
    
    override var schema: String {
        return ecommerceActionSchema
    }
    
    override var payload: [String : Any] {
        let data: [String: Any] = ["type": "transaction"]
        return data
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get {
            var entities = [SelfDescribingJson]()
            
            var data: [String : Any] = [
                "transaction_id": transactionId,
                "revenue": revenue,
                "currency": currency,
                "payment_method": paymentMethod,
                "total_quantity": totalQuantity
            ]
            if let tax = tax { data["tax"] = tax }
            if let shipping = shipping { data["shipping"] = shipping }
            if let discountCode = discountCode { data["discount_code"] = discountCode }
            if let discountAmount = discountAmount { data["discount_amount"] = discountAmount }
            if let creditOrder = creditOrder { data["credit_order"] = creditOrder }
            let transactionEntity = SelfDescribingJson(schema: ecommerceTransactionSchema, andData: data)
            
            entities.append(transactionEntity)
            if let products = products {
                for product in products {
                    entities.append(product.entity)
                }
            }

            return entities
        }
    }
    
    /// - Parameter transactionId The ID of the transaction.
    /// - Parameter revenue The total value of the transaction.
    /// - Parameter currency The currency used (ISO 4217).
    /// - Parameter paymentMethod The payment method used.
    /// - Parameter totalQuantity Total quantity of items in the transaction.
    /// - Parameter tax Total amount of tax on the transaction.
    /// - Parameter shipping Total cost of shipping on the transaction.
    /// - Parameter discountCode Discount code used.
    /// - Parameter discountAmount Discount amount taken off.
    /// - Parameter creditOrder Whether it is a credit order or not.
    /// - Parameter products The product(s) included in the transaction.
    public init(
        transactionId: String,
        revenue: Double,
        currency: String,
        paymentMethod: String,
        totalQuantity: Int,
        tax: Double? = nil,
        shipping: Double? = nil,
        discountCode: String? = nil,
        discountAmount: Double? = nil,
        creditOrder: Bool? = nil,
        products: [ProductEntity]? = nil
    ) {
        self.transactionId = transactionId
        self.revenue = revenue
        self.currency = currency
        self.paymentMethod = paymentMethod
        self.totalQuantity = totalQuantity
        self.tax = tax
        self.shipping = shipping
        self.discountCode = discountCode
        self.discountAmount = discountAmount
        self.creditOrder = creditOrder
        self.products = products
    }
    
    /// Total amount of tax on the transaction.
    @objc
    public func tax(_ tax: Double) -> Self {
        self.tax = tax
        return self
    }
    
    /// Total cost of shipping on the transaction.
    @objc
    public func shipping(_ shipping: Double) -> Self {
        self.shipping = shipping
        return self
    }
    
    /// Discount amount taken off.
    @objc
    public func discountAmount(_ discountAmount: Double) -> Self {
        self.discountAmount = discountAmount
        return self
    }
    
    /// Whether the transaction is a credit order or not.
    @objc
    public func creditOrder(_ creditOrder: Bool) -> Self {
        self.creditOrder = creditOrder
        return self
    }
}
