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
static int const kDefaultBufferSize = 10;
static NSString *const kPayloadDataSchema = @"com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0";

- (id) init {
    self = [super init];
    if (self) {
        _urlEndpoint = nil;
        _bufferTime = kDefaultBufferTimeout;
    }
    return self;
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method {
    self = [super init];
    if(self) {
        _urlEndpoint = url;
        _httpMethod = method;
        _buffer = [[NSMutableArray alloc] init];
        _bufferTime = kDefaultBufferTimeout;
    }
    return self;
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferTime:(int)buffer_time {
    self = [super init];
    if(self) {
        _urlEndpoint = url;
        _bufferTime = buffer_time;
        _buffer = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    self.urlEndpoint = nil;
    self.buffer = nil;
}

- (void) addToBuffer:(NSDictionary *)payload {
    if([self.buffer count] == kDefaultBufferSize)
        [self flushBuffer];
    [self.buffer addObject:payload];
}

- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload {
    if([self.buffer count] == kDefaultBufferSize)
        [self flushBuffer];
    [self.buffer addObject:spPayload.payload];

}

- (void) flushBuffer {
    //Empties the buffer and sends the contents to the collector
    if([self.httpMethod isEqual:@"POST"]) {
        NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
        [payload setObject:kPayloadDataSchema forKey:@"schema"];
        [payload setObject:self.buffer forKey:@"data"];
        
        [self sendPostData:payload];
    } else if ([self.httpMethod isEqual:@"GET"]) {
        for (NSDictionary* event in self.buffer) {
            [self sendGetData:event];
        }
        [self.buffer removeAllObjects];
    } else {
        NSLog(@"Invalid httpMethod provided. Use \"POST\" or \"GET\".");
    }
}

- (void) sendPostData:(NSDictionary *)data {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[self.urlEndpoint absoluteString] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //Handle POST error response
    }];
}

- (void) sendGetData:(NSDictionary *)data {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager GET:[self.urlEndpoint absoluteString] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //Handle GET error response
    }];
}

@end
