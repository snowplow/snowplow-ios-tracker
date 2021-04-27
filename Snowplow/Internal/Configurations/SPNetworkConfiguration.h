//
//  SPNetworkConfiguration.h
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPNetworkConnection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents the network communication configuration
 * allowing the tracker to be able to send events to the Snowplow collector.
 */
NS_SWIFT_NAME(NetworkConfiguration)
@interface SPNetworkConfiguration : SPConfiguration

/**
 * URL (without schema/protocol) used to send events to the collector.
 */
@property (nonatomic, nullable, readonly) NSString *endpoint;

/**
 * Method used to send events to the collector.
 */
@property (nonatomic, readonly) SPHttpMethod method;

/**
 * Protocol used to send events to the collector.
 */
@property (nonatomic, readonly) SPProtocol protocol;

/**
 * See `NetworkConfiguration(NetworkConnection)`
 */
@property (nonatomic, nullable) id<SPNetworkConnection> networkConnection;

/**
 * A custom path which will be added to the endpoint URL to specify the
 * complete URL of the collector when paired with the POST method.
 */
@property (nonatomic, nullable) NSString *customPostPath;

/**
 *  Custom headers for http requests.
 */
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *requestHeaders;

// TODO: add -> @property () NSInteger timeout;


+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

/**
 * @param endpoint URL of the collector that is going to receive the events tracked by the tracker.
 *                 The URL can include the schema/protocol (e.g.: `http://collector-url.com`).
 *                 In case the URL doesn't include the schema/protocol, the HTTPS protocol is
 *                 automatically selected.
 */
- (instancetype)initWithEndpoint:(NSString *)endpoint;

/**
 * @param endpoint URL of the collector that is going to receive the events tracked by the tracker.
 *                 The URL can include the schema/protocol (e.g.: `http://collector-url.com`).
 *                 In case the URL doesn't include the schema/protocol, the HTTPS protocol is
 *                 automatically selected.
 * @param method The method used to send the requests (GET or POST).
 */
- (instancetype)initWithEndpoint:(NSString *)endpoint method:(SPHttpMethod)method;

/**
 * @param networkConnection The NetworkConnection component which will control the
 *                          communication between the tracker and the collector.
 */
- (instancetype)initWithNetworkConnection:(id<SPNetworkConnection>)networkConnection;

SP_BUILDER_DECLARE_NULLABLE(NSString *, customPostPath)
SP_BUILDER_DECLARE_NULLABLE(NSDictionary *, requestHeaders)

@end

NS_ASSUME_NONNULL_END
