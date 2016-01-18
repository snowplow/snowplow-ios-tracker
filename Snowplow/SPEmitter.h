//
//  SPEmitter.h
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPRequestCallback.h"

@class SPPayload;
@class SPEventStore;

enum SPRequestOptions {
    SPRequestGet,
    SPRequestPost
};

enum SPProtocol {
    SPHttp,
    SPHttps
};

@protocol SPEmitterBuilder <NSObject>

- (void) setUrlEndpoint:(NSString *)urlEndpoint;
- (void) setHttpMethod:(enum SPRequestOptions)method;
- (void) setProtocol:(enum SPProtocol)protocol;
- (void) setCallback:(id<SPRequestCallback>)callback;
- (void) setEmitRange:(NSInteger)emitRange;
- (void) setEmitThreadPoolSize:(NSInteger)emitThreadPoolSize;
- (void) setByteLimitGet:(NSInteger)byteLimitGet;
- (void) setByteLimitPost:(NSInteger)byteLimitPost;

@end

@interface SPEmitter : NSObject <SPEmitterBuilder>

@property (readonly, nonatomic) enum    SPRequestOptions      httpMethod;
@property (readonly, nonatomic) enum    SPProtocol            protocol;
@property (readonly, nonatomic, retain) NSURL *               urlEndpoint;
@property (readonly, nonatomic)         NSInteger             emitRange;
@property (readonly, nonatomic)         NSInteger             emitThreadPoolSize;
@property (readonly, nonatomic)         NSInteger             byteLimitGet;
@property (readonly, nonatomic)         NSInteger             byteLimitPost;
@property (readonly, nonatomic, weak)   id<SPRequestCallback> callback;

/**
 * Builds the Emitter using a build block of functions.
 */
+ (instancetype) build:(void(^)(id<SPEmitterBuilder>builder))buildBlock;

/**
 * Initializes a newly allocated SnowplowEmitter
 * @return A SnowplowEmitter.
 */
- (id) init;

/**
 * Inserts a SnowplowPayload object into the buffer to be sent in the next POST requests. Use this in favour over addToBuffer:
 * @param spPayload A SnowployPayload containing a completed event to be added into the buffer.
 */
- (void) addPayloadToBuffer:(SPPayload *)spPayload;

/**
 * Empties the buffer of events using the respective HTTP request method in httpMethod.
 */
- (void) flushBuffer;

/**
 * Sets up a timer to automatically initiate sending of events at pre-determined intervals.
 */
- (void) startTimerFlush;

/**
 * Stops the Future Buffer Flush function.
 */
- (void) stopTimerFlush;

/**
 * Returns the total Database Count
 * @return returns the total DB Count
 */
- (NSUInteger) getDbCount;

/**
 * Returns whether the emitter is currently sending
 * @return the sending state as a boolean
 */
- (BOOL) getSendingStatus;

@end
