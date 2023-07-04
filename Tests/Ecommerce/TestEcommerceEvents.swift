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

import XCTest
@testable import SnowplowTracker

class TestEcommerceEvents: XCTestCase {
    func testAddToCart() {
        let cart = CartEntity(totalValue: 500, currency: "GBP")
        
        let event = AddToCartEvent(products: [product1, product2], cart: cart)
        let entities = event.entitiesForProcessing
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("add_to_cart", event.payload["type"] as? String)
        XCTAssertEqual(3, entities?.count)
        XCTAssertEqual(2, getProductEntities(entities).count)
        XCTAssertEqual(1, getCartEntities(entities).count)
    }
    
    func testRemoveFromCart() {
        let cart = CartEntity(totalValue: 500, currency: "GBP")
        
        let event = RemoveFromCartEvent(products: [product1], cart: cart)
        let entities = event.entitiesForProcessing
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("remove_from_cart", event.payload["type"] as? String)
        XCTAssertEqual(2, entities?.count)
        XCTAssertEqual(1, getProductEntities(entities).count)
        XCTAssertEqual(1, getCartEntities(entities).count)
    }
    
    func testProductListClick() {
        let event = ProductListClickEvent(product: product1, name: "list_name")
        let entities = event.entitiesForProcessing
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("list_click", event.payload["type"] as? String)
        XCTAssertEqual("list_name", event.payload["name"] as? String)
        XCTAssertEqual(1, entities?.count)
        XCTAssertEqual(1, getProductEntities(entities).count)
    }
    
    func testProductListView() {
        let event = ProductListViewEvent(products: [product1, product2], name: "list_name")
        let entities = event.entitiesForProcessing
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("list_view", event.payload["type"] as? String)
        XCTAssertEqual("list_name", event.payload["name"] as? String)
        XCTAssertEqual(2, entities?.count)
        XCTAssertEqual(2, getProductEntities(entities).count)
    }
    
    func testProductView() {
        let event = ProductViewEvent(product: product1)
        let entities = event.entitiesForProcessing
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("product_view", event.payload["type"] as? String)
        XCTAssertEqual(1, entities?.count)
        XCTAssertEqual(1, getProductEntities(entities).count)
    }
    
    func testCheckoutStep() {
        let event = CheckoutStepEvent(
            step: 5,
            shippingPostcode: "postcode1",
            billingPostcode: "postcode2",
            shippingFullAddress: "address1",
            billingFullAddress: "address2",
            deliveryProvider: "provider",
            deliveryMethod: "delivery_method",
            couponCode: "coupon",
            accountType: "account",
            paymentMethod: "payment_method",
            proofOfPayment: "proof",
            marketingOptIn: false
        )
        let entities = event.entitiesForProcessing
        let checkoutEntities = getCheckoutStepEntities(entities)
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("checkout_step", event.payload["type"] as? String)
        XCTAssertEqual(1, entities?.count)
        XCTAssertEqual(1, checkoutEntities.count)
        
        let entity = checkoutEntities[0]
        
        XCTAssertEqual(5, entity.data["step"] as? Int)
        XCTAssertEqual("postcode1", entity.data["shipping_postcode"] as? String)
        XCTAssertEqual("postcode2", entity.data["billing_postcode"] as? String)
        XCTAssertEqual("address1", entity.data["shipping_full_address"] as? String)
        XCTAssertEqual("address2", entity.data["billing_full_address"] as? String)
        XCTAssertEqual("provider", entity.data["delivery_provider"] as? String)
        XCTAssertEqual("delivery_method", entity.data["delivery_method"] as? String)
        XCTAssertEqual("coupon", entity.data["coupon_code"] as? String)
        XCTAssertEqual("account", entity.data["account_type"] as? String)
        XCTAssertEqual("payment_method", entity.data["payment_method"] as? String)
        XCTAssertEqual("proof", entity.data["proof_of_payment"] as? String)
        XCTAssertEqual(false, entity.data["marketing_opt_in"] as? Bool)
    }
    
