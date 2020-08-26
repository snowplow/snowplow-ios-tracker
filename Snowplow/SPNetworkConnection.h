//
//  SPNetworkConnection.h
//  Snowplow
//
//  Created by Alex Benini on 21/08/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPRequest.h"
#import "SPRequestResult.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief An enum for HTTP method types.
 */
typedef NS_ENUM(NSInteger, SPRequestOptions) {
    /*! GET request. */
    SPRequestGet,
    /*! POST request. */
    SPRequestPost
};

/*!
 @brief An enum for HTTP security.
 */
typedef NS_ENUM(NSInteger, SPProtocol) {
    /*! Use HTTP. */
    SPHttp,
    /*! Use HTTP over TLS. */
    SPHttps
};

/**
 * Interface for the component that
 * sends events to the collector.
 */
@protocol SPNetworkConnection <NSObject>

/**
 * Send requests to the collector.
 * @param requests to send,
 * @return results of the sending operation.
 */
- (NSArray<SPRequestResult *> *)sendRequests:(NSArray<SPRequest *> *)requests;

/**
 * @return http method used to send requests to the collector.
 */
- (SPRequestOptions)httpMethod;

/**
 * @return URL of the collector.
 */
- (NSURL *)url;

@end

NS_ASSUME_NONNULL_END
