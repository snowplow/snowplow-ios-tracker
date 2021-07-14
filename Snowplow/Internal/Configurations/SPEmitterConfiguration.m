//
//  SPEmitterConfiguration.m
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

#import "SPEmitterConfiguration.h"

@implementation SPEmitterConfiguration

@synthesize bufferOption;
@synthesize byteLimitGet;
@synthesize byteLimitPost;
@synthesize emitRange;
@synthesize threadPoolSize;
@synthesize requestCallback;

- (instancetype)init {
    if (self = [super init]) {
        self.bufferOption = SPBufferOptionSingle;
        self.emitRange = 150;
        self.threadPoolSize = 15;
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
SP_BUILDER_METHOD(NSInteger, threadPoolSize)
SP_BUILDER_METHOD(NSInteger, byteLimitGet)
SP_BUILDER_METHOD(NSInteger, byteLimitPost)
SP_BUILDER_METHOD(id<SPRequestCallback>, requestCallback)

SP_BUILDER_METHOD(id<SPEventStore>, eventStore)

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPEmitterConfiguration *copy = [[SPEmitterConfiguration allocWithZone:zone] init];
    copy.bufferOption = self.bufferOption;
    copy.emitRange = self.emitRange;
    copy.threadPoolSize = self.threadPoolSize;
    copy.byteLimitGet = self.byteLimitGet;
    copy.byteLimitPost = self.byteLimitPost;
    copy.requestCallback = self.requestCallback;
    copy.eventStore = self.eventStore;
    return copy;
}

// MARK: - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeInteger:self.bufferOption forKey:SP_STR_PROP(bufferOption)];
    [coder encodeInteger:self.emitRange forKey:SP_STR_PROP(emitRange)];
    [coder encodeInteger:self.threadPoolSize forKey:SP_STR_PROP(threadPoolSize)];
    [coder encodeInteger:self.byteLimitGet forKey:SP_STR_PROP(byteLimitGet)];
    [coder encodeInteger:self.byteLimitPost forKey:SP_STR_PROP(byteLimitPost)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.bufferOption = [coder decodeIntegerForKey:SP_STR_PROP(bufferOption)];
        self.emitRange = [coder decodeIntegerForKey:SP_STR_PROP(emitRange)];
        self.threadPoolSize = [coder decodeIntegerForKey:SP_STR_PROP(threadPoolSize)];
        self.byteLimitGet = [coder decodeIntegerForKey:SP_STR_PROP(byteLimitGet)];
        self.byteLimitPost = [coder decodeIntegerForKey:SP_STR_PROP(byteLimitPost)];
    }
    return self;
}

@end
