//
//  SPRequestResult.h
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
//  Authors: Joshua Beemster
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(RequestResult)
@interface SPRequestResult : NSObject

/// Returns the HTTP status code from Collector.
@property (nonatomic, readonly) NSInteger statusCode;
/// Was the request oversize
@property (nonatomic, readonly) BOOL isOversize;
/// Returns the stored index array, needed to remove the events after sending.
@property (nonatomic, readonly) NSArray<NSNumber *> *storeIds;

/**
 * Creates a request result object
 * @param statusCode HTTP status code from collector response
 * @param storeIds the event indexes in the database
 */
- (instancetype)initWithStatusCode:(NSInteger)statusCode oversize:(BOOL)isOversize storeIds:(NSArray<NSNumber *> *)storeIds;

/**
 * @return Whether the events were successfuly sent to the Collector.
 */
- (BOOL)isSuccessful;

/**
 * @param customRetryForStatusCodes mapping of custom retry rules for HTTP status codes in Collector response.
 * @return Whether sending the events to the Collector should be retried.
 */
- (BOOL)shouldRetry:(NSDictionary<NSNumber *, NSNumber *> *)customRetryForStatusCodes;

@end
