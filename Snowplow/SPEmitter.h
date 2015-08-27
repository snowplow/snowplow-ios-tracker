//
//  SPEmitter.h
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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

enum SPBufferOptions {
    SPBufferInstant = 1,
    SPBufferDefault = 10
};

enum SPRequestOptions {
    SPRequestGet,
    SPRequestPost
};

@protocol SPEmitterBuilder <NSObject>

- (void) setURL:(NSURL *)url;
- (void) setHttpMethod:(enum SPRequestOptions)method;
- (void) setBufferOption:(enum SPBufferOptions)option;
- (void) setCallback:(id<SPRequestCallback>)callback;
- (void) setEmitRange:(NSInteger)emitRange;
- (void) setEmitThreadPoolSize:(NSInteger)emitThreadPoolSize;

@end

@interface SPEmitter : NSObject <SPEmitterBuilder>

@property BOOL                                    isSending;
@property (nonatomic, weak) id<SPRequestCallback> callback;

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
 * Set the buffer to send the data instantly or after storing 10 events. Use the enum SnowplowBufferOptions to set the preferred option. By default, the tracker is set to SnowplowBufferDefault (10).
 * @param buffer Sets the buffer to SnowplowBufferDefault or SnowplowBufferInstant with SnowplowBufferOptions.
 */
- (void) setNewBufferOption:(enum SPBufferOptions)buffer;

/**
 * Set the HTTP method to send the events.
 * @param method The HTTP request method that the tracker should send the event data (either GET or POST requests).
 */
- (void) setNewHttpMethod:(enum SPRequestOptions)method;

/**
 * Set the buffer time interval to send the events if the buffer hasn't reached it's max capacity yet.
 * @param userTime An int value in seconds
 */
- (void) setNewBufferTime:(NSInteger) userTime;

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
