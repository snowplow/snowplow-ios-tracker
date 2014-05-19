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

@implementation SnowplowRequest

static int const kDefaultBufferTimeout = 60;
static int const kDefaultBufferSize = 10;
static NSString *const kPayloadDataSchema = @"com.snowplowanalytics/payload_data/jsonschema/1-0-0";

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method {
    self = [super init];
    if(self) {
        self.urlRequest = [[NSMutableURLRequest alloc] init];
        self.urlEndpoint = url;
        self.httpMethod = method;
        self.buffer = [[NSMutableArray alloc] init];
        self.bufferTime = kDefaultBufferTimeout;
    }
    return self;
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferTime:(int)buffer_time {
    self = [super init];
    if(self) {
        self.urlRequest = [[NSMutableURLRequest alloc] init];
        self.urlEndpoint = url;
        self.bufferTime = buffer_time;
        self.buffer = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    [self.connection cancel];
    
    self.urlEndpoint = nil;
    self.connection = nil;
    self.response = nil;
    self.urlRequest = nil;
    self.error = nil;
    self.buffer = nil;
}

- (void) addToBuffer:(NSDictionary *)payload {
    if([self.buffer count] == kDefaultBufferSize)
        [self flushBuffer];
    [self.buffer addObject:payload];
}

- (void) flushBuffer {
    //Empties the buffer and sends the contents to the collector
    if([self.httpMethod isEqual:@"POST"]) {
        NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
        [payload setObject:kPayloadDataSchema forKey:@"schema"];
        [payload setObject:self.buffer forKey:@"data"];
        
        // TESTING ONLY
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
        NSString *somejson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Our JSON data:\n%@", somejson);
        // END OF TESTING
        
        [self sendPostData:jsonData];
    } else if ([self.httpMethod isEqual:@"GET"]) {
        
    } else {
        NSLog(@"Invalid httpMethod provided. Use \"POST\" or \"GET\".");
    }
}

- (void) sendPostData:(NSData *)data {
    NSLog(@"postData: %@", @[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]);
    NSLog(@"url: %@", self.urlEndpoint);
    [self.urlRequest setURL:self.urlEndpoint];
    [self.urlRequest setHTTPMethod:self.httpMethod];
    [self.urlRequest setHTTPBody:data];
    [self.urlRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];
}

@end
