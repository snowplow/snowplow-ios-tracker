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

/// Track a checkout step.
/// Entity schema: `iglu:com.snowplowanalytics.snowplow.ecommerce/checkout_step/jsonschema/1-0-0`
@objc(SPCheckoutStepEvent)
public class CheckoutStepEvent: SelfDescribingAbstract {
    /// Checkout step index.
    @objc
    public var step: Int
    
    /// Shipping address postcode.
    @objc
    public var shippingPostcode: String?
    
    /// Billing address postcode.
    @objc
    public var billingPostcode: String?
    
    /// Full shipping address.
    @objc
    public var shippingFullAddress: String?
    
    /// Full billing address.
    @objc
    public var billingFullAddress: String?
    
    /// Can be used to discern delivery providers DHL, PostNL etc.
    @objc
    public var deliveryProvider: String?
    
    /// E.g. store pickup, standard delivery, express delivery, international.
    @objc
    public var deliveryMethod: String?
    
    /// Coupon applied at checkout.
    @objc
    public var couponCode: String?
    
    /// Type of account used on checkout, e.g. existing user, guest.
    @objc
    public var accountType: String?
    
    /// Any kind of payment method the user selected to proceed. Card, PayPal, Alipay etc.
    @objc
    public var paymentMethod: String?
    
    /// E.g. invoice or receipt
    @objc
    public var proofOfPayment: String?
    
    /// If opted in to marketing campaigns to the email address.
    public var marketingOptIn: Bool?
    
    override var schema: String {
        return ecommerceActionSchema
    }
    
    override var payload: [String : Any] {
        let data: [String: Any] = ["type": "checkout_step"]
        return data
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get {
            var data: [String : Any] = ["step": step]
            
            if let shippingPostcode = shippingPostcode { data["shipping_postcode"] = shippingPostcode }
            if let billingPostcode = billingPostcode { data["billing_postcode"] = billingPostcode }
            if let shippingFullAddress = shippingFullAddress { data["shipping_full_address"] = shippingFullAddress }
            if let billingFullAddress = billingFullAddress { data["billing_full_address"] = billingFullAddress }
            if let deliveryProvider = deliveryProvider { data["delivery_provider"] = deliveryProvider }
            if let deliveryMethod = deliveryMethod { data["delivery_method"] = deliveryMethod }
            if let couponCode = couponCode { data["coupon_code"] = couponCode }
            if let accountType = accountType { data["account_type"] = accountType }
            if let paymentMethod = paymentMethod { data["payment_method"] = paymentMethod }
            if let proofOfPayment = proofOfPayment { data["proof_of_payment"] = proofOfPayment }
            if let marketingOptIn = marketingOptIn { data["marketing_opt_in"] = marketingOptIn }
            
            return [SelfDescribingJson(schema: ecommerceCheckoutStepSchema, andData: data)]
        }
    }
    
    /// - Parameter step: Checkout step index.
    /// - Parameter shippingPostcode: Shipping address postcode.
    /// - Parameter billingPostcode: Billing address postcode.
    /// - Parameter shippingFullAddress: Full shipping address.
    /// - Parameter billingFullAddress: Full billing address.
    /// - Parameter deliveryProvider: Can be used to discern delivery providers e.g. DHL, PostNL etc.
    /// - Parameter deliveryMethod: Store pickup, standard delivery, express delivery, international, etc.
    /// - Parameter couponCode: Coupon applied at checkout.
    /// - Parameter accountType: Type of account used on checkout, e.g. existing user, guest.
    /// - Parameter paymentMethod: Any kind of payment method the user selected to proceed. Card, PayPal, Alipay etc.
    /// - Parameter proofOfPayment: E.g. invoice or receipt.
    /// - Parameter marketingOptIn: If opted in to marketing campaigns to the email address.
    public init(
        step: Int,
        shippingPostcode: String? = nil,
        billingPostcode: String? = nil,
        shippingFullAddress: String? = nil,
        billingFullAddress: String? = nil,
        deliveryProvider: String? = nil,
        deliveryMethod: String? = nil,
        couponCode: String? = nil,
        accountType: String? = nil,
        paymentMethod: String? = nil,
        proofOfPayment: String? = nil,
        marketingOptIn: Bool? = nil
    ) {
        self.step = step
        self.shippingPostcode = shippingPostcode
        self.billingPostcode = billingPostcode
        self.shippingFullAddress = shippingFullAddress
        self.billingFullAddress = billingFullAddress
        self.deliveryProvider = deliveryProvider
        self.deliveryMethod = deliveryMethod
        self.couponCode = couponCode
        self.accountType = accountType
        self.paymentMethod = paymentMethod
        self.proofOfPayment = proofOfPayment
        self.marketingOptIn = marketingOptIn
    }
    
    /// - Parameter step: Checkout step index.
    /// - Parameter shippingPostcode: Shipping address postcode.
    /// - Parameter billingPostcode: Billing address postcode.
    /// - Parameter shippingFullAddress: Full shipping address.
    /// - Parameter billingFullAddress: Full billing address.
    /// - Parameter deliveryProvider: Can be used to discern delivery providers e.g. DHL, PostNL etc.
    /// - Parameter deliveryMethod: Store pickup, standard delivery, express delivery, international, etc.
    /// - Parameter couponCode: Coupon applied at checkout.
    /// - Parameter accountType: Type of account used on checkout, e.g. existing user, guest.
    /// - Parameter paymentMethod: Any kind of payment method the user selected to proceed. Card, PayPal, Alipay etc.
    /// - Parameter proofOfPayment: E.g. invoice or receipt.
    @objc
    public init(
        step: Int,
        shippingPostcode: String? = nil,
        billingPostcode: String? = nil,
        shippingFullAddress: String? = nil,
        billingFullAddress: String? = nil,
        deliveryProvider: String? = nil,
        deliveryMethod: String? = nil,
        couponCode: String? = nil,
        accountType: String? = nil,
        paymentMethod: String? = nil,
        proofOfPayment: String? = nil
    ) {
        self.step = step
        self.shippingPostcode = shippingPostcode
        self.billingPostcode = billingPostcode
        self.shippingFullAddress = shippingFullAddress
        self.billingFullAddress = billingFullAddress
        self.deliveryProvider = deliveryProvider
        self.deliveryMethod = deliveryMethod
        self.couponCode = couponCode
        self.accountType = accountType
        self.paymentMethod = paymentMethod
        self.proofOfPayment = proofOfPayment
    }
    
    /// If opted in to marketing campaigns to the email address.
    @objc
    public func marketingOptIn(_ marketingOptIn: Bool) -> Self {
        self.marketingOptIn = marketingOptIn
        return self
    }
}
