//
//  SPTiming.m
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
//  Authors: Alex Benini
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPTiming.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPSelfDescribingJson.h"

@implementation SPTiming {
    NSString * _category;
    NSString * _variable;
    NSNumber * _timing;
    NSString * _label;
}

+ (instancetype) build:(void(^)(id<SPTimingBuilder>builder))buildBlock {
    SPTiming* event = [SPTiming new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category cannot be nil or empty."];
    [SPUtilities checkArgument:([_variable length] != 0) withMessage:@"Variable cannot be nil or empty."];
    [SPUtilities checkArgument:(_timing != nil) withMessage:@"Timing cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setCategory:(NSString *)category {
    _category = category;
}

- (void) setVariable:(NSString *)variable {
    _variable = variable;
}

- (void) setTiming:(NSInteger)timing {
    _timing = [NSNumber numberWithLong:timing];
}

- (void) setLabel:(NSString *)label {
    _label = label;
}

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

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_category forKey:kSPUtCategory];
    [event setObject:_variable forKey:kSPUtVariable];
    [event setObject:_timing forKey:kSPUtTiming];
    if (_label != nil) {
        [event setObject:_label forKey:kSPUtLabel];
    }

    return [[SPSelfDescribingJson alloc] initWithSchema:kSPUserTimingsSchema
                                                andData:event];
}

@end
