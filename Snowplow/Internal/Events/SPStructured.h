//
//  SPStructured.h
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
 @protocol SPStructuredBuilder
 @brief The protocol for building structured events.
 */
NS_SWIFT_NAME(StructuredBuilder)
@protocol SPStructuredBuilder <SPEventBuilder>

/*!
 @brief Set the category of the structured event.

 @param category The category of the structured event.
 */
- (void) setCategory:(NSString *)category __deprecated_msg("Use `category` of `Structured` class instead.");

/*!
 @brief Set the action of the structured event.

 @param action The action of the structured event.
 */
- (void) setAction:(NSString *)action __deprecated_msg("Use `action` of `Structured` class instead.");

/*!
 @brief Set the label of the structured event.

 @param label The label of the structured event.
 */
- (void) setLabel:(nullable NSString *)label __deprecated_msg("Use `label` of `Structured` class instead.");

/*!
 @brief Set the property of the structured event.

 @param property The property of the structured event.
 */
- (void) setProperty:(nullable NSString *)property __deprecated_msg("Use `property` of `Structured` class instead.");

/*!
 @brief Set the value of the structured event.

 @param value The value of the structured event.
 */
- (void) setValue:(nullable NSNumber *)value __deprecated_msg("Use `value` of `Structured` class instead.");
@end

/*!
 @class SPStructured
 @brief A structured event.
 */
NS_SWIFT_NAME(Structured)
@interface SPStructured : SPPrimitiveAbstract <SPStructuredBuilder>

@property (nonatomic, readonly) NSString *category;
@property (nonatomic, readonly) NSString *action;
@property (nonatomic, nullable) NSString *label;
@property (nonatomic, nullable) NSString *property;
@property (nonatomic, nullable) NSNumber *value;

+ (instancetype)build:(void(^)(id<SPStructuredBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCategory:(NSString *)category action:(NSString *)action NS_SWIFT_NAME(init(category:action:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, label)
SP_BUILDER_DECLARE_NULLABLE(NSString *, property)
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, value)

@end

NS_ASSUME_NONNULL_END
