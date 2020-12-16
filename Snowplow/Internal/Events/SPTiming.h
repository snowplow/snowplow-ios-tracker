//
//  SPTiming.h
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
 @protocol SPTimingBuilder
 @brief The protocol for building timing events.
 */
@protocol SPTimingBuilder <SPEventBuilder>

/*!
 @brief Set the category of the timing event.

 This is for categorizing timing variables into logical groups (e.g API calls, asset loading).

 @param category A logical group name for variables.
 */
- (void) setCategory:(NSString *)category;

/*!
 @brief Set the variable of the timing event.

 @param variable Identify the timing being recorded.
 */
- (void) setVariable:(NSString *)variable;

/*!
 @brief Set the timing.

 @param timing The number of milliseconds in elapsed time to report.
 */
- (void) setTiming:(NSInteger)timing;

/*!
 @brief Set the label.

 @param label Optional description of this timing.
 */
- (void) setLabel:(nullable NSString *)label;
@end

/*!
 @class SPTiming
 @brief A timing event.
 */
@interface SPTiming : SPSelfDescribing <SPTimingBuilder>
+ (instancetype) build:(void(^)(id<SPTimingBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
