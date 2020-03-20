//
//  SPBackground.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEventBase.h"
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPBackgroundBuilder
 @brief The protocol for building background events.
 */
@protocol SPBackgroundBuilder <SPEventBuilder>

/*!
 @brief Set the index of the event, a count that increments on each background and foreground.

 @param index The transition event index.
 */
- (void) setIndex:(NSNumber *)index;
@end

/*!
 @class SPBackground
 @brief A background transition event.
 */
@interface SPBackground : SPSelfDescribing <SPBackgroundBuilder>
+ (instancetype) build:(void(^)(id<SPBackgroundBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload __deprecated_msg("getPayload is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
