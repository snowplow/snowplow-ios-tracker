//
//  SPRemoteConfiguration.h
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
 * Represents the configuration for fetching configurations from a remote source.
 * For details on the correct format of a remote configuration see the official documentation.
 */
NS_SWIFT_NAME(RemoteConfiguration)
@interface SPRemoteConfiguration : SPConfiguration

/**
 * URL (without schema/protocol) used to send events to the collector.
 */
@property (nonatomic, nullable, readonly) NSString *endpoint;

/**
 * Method used to send events to the collector.
 */
@property (nonatomic, readonly) SPHttpMethod method;

/**
 * @param endpoint URL of the remote configuration.
 *                 The URL can include the schema/protocol (e.g.: `http://remote-config-url.xyz`).
 *                 In case the URL doesn't include the schema/protocol, the HTTPS protocol is
 *                 automatically selected.
 * @param method The method used to send the requests (GET or POST).
 */
- (instancetype)initWithEndpoint:(NSString *)endpoint method:(SPHttpMethod)method;

@end

NS_ASSUME_NONNULL_END
