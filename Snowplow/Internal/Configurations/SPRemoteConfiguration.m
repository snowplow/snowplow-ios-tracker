//
//  SPRemoteConfiguration.m
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

#import "SPRemoteConfiguration.h"

@interface SPRemoteConfiguration ()

@property (nonatomic) NSString *endpoint;
@property (nonatomic) SPHttpMethod method;

@end

@implementation SPRemoteConfiguration

- (instancetype)initWithEndpoint:(NSString *)endpoint method:(SPHttpMethod)method {
    if (self = [super init]) {
        NSURL *url = [[NSURL alloc] initWithString:endpoint];
        if (url.scheme && [@[@"https", @"http"] containsObject:url.scheme]) {
            self.endpoint = endpoint;
        } else {
            self.endpoint = [NSString stringWithFormat:@"https://%@", endpoint];
        }
        self.method = method;
    }
    return self;
}

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[SPRemoteConfiguration allocWithZone:zone] initWithEndpoint:self.endpoint method:self.method];
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.endpoint forKey:SP_STR_PROP(endpoint)];
    [coder encodeInteger:self.method forKey:SP_STR_PROP(method)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.endpoint = [coder decodeObjectForKey:SP_STR_PROP(endpoint)];
        self.method = [coder decodeIntegerForKey:SP_STR_PROP(method)];
    }
    return self;
}


@end
