//
//  SPDefaultNetworkConnection.h
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
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPNetworkConnection.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SPDefaultNetworkConnectionBuilder <NSObject>

/*!
 @brief Builder method to set the collector endpoint.
 @param urlEndpoint The collector endpoint.
 */
- (void) setUrlEndpoint:(NSString *)urlEndpoint;

/*!
 @brief Builder method to set HTTP method.
 @param method Should be SPRequestGet or SPRequestPost.
 */
- (void) setHttpMethod:(SPRequestOptions)method;

/*!
 @brief Builder method to set HTTP security.
 @param protocol Should be SPHttp or SPHttps.
 */
- (void) setProtocol:(SPProtocol)protocol;

/*!
 @brief Builder method to set thread pool size.
 @param emitThreadPoolSize The number of threads used by the emitter.
 */
- (void) setEmitThreadPoolSize:(NSUInteger)emitThreadPoolSize;

/*!
 @brief Builder method to set byte limit for GET requests.
 @param byteLimitGet Maximum event size for a GET request.
 */
- (void) setByteLimitGet:(NSUInteger)byteLimitGet;

/*!
 @brief Builder method to set byte limit for POST requests.
 @param byteLimitPost Maximum event size for a POST request.
 */
- (void) setByteLimitPost:(NSUInteger)byteLimitPost;

/*!
 @brief Builder method to set a custom POST path.
 @param customPath A custom path that is used on the endpoint to send requests.
 */
- (void) setCustomPostPath:(NSString *)customPath;

@end

@interface SPDefaultNetworkConnection : NSObject <SPNetworkConnection, SPDefaultNetworkConnectionBuilder>

/*!
 @brief Builds the DefaultNetworkConnection using a build block of functions.
 */
+ (instancetype) build:(void(^)(id<SPDefaultNetworkConnectionBuilder>builder))buildBlock;

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
