//
//  SPSelfDescribingJson.m
//  Snowplow
//
//  Copyright (c) 2013-2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@implementation SPSelfDescribingJson

- (id)copyWithZone:(NSZone *)zone {
    SPSelfDescribingJson * copy = [[[self class] alloc] init];
    [copy setPayload:_payload];
    return copy;
}

- (id) init {
    return [self initWithSchema:@"" andData:[NSMutableDictionary dictionary]];
}

- (id) initWithSchema:(NSString *)schema andData:(NSObject *)data {
    self = [super init];
    if (self) {
        _payload = [[NSMutableDictionary alloc] init];
        [self setSchema:schema];
        [self setDataWithObject:data];
        return self;
    }
    return nil;
}

- (id) initWithSchema:(NSString *)schema andPayload:(SPPayload *)data {
    return [self initWithSchema:schema andData:[data getAsDictionary]];
}

- (id) initWithSchema:(NSString *)schema andSelfDescribingJson:(SPSelfDescribingJson *)data {
    return [self initWithSchema:schema andData:[data getAsDictionary]];
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

- (BOOL) isEqual:(id)other {
    return ([other isKindOfClass: [SPSelfDescribingJson class]] &&
            [_payload isEqualToDictionary:[other getAsDictionary]]);
}

- (NSUInteger) hash {
    NSUInteger hash = 0;
    if (_payload && [_payload objectForKey:kSPSchema]) {
        hash += [[_payload objectForKey:kSPSchema] hash];
    }
    return hash;
}

@end
