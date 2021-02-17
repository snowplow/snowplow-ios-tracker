//
//  SPForeground.h
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
 @protocol SPForegroundBuilder
 @brief The protocol for building foreground events.
 */
NS_SWIFT_NAME(ForegroundBuilder)
@protocol SPForegroundBuilder <SPEventBuilder>

/*!
 @brief Set the index of the event, a count that increments on each background and foreground.

 @param index The transition event index.
 */
- (void) setIndex:(NSNumber *)index __deprecated_msg("Use initializer of `Foreground` class instead.");
@end

/*!
 @class SPForeground
 @brief A foreground transition event.
 */
NS_SWIFT_NAME(Foreground)
@interface SPForeground : SPSelfDescribingAbstract <SPForegroundBuilder>

+ (instancetype)build:(void(^)(id<SPForegroundBuilder> builder))buildBlock __deprecated_msg("Use initializer instead.");

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIndex:(NSNumber *)index NS_SWIFT_NAME(init(index:));

@end

NS_ASSUME_NONNULL_END
