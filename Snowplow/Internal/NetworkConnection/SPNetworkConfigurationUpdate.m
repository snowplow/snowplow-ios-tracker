//
//  SPNetworkConfigurationUpdate.m
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

#import "SPNetworkConfigurationUpdate.h"

@implementation SPNetworkConfigurationUpdate

- (NSString *)endpoint {
    return [self.sourceConfig endpoint];
}

- (SPHttpMethod)method {
    return [self.sourceConfig method];
}

- (SPProtocol)protocol {
    return [self.sourceConfig protocol];
}

- (id<SPNetworkConnection>)networkConnection {
    return [self.sourceConfig networkConnection];
}

// SP_DIRTY_GETTER replacement as NetworkConfigurationUpdate doesn't extend NetworkConfiguration like the others updater classes.
- (NSString *)customPostPath { return self.customPostPathUpdated ? _customPostPath : self.sourceConfig.customPostPath; }
- (NSDictionary *)requestHeaders { return self.requestHeadersUpdated ? _requestHeaders : self.sourceConfig.requestHeaders; }

@end
