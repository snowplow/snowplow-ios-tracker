//
//  SPForeground.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

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
