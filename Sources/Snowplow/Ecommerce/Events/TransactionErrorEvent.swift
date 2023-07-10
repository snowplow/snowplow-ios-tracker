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

@objc
public enum ErrorType : Int {
    case hard
    case soft
}

/// Track a transaction error event.
/// Entity schema: `iglu:com.snowplowanalytics.snowplow.ecommerce/transaction_error/jsonschema/1-0-0`
@objc(SPTransactionErrorEvent)
public class TransactionErrorEvent: SelfDescribingAbstract {
    /// The transaction object representing the transaction that ended up in an error.
    @objc
    var transaction: TransactionEntity
    
    /// Error-identifying code for the transaction issue, e.g. E522.
    @objc
    var errorCode: String?
    
    /// Shortcode for the error that occurred in the transaction e.g. declined_by_stock_api, declined_by_payment_method, card_declined, pm_card_radarBlock.
    @objc
    var errorShortcode: String?
    
    /// Longer description for the error that occurred in the transaction.
    @objc
    var errorDescription: String?
    
    /// Type of error. Hard error types mean the customer must provide another form of payment e.g. an expired card.
    /// Soft errors can be the result of temporary issues where retrying might be successful e.g. processor declined the transaction.
    var errorType: ErrorType?
    
    /// The resolution selected for the error scenario e.g. retry_allowed, user_blacklisted, block_gateway, contact_user, default.
    @objc
    var resolution: String?
    
    override var schema: String {
        return ecommerceActionSchema
    }
    
    override var payload: [String : Any] {
        let data: [String: Any] = ["type": "trns_error"]
        return data
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get {
            var entities = [SelfDescribingJson]()
            
            var data: [String : Any] = [:]
            
            if let errorCode = errorCode { data["error_code"] = errorCode }
            if let errorShortcode = errorShortcode { data["error_shortcode"] = errorShortcode }
            if let errorDescription = errorDescription { data["error_description"] = errorDescription }
            if let errorType = errorType {
                if (errorType == .hard) {
                    data["error_type"] = "hard"
                } else {
                    data["error_type"] = "soft"
                }
            }
            if let resolution = resolution { data["resolution"] = resolution }
            
            entities.append(SelfDescribingJson(schema: ecommerceTransactionErrorSchema, andData: data))
            entities.append(transaction.entity)

            return entities
        }
    }
    
    /// - Parameter transaction: The transaction object representing the transaction that ended up in an error.
    /// - Parameter errorCode: Error-identifying code for the transaction issue. E.g. E522
    /// - Parameter errorShortcode: Shortcode for the error that occurred in the transaction.
    /// - Parameter errorDescription: Longer description for the error that occurred in the transaction.
    /// - Parameter errorType: Type of error.
    /// - Parameter resolution: The resolution selected for the error scenario.
    public init(
        transaction: TransactionEntity,
        errorCode: String? = nil,
        errorShortcode: String? = nil,
        errorDescription: String? = nil,
        errorType: ErrorType? = nil,
        resolution: String? = nil
    ) {
        self.transaction = transaction
        self.errorCode = errorCode
        self.errorShortcode = errorShortcode
        self.errorDescription = errorDescription
        self.errorType = errorType
        self.resolution = resolution
    }
    
    /// - Parameter transaction: The transaction object representing the transaction that ended up in an error.
    /// - Parameter errorCode: Error-identifying code for the transaction issue. E.g. E522
    /// - Parameter errorShortcode: Shortcode for the error that occurred in the transaction.
    /// - Parameter errorDescription: Longer description for the error that occurred in the transaction.
    /// - Parameter resolution: The resolution selected for the error scenario.
    @objc
    public init(
        transaction: TransactionEntity,
        errorCode: String? = nil,
        errorShortcode: String? = nil,
        errorDescription: String? = nil,
        resolution: String? = nil
    ) {
        self.transaction = transaction
        self.errorCode = errorCode
        self.errorShortcode = errorShortcode
        self.errorDescription = errorDescription
        self.resolution = resolution
    }
    
    /// Type of error. Hard error types mean the customer must provide another form of payment e.g. an expired card.
    /// Soft errors can be the result of temporary issues where retrying might be successful e.g. processor declined the transaction.
    @objc
    public func errorType(_ errorType: ErrorType) -> Self {
        self.errorType = errorType
        return self
    }
}
