//
//  SPEcommerceItem.h
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

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPEcommTransactionItemBuilder
 @brief The protocol for building ecommerce transaction item events.
 */
NS_SWIFT_NAME(EcommTransactionItemBuilder)
@protocol SPEcommTransactionItemBuilder <SPEventBuilder>

/*!
 @brief Set the item ID.

 @param itemId ID of the eCommerce transaction.
 */
- (void) setItemId:(NSString *)itemId __deprecated_msg("Use initializer of `EcommerceItem` class instead.");

/*!
 @brief Set the Sku.

 @param sku Item SKU.
 */
- (void) setSku:(NSString *)sku __deprecated_msg("Use initializer of `EcommerceItem` class instead.");

/*!
 @brief Set the price.

 @param price Item price.
 */
- (void) setPrice:(double)price __deprecated_msg("Use initializer of `EcommerceItem` class instead.");

/*!
 @brief Set the quantity.

 @param quantity Item quantity.
 */
- (void) setQuantity:(NSInteger)quantity __deprecated_msg("Use initializer of `EcommerceItem` class instead.");

/*!
 @brief Set the name.

 @param name Item name.
 */
- (void) setName:(nullable NSString *)name __deprecated_msg("Use `name` of `EcommerceItem` class instead.");

/*!
 @brief Set the category.

 @param category Item category.
 */
- (void) setCategory:(nullable NSString *)category __deprecated_msg("Use `category` of `EcommerceItem` class instead.");

/*!
 @brief Set the currency.

 @param currency Transaction currency.
 */
- (void) setCurrency:(nullable NSString *)currency __deprecated_msg("Use `currency` of `EcommerceItem` class instead.");
@end

/*!
 @class SPEcommerceItem
 @brief An ecommerce item event.
 */
NS_SWIFT_NAME(EcommerceItem)
@interface SPEcommerceItem : SPPrimitiveAbstract <SPEcommTransactionItemBuilder>

@property (nonatomic, readonly) NSString *sku;
@property (nonatomic, readonly) NSNumber *price;
@property (nonatomic, readonly) NSNumber *quantity;
@property (nonatomic, nullable) NSString *name;
@property (nonatomic, nullable) NSString *category;
@property (nonatomic, nullable) NSString *currency;

+ (instancetype)build:(void(^)(id<SPEcommTransactionItemBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSku:(NSString *)sku price:(NSNumber *)price quantity:(NSNumber *)quantity NS_SWIFT_NAME(init(sku:price:quantity:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
SP_BUILDER_DECLARE_NULLABLE(NSString *, category)
SP_BUILDER_DECLARE_NULLABLE(NSString *, currency)

- (void)setOrderId:(NSString *)orderId;

@end

NS_ASSUME_NONNULL_END
