//
//  SPDefaultNetworkConnection.h
//  Snowplow
//
//  Created by Alex Benini on 21/08/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
