//
//  SPEcommerceItem.h
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
@protocol SPEcommTransactionItemBuilder <SPEventBuilder>

/*!
 @brief Set the item ID.

 @param itemId ID of the eCommerce transaction.
 */
- (void) setItemId:(NSString *)itemId;

/*!
 @brief Set the Sku.

 @param sku Item SKU.
 */
- (void) setSku:(NSString *)sku;

/*!
 @brief Set the price.

 @param price Item price.
 */
- (void) setPrice:(double)price;

/*!
 @brief Set the quantity.

 @param quantity Item quantity.
 */
- (void) setQuantity:(NSInteger)quantity;

/*!
 @brief Set the name.

 @param name Item name.
 */
- (void) setName:(nullable NSString *)name;

/*!
 @brief Set the category.

 @param category Item category.
 */
- (void) setCategory:(nullable NSString *)category;

/*!
 @brief Set the currency.

 @param currency Transaction currency.
 */
- (void) setCurrency:(nullable NSString *)currency;
@end

/*!
 @class SPEcommerceItem
 @brief An ecommerce item event.
 */
@interface SPEcommerceItem : SPPrimitive <SPEcommTransactionItemBuilder>
+ (instancetype) build:(void(^)(id<SPEcommTransactionItemBuilder>builder))buildBlock;
- (SPPayload *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
