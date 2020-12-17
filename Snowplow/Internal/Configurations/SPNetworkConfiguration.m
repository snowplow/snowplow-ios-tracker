//
//  SPNetworkConfiguration.m
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

#import "SPNetworkConfiguration.h"

@interface SPNetworkConfiguration ()

@property (nonatomic, nullable) NSString *endpoint;
@property (nonatomic) SPRequestOptions method;
@property (nonatomic) SPProtocol protocol;

@end

@implementation SPNetworkConfiguration

@synthesize customPostPath;

- (instancetype)initWithEndpoint:(NSString *)endpoint protocol:(SPProtocol)protocol method:(SPRequestOptions)method {
    if (self = [super init]) {
        self.endpoint = endpoint;
        self.protocol = protocol;
        self.method = method;
        self.networkConnection = nil;
        self.customPostPath = nil;
    }
    return self;
}

- (instancetype)initWithEndpoint:(NSString *)endpoint {
    return [self initWithEndpoint:endpoint protocol:SPProtocolHttps method:SPRequestOptionsPost];
}

- (instancetype)initWithNetworkConnection:(id<SPNetworkConnection>)networkConnection {
    if (self = [super init]) {
        self.endpoint = nil;
        self.protocol = 0;
        self.method = 0;
        self.networkConnection = networkConnection;
        self.customPostPath = nil;
    }
    return self;
}

// MARK: - Builder

SP_BUILDER_METHOD(NSString *, customPostPath)

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPNetworkConfiguration *copy;
    if (self.networkConnection) {
        copy = [[SPNetworkConfiguration alloc] initWithNetworkConnection:self.networkConnection];
        
    } else {
        copy = [[SPNetworkConfiguration allocWithZone:zone] initWithEndpoint:self.endpoint protocol:self.protocol method:self.method];
    }
    copy.customPostPath = self.customPostPath;
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.endpoint forKey:SP_STR_PROP(endpoint)];
    [coder encodeInteger:self.protocol forKey:SP_STR_PROP(protocol)];
    [coder encodeInteger:self.method forKey:SP_STR_PROP(method)];
    [coder encodeObject:self.customPostPath forKey:SP_STR_PROP(customPostPath)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.endpoint = [coder decodeObjectForKey:SP_STR_PROP(endpoint)];
        self.protocol = [coder decodeIntegerForKey:SP_STR_PROP(protocol)];
        self.method = [coder decodeIntegerForKey:SP_STR_PROP(method)];
        self.customPostPath = [coder decodeObjectForKey:SP_STR_PROP(customPostPath)];
    }
    return self;
}

@end
