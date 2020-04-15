//
//  SPSelfDescribingJson.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@interface SPSelfDescribingJson ()

@property (nonatomic, readwrite) NSObject *data;

@end

@implementation SPSelfDescribingJson

- (instancetype)initWithSchema:(NSString *)schema andData:(NSObject *)data {
    if (self = [super init]) {
        [self setSchema:schema];
        [self setDataWithObject:data];
    }
    return self;
}

- (instancetype)initWithSchema:(NSString *)schema andPayload:(SPPayload *)data {
    return [self initWithSchema:schema andData:[data getAsDictionary]];
}

- (instancetype)initWithSchema:(NSString *)schema andSelfDescribingJson:(SPSelfDescribingJson *)data {
    return [self initWithSchema:schema andData:[data getAsDictionary]];
}

- (void) setSchema:(NSString *)schema {
    [SPUtilities checkArgument:([schema length] != 0) withMessage:@"Schema cannot be nil or empty."];
    _schema = schema;
}

- (void) setDataWithObject:(NSObject *)data {
    self.data = data;
}

- (void) setDataWithPayload:(SPPayload *)data {
    return [self setDataWithObject:[data getAsDictionary]];
}

- (void) setDataWithSelfDescribingJson:(SPSelfDescribingJson *)data {
    return [self setDataWithObject:[data getAsDictionary]];
}

- (NSDictionary<NSString *, NSObject *> *) getAsDictionary {
    return @{
        kSPSchema: self.schema,
        kSPData: self.data,
    };
}

- (NSString *) description {
    return [[self getAsDictionary] description];
}

@end
