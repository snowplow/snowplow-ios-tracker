//
//  SnowplowRequest.m
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

#import "SnowplowRequest.h"
#import <AFNetworking/AFNetworking.h>

@implementation SnowplowRequest

static int const kDefaultBufferTimeout = 60;
static int kDefaultBufferSize = 10;
static NSString *const kPayloadDataSchema = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0";

- (id) init {
    self = [super init];
    if (self) {
        _urlEndpoint = nil;
        _httpMethod = @"GET";
        _bufferTime = kDefaultBufferTimeout;
        _buffer = [[NSMutableArray alloc] init];
        _outQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method {
    self = [super init];
    if(self) {
        _urlEndpoint = url;
        _httpMethod = method;
        _bufferTime = kDefaultBufferTimeout;
        _buffer = [[NSMutableArray alloc] init];
        _outQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferOption:(enum SnowplowBufferOptions)option {
    self = [super init];
    if(self) {
        _urlEndpoint = url;
        _httpMethod = method;
        _bufferTime = option;
        _buffer = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    // Save buffer to database Issue #9
    self.urlEndpoint = nil;
    self.buffer = nil;
}

- (void) addToBuffer:(NSDictionary *)payload {
    [self.buffer addObject:payload];
    if([self.buffer count] == kDefaultBufferSize)
        [self flushBuffer];
}

- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload {
    [self.buffer addObject:spPayload.payload];
    if([self.buffer count] == _bufferTime)
        [self flushBuffer];
}

- (void) addToOutQueue:(NSDictionary *)payload {
    // Write to SQL db
}

- (void) popFromOutQueue {
    // Remove from SQL db
}

- (void) setBufferOption:(enum SnowplowBufferOptions) buffer {
    _bufferTime = buffer;
}

- (void) flushBuffer {
    //Empties the buffer and sends the contents to the collector
    if([self.httpMethod isEqual:@"POST"]) {
        NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
        [payload setObject:kPayloadDataSchema forKey:@"$schema"];
        [payload setObject:self.buffer forKey:@"data"];
        
        [self sendPostData:payload];
    } else if ([self.httpMethod isEqual:@"GET"]) {
        for (NSDictionary* event in self.buffer) {
            [self sendGetData:event];
        }
    } else {
        NSLog(@"Invalid httpMethod provided. Use \"POST\" or \"GET\".");
    }
}

- (void) sendPostData:(NSDictionary *)data {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // Add queue to next POST
    // Empty queue at the same time
    
    [manager POST:[self.urlEndpoint absoluteString] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //Add event to queue
    }];
    [self.buffer removeAllObjects];
}

- (void) sendGetData:(NSDictionary *)data {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager GET:[self.urlEndpoint absoluteString] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        // Remove from queue
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //Add event to queue
    }];
    [self.buffer removeObjectAtIndex:0];
}

@end
