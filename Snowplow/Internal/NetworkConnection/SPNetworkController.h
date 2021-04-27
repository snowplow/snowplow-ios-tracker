//
//  SPNetworkController.h
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
#import "SPNetworkConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(NetworkController)
@protocol SPNetworkController

/**
 * URL used to send events to the collector.
 */
@property (nonatomic, nullable) NSString *endpoint;
/**
 * Method used to send events to the collector.
 */
@property (nonatomic) SPHttpMethod method;

/**
 * A custom path which will be added to the endpoint URL to specify the
 * complete URL of the collector when paired with the POST method.
 */
@property (nonatomic, nullable) NSString *customPostPath;

/**
 * Custom headers for http requests.
 */
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *requestHeaders;

@end

NS_ASSUME_NONNULL_END
