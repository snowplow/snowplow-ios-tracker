//
//  SPSelfDescribingJson.m
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@implementation SPSelfDescribingJson {
    NSMutableDictionary * _payload;
}

- (id) initWithSchema:(NSString *)schema andData:(NSObject *)data {
    self = [super init];
    if(self) {
        _payload = [[NSMutableDictionary alloc] init];
        [self setSchema:schema];
        [self setDataWithObject:data];
    }
    return self;
}

- (id) initWithSchema:(NSString *)schema andPayload:(SPPayload *)data {
    self = [super init];
    if(self) {
        _payload = [[NSMutableDictionary alloc] init];
        [self setSchema:schema];
        [self setDataWithPayload:data];
    }
    return self;
}

- (id) initWithSchema:(NSString *)schema andSelfDescribingJson:(SPSelfDescribingJson *)data {
    self = [super init];
    if(self) {
        _payload = [[NSMutableDictionary alloc] init];
        [self setSchema:schema];
        [self setDataWithSelfDescribingJson:data];
    }
    return self;
}

- (void) setSchema:(NSString *)schema {
    [SPUtilities checkArgument:([schema length] != 0) withMessage:@"Schema cannot be nil or empty."];
    [_payload setObject:schema forKey:kSPSchema];
}

- (void) setDataWithObject:(NSObject *)data {
    if (data != nil) {
        [_payload setObject:data forKey:kSPData];
    }
}

- (void) setDataWithPayload:(SPPayload *)data {
    return [self setDataWithObject:[data getAsDictionary]];
}

- (void) setDataWithSelfDescribingJson:(SPSelfDescribingJson *)data {
    return [self setDataWithObject:[data getAsDictionary]];
}

- (NSDictionary *) getAsDictionary {
    return _payload;
}

- (NSString *) description {
    return [[self getAsDictionary] description];
}

@end
