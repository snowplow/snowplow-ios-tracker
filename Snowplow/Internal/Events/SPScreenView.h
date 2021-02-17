//
//  SPScreenView.h
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

@class SPScreenState;

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPScreenViewBuilder
 @brief The protocol for building screenview events.
 */
NS_SWIFT_NAME(ScreenViewBuilder)
@protocol SPScreenViewBuilder <SPEventBuilder>
/*!
 @brief Set the name of the screen.

 @param name The name of the screen.
 */
- (void) setName:(NSString *)name __deprecated_msg("Use `name` of `ScreenView` class instead.");

/*!
 @brief Set the type of the screen.

 @param type The type for the screen.
 */
- (void) setType:(nullable NSString *)type __deprecated_msg("Use `type` of `ScreenView` class instead.");

/*!
 @brief Set the ID of the screen.

 @param screenId The ID for the screen.
 */
- (void) setScreenId:(NSString *)screenId __deprecated_msg("Use `screenId` of `ScreenView` class instead.");

/*!
 @brief Set the name of the previous screen.

 @param name The name of the previous screen.
 */
- (void) setPreviousScreenName:(nullable NSString *)name __deprecated_msg("Use `previousName` of `ScreenView` class instead.");

/*!
 @brief Set the type of the previous screen.

 @param type The type of the previous screen.
 */
- (void) setPreviousScreenType:(nullable NSString *)type __deprecated_msg("Use `previousType` of `ScreenView` class instead.");

/*!
 @brief Set the ID of the previous screen.

 @param screenId The ID for the previous screen.
 */
- (void) setPreviousScreenId:(nullable NSString *)screenId __deprecated_msg("Use `previousId` of `ScreenView` class instead.");

/*!
 @brief Set the type of the screen transition.

 @param type The type of the screen transition.
 */
- (void) setTransitionType:(nullable NSString *)type __deprecated_msg("Use `transitionType` of `ScreenView` class instead.");

- (void) setViewControllerClassName:(nullable NSString *)className __deprecated_msg("Use `viewControllerClassName` of `ScreenView` class instead.");

- (void) setTopViewControllerClassName:(nullable NSString *)className __deprecated_msg("Use `topViewControllerClassName` of `ScreenView` class instead.");

@end

/*!
 @class SPScreenView
 @brief A screenview event.
 */
NS_SWIFT_NAME(ScreenView)
@interface SPScreenView : SPSelfDescribingAbstract <SPScreenViewBuilder>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *screenId;
@property (nonatomic, nullable) NSString *type;
@property (nonatomic, nullable) NSString *previousName;
@property (nonatomic, nullable) NSString *previousId;
@property (nonatomic, nullable) NSString *previousType;
@property (nonatomic, nullable) NSString *transitionType;
@property (nonatomic, nullable) NSString *viewControllerClassName;
@property (nonatomic, nullable) NSString *topViewControllerClassName;

+ (instancetype)build:(void(^)(id<SPScreenViewBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name screenId:(nullable NSUUID *)screenId NS_SWIFT_NAME(init(name:screenId:));

- (SPScreenState *)getScreenState;

- (BOOL)updateWithPreviousState:(SPScreenState *)previousState;

SP_BUILDER_DECLARE_NULLABLE(NSString *, type)
SP_BUILDER_DECLARE_NULLABLE(NSString *, previousName)
SP_BUILDER_DECLARE_NULLABLE(NSString *, previousId)
SP_BUILDER_DECLARE_NULLABLE(NSString *, previousType)
SP_BUILDER_DECLARE_NULLABLE(NSString *, transitionType)
SP_BUILDER_DECLARE_NULLABLE(NSString *, viewControllerClassName)
SP_BUILDER_DECLARE_NULLABLE(NSString *, topViewControllerClassName)

@end


NS_ASSUME_NONNULL_END
