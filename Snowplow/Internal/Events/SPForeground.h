//
//  SPForeground.h
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
 @protocol SPForegroundBuilder
 @brief The protocol for building foreground events.
 */
@protocol SPForegroundBuilder <SPEventBuilder>

/*!
 @brief Set the index of the event, a count that increments on each background and foreground.

 @param index The transition event index.
 */
- (void) setIndex:(NSNumber *)index;
@end

/*!
 @class SPForeground
 @brief A foreground transition event.
 */
@interface SPForeground : SPSelfDescribing <SPForegroundBuilder>
+ (instancetype) build:(void(^)(id<SPForegroundBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