    func testTransaction() {
        let event = TransactionEvent(
            transactionId: "id",
            revenue: 55.55,
            currency: "CAD",
            paymentMethod: "cash",
            totalQuantity: 2,
            tax: 11.11,
            shipping: 0,
            discountCode: "new",
            discountAmount: 0.5,
            creditOrder: false,
            products: [product1, product2]
        )
        let entities = event.entitiesForProcessing
        let transactionEntities = getTransactionEntities(entities)
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("transaction", event.payload["type"] as? String)
        XCTAssertEqual(3, entities?.count)
        XCTAssertEqual(1, transactionEntities.count)
        XCTAssertEqual(2, getProductEntities(entities).count)
        
        let entity = transactionEntities[0]
        
        XCTAssertEqual("id", entity.data["transaction_id"] as? String)
        XCTAssertEqual(55.55, entity.data["revenue"] as? Double)
        XCTAssertEqual("CAD", entity.data["currency"] as? String)
        XCTAssertEqual("cash", entity.data["payment_method"] as? String)
        XCTAssertEqual(2, entity.data["total_quantity"] as? Int)
        XCTAssertEqual(11.11, entity.data["tax"] as? Double)
        XCTAssertEqual(0, entity.data["shipping"] as? Double)
        XCTAssertEqual("new", entity.data["discount_code"] as? String)
        XCTAssertEqual(0.5, entity.data["discount_amount"] as? Double)
        XCTAssertEqual(false, entity.data["credit_order"] as? Bool)
    }
    
    func testRefund() {
        let event = RefundEvent(
            transactionId: "id",
            refundAmount: 300,
            currency: "INR",
            refundReason: "reason",
            products: [product1]
        )
        let entities = event.entitiesForProcessing
        let refundEntities = getRefundEntities(entities)
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("refund", event.payload["type"] as? String)
        XCTAssertEqual(2, entities?.count)
        XCTAssertEqual(1, refundEntities.count)
        XCTAssertEqual(1, getProductEntities(entities).count)
        
        let entity = refundEntities[0]

        XCTAssertEqual("id", entity.data["transaction_id"] as? String)
        XCTAssertEqual("INR", entity.data["currency"] as? String)
        XCTAssertEqual(300, entity.data["refund_amount"] as? Double)
        XCTAssertEqual("reason", entity.data["refund_reason"] as? String)
    }
    
    func testPromotionClick() {
        let event = PromotionClickEvent(promotion: PromotionEntity(id: "promo"))
        let entities = event.entitiesForProcessing
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("promo_click", event.payload["type"] as? String)
        XCTAssertEqual(1, entities?.count)
        XCTAssertEqual(1, getPromotionEntities(entities).count)
    }
    
    func testPromotionView() {
        let event = PromotionViewEvent(promotion: PromotionEntity(id: "promo"))
        let entities = event.entitiesForProcessing
        
        XCTAssertEqual(ecommerceActionSchema, event.schema)
        XCTAssertEqual("promo_view", event.payload["type"] as? String)
        XCTAssertEqual(1, entities?.count)
        XCTAssertEqual(1, getPromotionEntities(entities).count)
    }
    
    private let product1 = ProductEntity(
        id: "id1",
        category: "category1",
        currency: "GBP",
        price: 1.23
    )
    
    let product2 = ProductEntity(
        id: "id2",
        category: "category2",
        currency: "GBP",
        price: 0.99
    )
    
    private func getProductEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == ecommerceProductSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
    
    private func getCartEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == ecommerceCartSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
    
    private func getPromotionEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == ecommercePromotionSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
    
    private func getCheckoutStepEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == ecommerceCheckoutStepSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
    
    private func getTransactionEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == ecommerceTransactionSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
    
    private func getRefundEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == ecommerceRefundSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
}
