//
//  SPNetworkConnection.h
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
