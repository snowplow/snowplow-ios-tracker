//
//  SPEcommerce.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPEcommTransactionBuilder
 @brief The protocol for building ecommerce transaction events.
 */
@protocol SPEcommTransactionBuilder <SPEventBuilder>

/*!
 @brief Set the order ID.

 @param orderId ID of the eCommerce transaction.
 */
- (void) setOrderId:(NSString *)orderId;

/*!
 @brief Set the total value.

 @param totalValue Total transaction value.
 */
- (void) setTotalValue:(double)totalValue;

/*!
 @brief Set the affiliation.

 @param affiliation Transaction affiliation.
 */
- (void) setAffiliation:(nullable NSString *)affiliation;

/*!
 @brief Set the tax value.

 @param taxValue Transaction tax value.
 */
- (void) setTaxValue:(double)taxValue;

/*!
 @brief Set the shipping.

 @param shipping Delivery cost charged.
 */
- (void) setShipping:(double)shipping;

/*!
 @brief Set the city.

 @param city Delivery address city.
 */
- (void) setCity:(nullable NSString *)city;

/*!
 @brief Set the state.

 @param state Delivery address state.
 */
- (void) setState:(nullable NSString *)state;

/*!
 @brief Set the country.

 @param country Delivery address country.
 */
- (void) setCountry:(nullable NSString *)country;

/*!
 @brief Set the currency.

 @param currency Transaction currency.
 */
- (void) setCurrency:(nullable NSString *)currency;

/*!
 @brief Set the items.

 @param items An array of items in the transaction.
 */
- (void) setItems:(NSArray *)items;
@end

/*!
 @class SPEcommerce
 @brief An ecommerce event.
 */
@interface SPEcommerce : SPBuiltIn <SPEcommTransactionBuilder>
+ (instancetype) build:(void(^)(id<SPEcommTransactionBuilder>builder))buildBlock;
- (SPPayload *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
- (NSArray *) getItems;
@end

NS_ASSUME_NONNULL_END
