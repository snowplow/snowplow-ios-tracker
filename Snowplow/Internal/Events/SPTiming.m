//
//  SPTiming.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

#import "SPTiming.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPSelfDescribingJson.h"


@interface SPTiming ()

@property (nonatomic, readwrite) NSString *category;
@property (nonatomic, readwrite) NSString *variable;
@property (nonatomic, readwrite) NSNumber *timing;

@end

@implementation SPTiming

- (instancetype)initWithCategory:(NSString *)category variable:(NSString *)variable timing:(NSNumber *)timing {
    if (self = [super init]) {
        _category = category;
        _variable = variable;
        _timing = timing;
        [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category cannot be nil or empty."];
        [SPUtilities checkArgument:([_variable length] != 0) withMessage:@"Variable cannot be nil or empty."];
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, label)

// --- Public Methods

- (NSString *)schema {
    return kSPUserTimingsSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_category forKey:kSPUtCategory];
    [payload setValue:_variable forKey:kSPUtVariable];
    [payload setValue:_timing forKey:kSPUtTiming];
    [payload setValue:_label forKey:kSPUtLabel];
    return payload;
}

@end
