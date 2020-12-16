//
//  SPEmitterConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEmitterConfiguration.h"

@implementation SPEmitterConfiguration

@synthesize bufferOption;
@synthesize byteLimitGet;
@synthesize byteLimitPost;
@synthesize emitRange;
@synthesize emitThreadPoolSize;
@synthesize requestCallback;

- (instancetype)init {
    if (self = [super init]) {
        self.bufferOption = SPBufferOptionSingle;
        self.emitRange = 150;
        self.emitThreadPoolSize = 15;
        self.byteLimitGet = 40000;
        self.byteLimitPost = 40000;
        self.eventStore = nil;
        self.requestCallback = nil;
    }
    return self;
}

// MARK: - Builder

SP_BUILDER_METHOD(SPBufferOption, bufferOption)
SP_BUILDER_METHOD(NSInteger, emitRange)
SP_BUILDER_METHOD(NSInteger, emitThreadPoolSize)
SP_BUILDER_METHOD(NSInteger, byteLimitGet)
SP_BUILDER_METHOD(NSInteger, byteLimitPost)
SP_BUILDER_METHOD(id<SPRequestCallback>, requestCallback)

SP_BUILDER_METHOD(id<SPEventStore>, eventStore)

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPEmitterConfiguration *copy = [[SPEmitterConfiguration allocWithZone:zone] init];
    copy.bufferOption = self.bufferOption;
    copy.emitRange = self.emitRange;
    copy.emitThreadPoolSize = self.emitThreadPoolSize;
    copy.byteLimitGet = self.byteLimitGet;
    copy.byteLimitPost = self.byteLimitPost;
    copy.requestCallback = self.requestCallback;
    copy.eventStore = self.eventStore;
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeInteger:self.bufferOption forKey:SP_STR_PROP(bufferOption)];
    [coder encodeInteger:self.emitRange forKey:SP_STR_PROP(emitRange)];
    [coder encodeInteger:self.emitThreadPoolSize forKey:SP_STR_PROP(emitThreadPoolSize)];
    [coder encodeInteger:self.byteLimitGet forKey:SP_STR_PROP(byteLimitGet)];
    [coder encodeInteger:self.byteLimitPost forKey:SP_STR_PROP(byteLimitPost)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.bufferOption = [coder decodeIntegerForKey:SP_STR_PROP(bufferOption)];
        self.emitRange = [coder decodeIntegerForKey:SP_STR_PROP(emitRange)];
        self.emitThreadPoolSize = [coder decodeIntegerForKey:SP_STR_PROP(emitThreadPoolSize)];
        self.byteLimitGet = [coder decodeIntegerForKey:SP_STR_PROP(byteLimitGet)];
        self.byteLimitPost = [coder decodeIntegerForKey:SP_STR_PROP(byteLimitPost)];
    }
    return self;
}

@end
