//
//  SPEcommerce.h
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Alex Benini
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPEventBase.h"
#import "SPEcommerceItem.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPEcommTransactionBuilder
 @brief The protocol for building ecommerce transaction events.
 */
NS_SWIFT_NAME(EcommTransactionBuilder)
@protocol SPEcommTransactionBuilder <SPEventBuilder>

/*!
 @brief Set the order ID.

 @param orderId ID of the eCommerce transaction.
 */
- (void) setOrderId:(NSString *)orderId __deprecated_msg("Use initializer of `Ecommerce` class instead.");

/*!
 @brief Set the total value.

 @param totalValue Total transaction value.
 */
- (void) setTotalValue:(NSNumber *)totalValue __deprecated_msg("Use initializer of `Ecommerce` class instead.");

/*!
 @brief Set the affiliation.

 @param affiliation Transaction affiliation.
 */
- (void) setAffiliation:(nullable NSString *)affiliation __deprecated_msg("Use `affiliation` of `Ecommerce` class instead.");

/*!
 @brief Set the tax value.

 @param taxValue Transaction tax value.
 */
- (void) setTaxValue:(NSNumber *)taxValue __deprecated_msg("Use `taxValue` of `Ecommerce` class instead.");

/*!
 @brief Set the shipping.

 @param shipping Delivery cost charged.
 */
- (void) setShipping:(NSNumber *)shipping __deprecated_msg("Use `shipping` of `Ecommerce` class instead.");

/*!
 @brief Set the city.

 @param city Delivery address city.
 */
- (void) setCity:(nullable NSString *)city __deprecated_msg("Use `city` of `Ecommerce` class instead.");

/*!
 @brief Set the state.

 @param state Delivery address state.
 */
- (void) setState:(nullable NSString *)state __deprecated_msg("Use `state` of `Ecommerce` class instead.");

/*!
 @brief Set the country.

 @param country Delivery address country.
 */
- (void) setCountry:(nullable NSString *)country __deprecated_msg("Use `country` of `Ecommerce` class instead.");

/*!
 @brief Set the currency.

 @param currency Transaction currency.
 */
- (void) setCurrency:(nullable NSString *)currency __deprecated_msg("Use `currency` of `Ecommerce` class instead.");

/*!
 @brief Set the items.

 @param items An array of items in the transaction.
 */
- (void) setItems:(NSArray *)items __deprecated_msg("Use initializer of `Ecommerce` class instead.");
@end

/*!
 @class SPEcommerce
 @brief An ecommerce event.
 */
NS_SWIFT_NAME(Ecommerce)
@interface SPEcommerce : SPPrimitiveAbstract <SPEcommTransactionBuilder>

@property (nonatomic, readonly) NSString *orderId;
@property (nonatomic, readonly) NSNumber *totalValue;
@property (nonatomic, readonly) NSArray<SPEcommerceItem *> *items;
@property (nonatomic, nullable) NSString *affiliation;
@property (nonatomic, nullable) NSNumber *taxValue;
@property (nonatomic, nullable) NSNumber *shipping;
@property (nonatomic, nullable) NSString *city;
@property (nonatomic, nullable) NSString *state;
@property (nonatomic, nullable) NSString *country;
@property (nonatomic, nullable) NSString *currency;

+ (instancetype)build:(void(^)(id<SPEcommTransactionBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithOrderId:(NSString *)orderId totalValue:(NSNumber *)totalValue items:(NSArray<SPEcommerceItem *> *)items NS_SWIFT_NAME(init(orderId:totalValue:items:));

- (NSArray *) getItems;

SP_BUILDER_DECLARE_NULLABLE(NSString *, affiliation)
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, taxValue)
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, shipping)
SP_BUILDER_DECLARE_NULLABLE(NSString *, city)
SP_BUILDER_DECLARE_NULLABLE(NSString *, state)
SP_BUILDER_DECLARE_NULLABLE(NSString *, country)
SP_BUILDER_DECLARE_NULLABLE(NSString *, currency)

@end

NS_ASSUME_NONNULL_END
