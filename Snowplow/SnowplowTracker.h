//
//  SnowplowTracker.h
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
#import "SnowplowRequest.h"

@interface SnowplowTracker : NSObject

extern NSString * const kSnowplowVendor;
extern Boolean const kDefaultEncodeBase64;
extern NSString * const kVersion;

@property (nonatomic) Boolean base64Encoded;
@property (nonatomic) NSString *trackerNamespace;
@property (nonatomic) SnowplowRequest *collector;
@property (nonatomic) NSMutableDictionary *standardData;

- (id) init;

- (id) initUsingNamespace:(NSString *)namespace
                    appId:(NSString *)appId
            base64Encoded:(Boolean)encoded
                collector:(SnowplowRequest *)collector;

- (void) setCollector:(SnowplowRequest *)collector;

- (void) setNamespace:(NSString *)trackerNamespace;

- (void) setAppId:(NSString *)appId;

- (void) setUserId:(NSString *)userId;

@end
