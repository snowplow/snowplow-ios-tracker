//
//  SNOWError.h
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
- (void) setMessage:(NSString *)message __deprecated_msg("Use initializer of `SNOWError` class instead.");

/*!
 @brief Set the exception stack trace.
 
 @param stackTrace The stack trace of the exception.
 */
- (void) setStackTrace:(nullable NSString *)stackTrace __deprecated_msg("Use `stackTrace` of `SNOWError` class instead.");

/*!
 @brief Set the exception name.
 
 @param name The exception name.
 */
- (void) setName:(nullable NSString *)name __deprecated_msg("Use name of `SNOWError` class instead.");

@end

/*!
 @class SNOWError
 @brief An error event.
 */
@interface SNOWError : SPSelfDescribingAbstract <SPErrorBuilder>

@property (nonatomic, nullable) NSString *name;
@property (nonatomic, nullable) NSString *stackTrace;
@property (nonatomic, readonly) NSString *message;

+ (instancetype)build:(void(^)(id<SPErrorBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithMessage:(NSString *)message NS_SWIFT_NAME(init(message:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
SP_BUILDER_DECLARE_NULLABLE(NSString *, stackTrace)

@end


NS_ASSUME_NONNULL_END
