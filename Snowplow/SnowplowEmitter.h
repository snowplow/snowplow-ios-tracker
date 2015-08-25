//
//  SnowplowEmitter.h
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
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "RequestCallback.h"

@class SnowplowPayload;

enum SnowplowBufferOptions {
    SnowplowBufferInstant = 1,
    SnowplowBufferDefault = 10
};

@protocol SnowplowEmitterBuilder <NSObject>

- (void) setURL:(NSURL *)url;
- (void) setHttpMethod:(NSString *)method;
- (void) setBufferOption:(enum SnowplowBufferOptions)option;
- (void) setCallback:(id<RequestCallback>)callback;
- (void) setEmitRange:(NSInteger)emitRange;

@end

@interface SnowplowEmitter : NSObject <SnowplowEmitterBuilder>

@property BOOL                                  isSending;
@property (nonatomic, weak) id<RequestCallback> callback;

/**
 * Builds the Emitter using a build block of functions.
 */
+ (instancetype) build:(void(^)(id<SnowplowEmitterBuilder>builder))buildBlock;

/**
 * Initializes a newly allocated SnowplowEmitter
 * @return A SnowplowEmitter.
 */
- (id) init;

/**
 * Inserts a SnowplowPayload object into the buffer to be sent in the next POST requests. Use this in favour over addToBuffer:
 * @param spPayload A SnowployPayload containing a completed event to be added into the buffer.
 */
- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload;

/**
 * Empties the buffer of events using the respective HTTP request method in httpMethod.
 */
- (void) flushBuffer;

/**
 * Set the buffer to send the data instantly or after storing 10 events. Use the enum SnowplowBufferOptions to set the preferred option. By default, the tracker is set to SnowplowBufferDefault (10).
 * @param buffer Sets the buffer to SnowplowBufferDefault or SnowplowBufferInstant with SnowplowBufferOptions.
 */
- (void) setNewBufferOption:(enum SnowplowBufferOptions) buffer;

/**
 * Set the HTTP method to send the events.
 * @param method The HTTP request method that the tracker should send the event data (either GET or POST requests).
 */
- (void) setNewHttpMethod:(NSString *)method;

/**
 * Set the buffer time interval to send the events if the buffer hasn't reached it's max capacity yet.
 * @param userTime An int value in seconds
 */
- (void) setNewBufferTime:(int) userTime;

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
