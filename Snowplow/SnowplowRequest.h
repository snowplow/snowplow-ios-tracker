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

@interface SnowplowRequest : NSObject

@property (nonatomic) NSURL *urlEndpoint;
@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSHTTPURLResponse *response;
@property (nonatomic) id responseJSON;
@property (nonatomic) NSMutableURLRequest *urlRequest;
@property (nonatomic) NSError *error;
@property (nonatomic) NSString *httpMethod;
@property (nonatomic) int bufferTime;
@property (atomic) NSMutableArray *buffer;

//def __init__(self, endpoint, protocol="http", port=None, method="get", buffer_size=None, on_success=None, on_failure=None):

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method;

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferTime:(int)buffer_time;

- (void) addToBuffer:(NSDictionary *)payload;

- (void) sendPostData:(NSData *)data;

- (void) flushBuffer;

@end
