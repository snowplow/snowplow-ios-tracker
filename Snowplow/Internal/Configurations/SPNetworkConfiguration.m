//
//  SPNetworkConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
