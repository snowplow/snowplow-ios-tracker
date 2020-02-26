//
//  SPEcommerceItem.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

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
- (void) setName:(NSString *)name;

/*!
 @brief Set the category.

 @param category Item category.
 */
- (void) setCategory:(NSString *)category;

/*!
 @brief Set the currency.

 @param currency Transaction currency.
 */
- (void) setCurrency:(NSString *)currency;
@end

/*!
 @class SPEcommerceItem
 @brief An ecommerce item event.
 */
@interface SPEcommerceItem : SPEvent <SPEcommTransactionItemBuilder>
+ (instancetype) build:(void(^)(id<SPEcommTransactionItemBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
@end

NS_ASSUME_NONNULL_END
