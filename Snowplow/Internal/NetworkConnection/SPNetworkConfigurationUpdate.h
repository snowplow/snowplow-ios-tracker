//
//  SPNetworkConfigurationUpdate.h
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
#import "SPTrackerConstants.h"
#import "SPNetworkConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPNetworkConfigurationUpdate : NSObject

@property (nonatomic, nullable) SPNetworkConfiguration *sourceConfig;

@property (nonatomic, nullable) NSString *customPostPath;
@property (nonatomic, nullable) NSDictionary<NSString *, NSString *> *requestHeaders;

- (nullable NSString *)endpoint;
- (SPHttpMethod)method;
- (SPProtocol)protocol;
- (nullable id<SPNetworkConnection>)networkConnection;

SP_DIRTYFLAG(customPostPath)
SP_DIRTYFLAG(requestHeaders)

@end

NS_ASSUME_NONNULL_END
