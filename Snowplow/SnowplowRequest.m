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
#import "SnowplowEventStore.h"
#import "SnowplowUtils.h"
#import <AFNetworking/AFNetworking.h>

@implementation SnowplowRequest {
    NSURL *                     _urlEndpoint;
    NSString *                  _httpMethod;
    NSMutableArray *            _buffer;
    NSMutableArray *            _outQueue;
    enum SnowplowBufferOptions  _bufferTime;
    NSTimer *                   _timer;
    SnowplowEventStore *        _db;
}

static int       const kDefaultBufferTimeout = 60;
static NSString *const kPayloadDataSchema    = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0";

- (id) init {
    self = [super init];
    if (self) {
        _urlEndpoint = nil;
        _httpMethod = @"GET";
        _bufferTime = kDefaultBufferTimeout;
        _buffer = [[NSMutableArray alloc] init];
        _outQueue = [[NSMutableArray alloc] init];
        _db = [[SnowplowEventStore alloc] initWithAppId:[SnowplowUtils getAppId]];
        _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(flushBuffer) userInfo:nil repeats:YES];
    }
    return self;
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method {
    self = [super init];
    if(self) {
        _urlEndpoint = url;
        _httpMethod = method;
        _bufferTime = SnowplowBufferDefault;
        _buffer = [[NSMutableArray alloc] init];
        _outQueue = [[NSMutableArray alloc] init];
        _db = [[SnowplowEventStore alloc] initWithAppId:[SnowplowUtils getAppId]];
        _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(flushBuffer) userInfo:nil repeats:YES];
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
        _db = [[SnowplowEventStore alloc] initWithAppId:[SnowplowUtils getAppId]];
        _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(flushBuffer) userInfo:nil repeats:YES];
    }
    return self;
}

- (void) dealloc {
    // Save buffer to database Issue #9
    _urlEndpoint = nil;
    _buffer = nil;
}

- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload {
    [_buffer addObject:spPayload.getPayloadAsDictionary];
    if([_buffer count] == _bufferTime)
        [self flushBuffer];
}

- (void) addToOutQueue:(SnowplowPayload *)payload {
    [_db insertEvent:payload];
}

- (void) popFromOutQueue {
    // Remove from SQL db
}

- (void) setBufferOption:(enum SnowplowBufferOptions) buffer {
    _bufferTime = buffer;
}

- (void) flushBuffer {
    NSLog(@"Flushing buffer..");
    // Avoid calling flush to send an empty buffer
    if ([_buffer count] == 0) {
        return;
    }
    
    //Empties the buffer and sends the contents to the collector
    if([_httpMethod isEqual:@"POST"]) {
        NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
        [payload setValue:kPayloadDataSchema forKey:@"$schema"];
        [payload setValue:_buffer forKey:@"data"];
        
        [self sendPostData:payload];
    } else if ([_httpMethod isEqual:@"GET"]) {
        for (NSDictionary* event in _buffer) {
            [self sendGetData:event];
        }
    } else {
        NSLog(@"Invalid httpMethod provided. Use \"POST\" or \"GET\".");
    }
    [_buffer removeAllObjects];
}

- (void) sendPostData:(NSDictionary *)data {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // Add queue to next POST
    // Empty queue at the same time
    
    [manager POST:[_urlEndpoint absoluteString] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //Add event to queue
    }];
//    [self.buffer removeAllObjects];
}

- (void) sendGetData:(NSDictionary *)data {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager GET:[_urlEndpoint absoluteString] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        // Remove from queue
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //Add event to queue
    }];
}

@end
