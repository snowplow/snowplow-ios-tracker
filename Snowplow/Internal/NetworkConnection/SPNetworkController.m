//
//  SPNetworkController.m
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

#import "SPNetworkController.h"

@interface SPNetworkController ()

@property SPEmitter *emitter;

@end


@implementation SPNetworkController {
    id<SPRequestCallback> _requestCallback;
}

- (instancetype)initWithEmitter:(SPEmitter *)emitter {
    if (self = [super init]) {
        self.emitter = emitter;
    }
    return self;
}

// MARK: - Properties

- (void)setEndpoint:(NSString *)endpoint {
    [self.emitter setUrlEndpoint:endpoint];
}

- (NSString *)endpoint {
    return [self.emitter urlEndpoint].absoluteString;
}

- (void)setMethod:(SPRequestOptions)method {
    [self.emitter setHttpMethod:method];
}

- (SPRequestOptions)method {
    return [self.emitter httpMethod];
}

- (void)setProtocol:(SPProtocol)protocol {
    [self.emitter setProtocol:protocol];
}

- (SPProtocol)protocol {
    return [self.emitter protocol];
}

- (void)setCustomPostPath:(NSString *)customPostPath {
    [self.emitter setCustomPostPath:customPostPath];
}

- (NSString *)customPostPath {
    return [self.emitter customPostPath];
}

@end
