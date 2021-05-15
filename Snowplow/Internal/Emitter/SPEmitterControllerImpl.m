//
//  SPEmitterControllerImpl.m
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

#import "SPEmitterControllerImpl.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPEmitterConfigurationUpdate.h"


@implementation SPEmitterControllerImpl {
    id<SPRequestCallback> _requestCallback;
}

@synthesize bufferOption;
@synthesize byteLimitGet;
@synthesize byteLimitPost;
@synthesize emitRange;
@synthesize threadPoolSize;

// MARK: - Properties

- (void)setBufferOption:(SPBufferOption)bufferOption {
    self.dirtyConfig.bufferOption = bufferOption;
    self.dirtyConfig.bufferOptionUpdated = YES;
    [self.emitter setBufferOption:bufferOption];
}

- (SPBufferOption)bufferOption {
    return [self.emitter bufferOption];
}

- (void)setByteLimitGet:(NSInteger)byteLimitGet {
    self.dirtyConfig.byteLimitGet = byteLimitGet;
    self.dirtyConfig.byteLimitGetUpdated = YES;
    [self.emitter setByteLimitGet:byteLimitGet];
}

- (NSInteger)byteLimitGet {
    return [self.emitter byteLimitGet];
}

- (void)setByteLimitPost:(NSInteger)byteLimitPost {
    self.dirtyConfig.byteLimitPost = byteLimitPost;
    self.dirtyConfig.byteLimitPostUpdated = YES;
    [self.emitter setByteLimitPost:byteLimitPost];
}

- (NSInteger)byteLimitPost {
    return [self.emitter byteLimitPost];
}

- (void)setEmitRange:(NSInteger)emitRange {
    self.dirtyConfig.emitRange = emitRange;
    self.dirtyConfig.emitRangeUpdated = YES;
    [self.emitter setEmitRange:emitRange];
}

- (NSInteger)emitRange {
    return [self.emitter emitRange];
}

- (void)setThreadPoolSize:(NSInteger)emitThreadPoolSize {
    self.dirtyConfig.threadPoolSize = emitThreadPoolSize;
    self.dirtyConfig.threadPoolSizeUpdated = YES;
    [self.emitter setEmitThreadPoolSize:emitThreadPoolSize];
}

- (NSInteger)threadPoolSize {
    return [self.emitter emitThreadPoolSize];
}

- (void)setRequestCallback:(id<SPRequestCallback>)requestCallback {
    _requestCallback = requestCallback;
    [self.emitter setCallback:requestCallback];
}

- (id<SPRequestCallback>)requestCallback {
    return _requestCallback;
}

// MARK: - Methods

- (void)flush {
    [self.emitter flush];
}

- (NSInteger)dbCount {
    return [self.emitter getDbCount];
}

- (BOOL)isSending {
    return [self.emitter getSendingStatus];
}

// MARK: - Private methods

- (SPEmitter *)emitter {
    return self.serviceProvider.tracker.emitter;
}

- (SPEmitterConfigurationUpdate *)dirtyConfig {
    return self.serviceProvider.emitterConfigurationUpdate;
}

@end
