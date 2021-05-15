//
//  SPNetworkControllerImpl.m
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

#import "SPNetworkControllerImpl.h"
#import "SPDefaultNetworkConnection.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPNetworkConfigurationUpdate.h"


@implementation SPNetworkControllerImpl {
    id<SPRequestCallback> _requestCallback;
}

- (BOOL)isCustomNetworkConnection {
    return self.emitter.networkConnection && ![self.emitter.networkConnection isKindOfClass:SPDefaultNetworkConnection.class];
}

// MARK: - Properties

- (void)setEndpoint:(NSString *)endpoint {
    [self.emitter setUrlEndpoint:endpoint];
}

- (NSString *)endpoint {
    return [self.emitter urlEndpoint].absoluteString;
}

- (void)setMethod:(SPHttpMethod)method {
    [self.emitter setHttpMethod:method];
}

- (SPHttpMethod)method {
    return [self.emitter httpMethod];
}

- (void)setCustomPostPath:(NSString *)customPostPath {
    self.dirtyConfig.customPostPath = customPostPath;
    self.dirtyConfig.customPostPathUpdated = YES;
    [self.emitter setCustomPostPath:customPostPath];
}

- (NSString *)customPostPath {
    return [self.emitter customPostPath];
}

- (void)setRequestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders {
    self.dirtyConfig.requestHeaders = requestHeaders;
    self.dirtyConfig.requestHeadersUpdated = YES;
    [self.emitter setRequestHeaders:requestHeaders];
}

- (NSDictionary<NSString *, NSString *> *)requestHeaders {
    return [self.emitter requestHeaders];
}

// MARK: - Private methods

- (SPEmitter *)emitter {
    return self.serviceProvider.tracker.emitter;
}

- (SPNetworkConfigurationUpdate *)dirtyConfig {
    return self.serviceProvider.networkConfigurationUpdate;
}

@end
