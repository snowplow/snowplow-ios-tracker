//
//  SnowplowRequest.h
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
#import <AFNetworking/AFNetworking.h>
#import "SnowplowPayload.h"

@interface SnowplowRequest : NSObject

@property (nonatomic) NSURL *urlEndpoint;
@property (nonatomic) NSString *httpMethod;
@property (nonatomic) int bufferTime;
@property (atomic) NSMutableArray *buffer;

/**
 *  Initializes a newly allocated SnowplowRequest
 *  @return A SnowplowRequest.
 */
- (id) init;

/**
 *  Initializes a newly allocated SnowplowRequest with a url and HTTP data transfer method.
 *  @param url A url of the collector that events should be sent to.
 *  @param method The HTTP request method that the tracker should send the event data (either GET or POST requests).
 *  @return A SnowplowRequest
 */
- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method;

/**
 *  Initializes a newly allocated SnowplowRequest with a url and HTTP data transfer method including the buffer time interval between every POST request is sent.
 *  @param url A url of the collector that events should be sent to.
 *  @param method The HTTP request method that the tracker should send the event data (either GET or POST requests).
 *  @param bufferTime The time interval to wait until the next POST should be sent.
 */
- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferTime:(int)buffer_time;

/**
 * Inserts a dictionary of data into the buffer for the class.
 * @param payload A dictionary of data to make up an event that will be sent via the buffer.
 */
- (void) addToBuffer:(NSDictionary *)payload;

/**
 * Inserts a SnowplowPayload object into the buffer to be sent in the next POST requests. Use this in favour over addToBuffer:
 * @param spPayload A SnowployPayload containing a completed event to be added into the buffer.
 */
- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload;

/**
 * Sends a dictionary of data to the urlEndpoint via a JSON POST request.
 * @param A dictionary of event data.
 */
- (void) sendPostData:(NSDictionary *)data;

/**
 * Empties the buffer of events using the respective HTTP request method in httpMethod.
 */
- (void) flushBuffer;

@end
