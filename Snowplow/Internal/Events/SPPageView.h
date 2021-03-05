//
//  SPPageView.h
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
 @protocol SPPageViewBuilder
 @brief The protocol for building pageview events.
 */
NS_SWIFT_NAME(PageViewBuilder)
@protocol SPPageViewBuilder <SPEventBuilder>

/*!
 @brief Set the URL of the page.

 @param pageUrl The URL of the page.
 */
- (void) setPageUrl:(NSString *)pageUrl __deprecated_msg("Use initializer of `PageView` class instead.");

/*!
 @brief Set the title of the page.

 @param pageTitle The title of the page.
 */
- (void) setPageTitle:(nullable NSString *)pageTitle __deprecated_msg("Use `pageTitle` of `PageView` class instead.");

/*!
 @brief Set the referrer of the pageview.

 @param referrer The pageview referrer.
 */
- (void) setReferrer:(nullable NSString *)referrer __deprecated_msg("Use `referrer` of `PageView` class instead.");
@end

/*!
 @class SPPageView
 @brief A pageview.
 */
NS_SWIFT_NAME(PageView)
@interface SPPageView : SPPrimitiveAbstract <SPPageViewBuilder>

@property (nonatomic, readonly) NSString *pageUrl;
@property (nonatomic, nullable) NSString *pageTitle;
@property (nonatomic, nullable) NSString *referrer;

+ (instancetype)build:(void(^)(id<SPPageViewBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPageUrl:(NSString *)pageUrl NS_SWIFT_NAME(init(pageUrl:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, pageTitle)
SP_BUILDER_DECLARE_NULLABLE(NSString *, referrer)

@end

NS_ASSUME_NONNULL_END
