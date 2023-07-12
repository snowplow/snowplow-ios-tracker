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
@objc(SPTransactionEvent)
public class TransactionEvent: SelfDescribingAbstract {
    /// The transaction involved.
    @objc
    public var transaction: TransactionEntity
    
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
            
            entities.append(transaction.entity)
            if let products = products {
                for product in products {
                    entities.append(product.entity)
                }
            }
            return entities
        }
    }
    
    /// - Parameter transaction: The transaction details.
    /// - Parameter products: The product(s) included in the transaction.
    @objc
    public init(transaction: TransactionEntity, products: [ProductEntity]? = nil) {
        self.transaction = transaction
        self.products = products
    }
}
