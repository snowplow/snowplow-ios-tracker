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
#import "SnowplowPayload.h"

@interface SnowplowEmitter : NSObject

enum SnowplowBufferOptions {
    SnowplowBufferInstant = 1,
    SnowplowBufferDefault = 10
};

/**
 *  Initializes a newly allocated SnowplowEmitter
 *  @return A SnowplowEmitter.
 */
- (id) init;

/**
 *  Initializes a newly allocated SnowplowEmitter with a url sent via POST requests.
 *  @param url A url of the collector that events should be sent to.
 *  @return A SnowplowEmitter instance
 */
- (id) initWithURLRequest:(NSURL *)url;

/**
 *  Initializes a newly allocated SnowplowEmitter with a url and HTTP data transfer method.
 *  @param url A url of the collector that events should be sent to.
 *  @param method The HTTP request method that the tracker should send the event data (either GET or POST requests).
 *  @return A SnowplowEmitter instance
 */
- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method;

/**
 *  Initializes a newly allocated SnowplowEmitter with a url and HTTP data transfer method including the buffer time interval between every POST request is sent.
 *  @param url A url of the collector that events should be sent to.
 *  @param method The HTTP request method that the tracker should send the event data (either GET or POST requests).
 *  @param bufferOption The time interval to wait until the next POST should be sent.
 *  @return A SnowplowEmitter instance
 */
- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferOption:(enum SnowplowBufferOptions)option;

/**
 *  Set the buffer to send the data instantly or after storing 10 events. Use the enum SnowplowBufferOptions to set the preferred option. By default, the tracker is set to SnowplowBufferDefault (10).
 *  @param buffer Sets the buffer to SnowplowBufferDefault or SnowplowBufferInstant with SnowplowBufferOptions.
 */
- (void) setBufferOption:(enum SnowplowBufferOptions) buffer;

/**
 *  Set the HTTP method to send the events.
 *  @param method The HTTP request method that the tracker should send the event data (either GET or POST requests).
 */
- (void) setHttpMethod:(NSString *)method;

/**
 *  Set the buffer time interval to send the events if the buffer hasn't reached it's max capacity yet.
 *  @param userTime An int value in seconds
 */
- (void) setBufferTime:(int) userTime;

/**
 * Inserts a SnowplowPayload object into the buffer to be sent in the next POST requests. Use this in favour over addToBuffer:
 * @param spPayload A SnowployPayload containing a completed event to be added into the buffer.
 */
- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload;

/**
 * Empties the buffer of events using the respective HTTP request method in httpMethod.
 */
- (void) flushBuffer;

@end
