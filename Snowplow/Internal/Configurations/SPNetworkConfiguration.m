//
//  SPNetworkConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPNetworkConfiguration.h"

@implementation SPNetworkConfiguration

@synthesize endpoint;
@synthesize method;
@synthesize protocol;
@synthesize customPostPath;
@synthesize timeout;

- (instancetype)initWithEndpoint:(NSString *)endpoint protocol:(SPProtocol)protocol method:(SPRequestOptions)method {
    if (self = [super init]) {
        self.endpoint = endpoint;
        self.protocol = protocol;
        self.method = method;
        
        self.customPostPath = nil;
        self.timeout = 5;
    }
    return self;
}

// MARK: - Builder

SP_BUILDER_METHOD(NSString *, customPostPath)
SP_BUILDER_METHOD(NSInteger, timeout)

// MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    SPNetworkConfiguration *copy = [[SPNetworkConfiguration allocWithZone:zone] initWithEndpoint:self.endpoint protocol:self.protocol method:self.method];
    copy.customPostPath = self.customPostPath;
    copy.timeout = self.timeout;
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.endpoint forKey:SP_STR_PROP(endpoint)];
    [coder encodeInteger:self.protocol forKey:SP_STR_PROP(protocol)];
    [coder encodeInteger:self.method forKey:SP_STR_PROP(method)];
    [coder encodeObject:self.customPostPath forKey:SP_STR_PROP(customPostPath)];
    [coder encodeInteger:self.timeout forKey:SP_STR_PROP(timeout)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.endpoint = [coder decodeObjectForKey:SP_STR_PROP(endpoint)];
        self.protocol = [coder decodeIntegerForKey:SP_STR_PROP(protocol)];
        self.method = [coder decodeIntegerForKey:SP_STR_PROP(method)];
        self.customPostPath = [coder decodeObjectForKey:SP_STR_PROP(customPostPath)];
        self.timeout = [coder decodeIntegerForKey:SP_STR_PROP(timeout)];
    }
    return self;
}

@end
