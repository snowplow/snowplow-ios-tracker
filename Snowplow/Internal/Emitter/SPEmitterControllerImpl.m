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

@interface SPEmitterControllerImpl ()

@property (nonatomic, weak) SPEmitter *emitter;

@end


@implementation SPEmitterControllerImpl {
    id<SPRequestCallback> _requestCallback;
}

@synthesize bufferOption;
@synthesize byteLimitGet;
@synthesize byteLimitPost;
@synthesize emitRange;
@synthesize threadPoolSize;

- (instancetype)initWithEmitter:(SPEmitter *)emitter {
    if (self = [super init]) {
        self.emitter = emitter;
    }
    return self;
}

// MARK: - Properties

- (void)setBufferOption:(SPBufferOption)bufferOption {
    [self.emitter setBufferOption:bufferOption];
}

- (SPBufferOption)bufferOption {
    return [self.emitter bufferOption];
}

- (void)setByteLimitGet:(NSInteger)byteLimitGet {
    [self.emitter setByteLimitGet:byteLimitGet];
}

- (NSInteger)byteLimitGet {
    return [self.emitter byteLimitGet];
}

- (void)setByteLimitPost:(NSInteger)byteLimitPost {
    [self.emitter setByteLimitPost:byteLimitPost];
}

- (NSInteger)byteLimitPost {
    return [self.emitter byteLimitPost];
}

- (void)setEmitRange:(NSInteger)emitRange {
    [self.emitter setEmitRange:emitRange];
}

- (NSInteger)emitRange {
    return [self.emitter emitRange];
}

- (void)setThreadPoolSize:(NSInteger)emitThreadPoolSize {
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

@end
