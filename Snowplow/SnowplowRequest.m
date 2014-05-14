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

- (id)initWithURLRequest:(NSURL *)url withHTTPMethod:(NSString* )method {
    self = [super init];
    if(self) {
        self.urlRequest = [[NSMutableURLRequest alloc] init];
        self.url = url;
        self.httpMethod = method;
    }
    return self;
}

- (void)dealloc {
    [self.connection cancel];
    
    self.url = nil;
    self.connection = nil;
    self.response = nil;
    self.urlRequest = nil;
    self.error = nil;
}

- (void)sendRequest:(NSDictionary *)data {
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];

    NSLog(@"postData: %@", @[[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]]);
    NSLog(@"url: %@", self.url);
    [self.urlRequest setURL:self.url];
    [self.urlRequest setHTTPMethod:self.httpMethod];
    [self.urlRequest setHTTPBody:postData];
    [self.urlRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];

    self.connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];
}

@end
