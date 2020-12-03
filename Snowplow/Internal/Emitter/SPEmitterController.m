//
//  SPEmitterController.m
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEmitterController.h"

@interface SPEmitterController ()

@property SPEmitter *emitter;

@end


@implementation SPEmitterController

@synthesize bufferOption;
@synthesize byteLimitGet;
@synthesize byteLimitPost;
@synthesize emitRange;
@synthesize emitThreadPoolSize;

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

- (void)setEmitThreadPoolSize:(NSInteger)emitThreadPoolSize {
    [self.emitter setEmitThreadPoolSize:emitThreadPoolSize];
}

- (NSInteger)emitThreadPoolSize {
    return [self.emitter emitThreadPoolSize];
}

// MARK: - Methods

- (void)flush {
    [self.emitter flushBuffer];
}

@end
