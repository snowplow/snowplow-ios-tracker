//
//  SNOWError.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPErrorBuilder
 @brief The protocol for building error events.
 */
@protocol SPErrorBuilder <SPEventBuilder>

/*!
 @brief Set the error message.
 
 @param message The error message.
 */
- (void) setMessage:(NSString *)message;

/*!
 @brief Set the exception stack trace.
 
 @param stackTrace The stack trace of the exception.
 */
- (void) setStackTrace:(nullable NSString *)stackTrace;

/*!
 @brief Set the exception name.
 
 @param name The exception name.
 */
- (void) setName:(nullable NSString *)name;

@end

/*!
 @class SNOWError
 @brief An error event.
 */
@interface SNOWError : SPSelfDescribing <SPErrorBuilder>
+ (instancetype) build:(void(^)(id<SPErrorBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end


NS_ASSUME_NONNULL_END
