//
//  SNOWError.h
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
