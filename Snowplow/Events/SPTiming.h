//
//  SPTiming.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

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
- (void) setLabel:(NSString *)label;
@end

/*!
 @class SPTiming
 @brief A timing event.
 */
@interface SPTiming : SPEvent <SPTimingBuilder>
+ (instancetype) build:(void(^)(id<SPTimingBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

NS_ASSUME_NONNULL_END
