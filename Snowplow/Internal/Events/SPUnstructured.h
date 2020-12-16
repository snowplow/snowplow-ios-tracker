//
//  SPUnstructured.h
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
@interface SPUnstructured : SPSelfDescribing <SPUnstructuredBuilder>
+ (instancetype) build:(void(^)(id<SPUnstructuredBuilder>builder))buildBlock;
- (SPPayload *) getPayloadWithEncoding:(BOOL)encoding  __deprecated_msg("getPayloadWithEncoding is deprecated. Use `payload` instead.");
@end

NS_ASSUME_NONNULL_END
