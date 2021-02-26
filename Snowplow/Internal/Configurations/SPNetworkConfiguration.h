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

NS_SWIFT_NAME(NetworkConfiguration)
@interface SPNetworkConfiguration : SPConfiguration

@property (nonatomic, nullable, readonly) NSString *endpoint;
@property (nonatomic, readonly) SPHttpMethod method;
@property (nonatomic, readonly) SPProtocol protocol;

@property (nonatomic, nullable) id<SPNetworkConnection> networkConnection;
@property (nonatomic, nullable) NSString *customPostPath;
// TODO: add -> @property () NSInteger timeout;


+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype)initWithEndpoint:(NSString *)endpoint;
- (instancetype)initWithEndpoint:(NSString *)endpoint method:(SPHttpMethod)method;

- (instancetype)initWithNetworkConnection:(id<SPNetworkConnection>)networkConnection;

SP_BUILDER_DECLARE_NULLABLE(NSString *, customPostPath)

@end

NS_ASSUME_NONNULL_END
