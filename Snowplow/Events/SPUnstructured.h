//
//  SPUnstructured.h
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEvent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SPUnstructuredBuilder
 @brief The protocol for building unstructured events.
 */
@protocol SPUnstructuredBuilder <SPEventBuilder>
/*!
 @brief Set the data field of the unstructured event.

 @param eventData A self-describing JSON of an unstructured event.
 */
- (void) setEventData:(SPSelfDescribingJson *)eventData;
@end

/*!
 @class SPUnstructured
 @brief An unstructured event.
 */
@interface SPUnstructured : SPEvent <SPUnstructuredBuilder>
+ (instancetype) build:(void(^)(id<SPUnstructuredBuilder>builder))buildBlock;
- (SPPayload *) getPayloadWithEncoding:(BOOL)encoding;
@end

NS_ASSUME_NONNULL_END
