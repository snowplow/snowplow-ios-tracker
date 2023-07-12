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
 Provided to certain Ecommerce events. The Transaction properties will be sent with the event as a Transaction entity.
 Entity schema: `iglu:com.snowplowanalytics.snowplow.ecommerce/transaction/jsonschema/1-0-0`
 */
@objc(SPTransactionEntity)
public class TransactionEntity: NSObject {
    /// The ID of the transaction.
    @objc
    public var transactionId: String
    
    /// The total value of the transaction.
    @objc
    public var revenue: Decimal
    
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
    public var tax: Decimal?
    
    /// Total cost of shipping on the transaction.
    public var shipping: Decimal?
    
    /// Discount code used.
    @objc
    public var discountCode: String?
    
    /// Discount amount taken off.
    public var discountAmount: Decimal?
    
    /// Whether the transaction is a credit order or not.
    public var creditOrder: Bool?
    
    internal var entity: SelfDescribingJson {
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
        
        return SelfDescribingJson(schema: ecommerceTransactionSchema, andData: data)
    }
    
    /// - Parameter transactionId: The ID of the transaction.
    /// - Parameter revenue: The total value of the transaction.
    /// - Parameter currency: The currency used (ISO 4217).
    /// - Parameter paymentMethod: The payment method used.
    /// - Parameter totalQuantity: Total quantity of items in the transaction.
    /// - Parameter tax: Total amount of tax on the transaction.
    /// - Parameter shipping: Total cost of shipping on the transaction.
    /// - Parameter discountCode: Discount code used.
    /// - Parameter discountAmount: Discount amount taken off.
    /// - Parameter creditOrder: Whether it is a credit order or not.
    public init(
        transactionId: String,
        revenue: Decimal,
        currency: String,
        paymentMethod: String,
        totalQuantity: Int,
        tax: Decimal? = nil,
        shipping: Decimal? = nil,
        discountCode: String? = nil,
        discountAmount: Decimal? = nil,
        creditOrder: Bool? = nil
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
    }
    
    /// - Parameter transactionId: The ID of the transaction.
    /// - Parameter revenue: The total value of the transaction.
    /// - Parameter currency: The currency used (ISO 4217).
    /// - Parameter paymentMethod: The payment method used.
    /// - Parameter totalQuantity: Total quantity of items in the transaction.
    /// - Parameter discountCode: Discount code used.
    @objc
    public init(
        transactionId: String,
        revenue: Decimal,
        currency: String,
        paymentMethod: String,
        totalQuantity: Int,
        discountCode: String? = nil
    ) {
        self.transactionId = transactionId
        self.revenue = revenue
        self.currency = currency
        self.paymentMethod = paymentMethod
        self.totalQuantity = totalQuantity
        self.discountCode = discountCode
    }
    
    /// Total amount of tax on the transaction.
    @objc
    public func tax(_ tax: Decimal) -> Self {
        self.tax = tax
        return self
    }
    
    /// Total cost of shipping on the transaction.
    @objc
    public func shipping(_ shipping: Decimal) -> Self {
        self.shipping = shipping
        return self
    }
    
    /// Discount amount taken off.
    @objc
    public func discountAmount(_ discountAmount: Decimal) -> Self {
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
