//
//  SPScreenView.h
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

@class SPScreenState;

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPScreenViewBuilder
 @brief The protocol for building screenview events.
 */
@protocol SPScreenViewBuilder <SPEventBuilder>
/*!
 @brief Set the name of the screen.

 @param name The name of the screen.
 */
- (void) setName:(NSString *)name;

/*!
 @brief Set the type of the screen.

 @param type The type for the screen.
 */
- (void) setType:(nullable NSString *)type;

/*!
 @brief Set the ID of the screen.

 @param screenId The ID for the screen.
 */
- (void) setScreenId:(NSString *)screenId;

/*!
 @brief Set the name of the previous screen.

 @param name The name of the previous screen.
 */
- (void) setPreviousScreenName:(nullable NSString *)name;

/*!
 @brief Set the type of the previous screen.

 @param type The type of the previous screen.
 */
- (void) setPreviousScreenType:(nullable NSString *)type;

/*!
 @brief Set the ID of the previous screen.

 @param screenId The ID for the previous screen.
 */
- (void) setPreviousScreenId:(nullable NSString *)screenId;

/*!
 @brief Set the type of the screen transition.

 @param type The type of the screen transition.
 */
- (void) setTransitionType:(nullable NSString *)type;

- (void) setViewControllerClassName:(nullable NSString *)className;

- (void) setTopViewControllerClassName:(nullable NSString *)className;

@end

/*!
 @class SPScreenView
 @brief A screenview event.
 */
@interface SPScreenView : SPSelfDescribing <SPScreenViewBuilder>
+ (instancetype) build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
- (SPScreenState *) getScreenState;
- (BOOL) updateWithPreviousState:(SPScreenState *)previousState;
@end


NS_ASSUME_NONNULL_END
