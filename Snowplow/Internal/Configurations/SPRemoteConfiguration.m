//
//  SPRemoteConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 03/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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
