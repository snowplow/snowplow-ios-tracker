//
//  SPStructured.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPStructuredBuilder
 @brief The protocol for building structured events.
 */
@protocol SPStructuredBuilder <SPEventBuilder>

/*!
 @brief Set the category of the structured event.

 @param category The category of the structured event.
 */
- (void) setCategory:(NSString *)category;

/*!
 @brief Set the action of the structured event.

 @param action The action of the structured event.
 */
- (void) setAction:(NSString *)action;

/*!
 @brief Set the label of the structured event.

 @param label The label of the structured event.
 */
- (void) setLabel:(nullable NSString *)label;

/*!
 @brief Set the property of the structured event.

 @param property The property of the structured event.
 */
- (void) setProperty:(nullable NSString *)property;

/*!
 @brief Set the value of the structured event.

 @param value The value of the structured event.
 */
- (void) setValue:(double)value;
@end

/*!
 @class SPStructured
 @brief A structured event.
 */
@interface SPStructured : SPBuiltIn <SPStructuredBuilder>
+ (instancetype) build:(void(^)(id<SPStructuredBuilder>builder))buildBlock;
- (SPPayload *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
