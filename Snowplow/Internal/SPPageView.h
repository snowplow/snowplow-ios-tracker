//
//  SPPageView.h
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

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPPageViewBuilder
 @brief The protocol for building pageview events.
 */
@protocol SPPageViewBuilder <SPEventBuilder>

/*!
 @brief Set the URL of the page.

 @param pageUrl The URL of the page.
 */
- (void) setPageUrl:(NSString *)pageUrl;

/*!
 @brief Set the title of the page.

 @param pageTitle The title of the page.
 */
- (void) setPageTitle:(nullable NSString *)pageTitle;

/*!
 @brief Set the referrer of the pageview.

 @param referrer The pageview referrer.
 */
- (void) setReferrer:(nullable NSString *)referrer;
@end

/*!
 @class SPPageView
 @brief A pageview.
 */
@interface SPPageView : SPPrimitive <SPPageViewBuilder>
+ (instancetype) build:(void(^)(id<SPPageViewBuilder>builder))buildBlock;
- (SPPayload *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
