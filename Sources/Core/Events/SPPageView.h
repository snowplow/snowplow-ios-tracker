//
//  SPPageView.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 A pageview event.
 @deprecated This event has been designed for web trackers, not suitable for mobile apps. Use DeepLinkReceived event to track deep link received in the app.
 */
NS_SWIFT_NAME(PageView)
@interface SPPageView : SPPrimitiveAbstract

/// Page url.
@property (nonatomic, readonly) NSString *pageUrl;
/// Page title.
@property (nonatomic, nullable) NSString *pageTitle;
/// Page referrer url.
@property (nonatomic, nullable) NSString *referrer;

- (instancetype)init NS_UNAVAILABLE;

/// Creates a pageview event.
/// @param pageUrl The page url.
- (instancetype)initWithPageUrl:(NSString *)pageUrl NS_SWIFT_NAME(init(pageUrl:));

/// Page title.
SP_BUILDER_DECLARE_NULLABLE(NSString *, pageTitle)
/// Page referrer url.
SP_BUILDER_DECLARE_NULLABLE(NSString *, referrer)

@end

NS_ASSUME_NONNULL_END
