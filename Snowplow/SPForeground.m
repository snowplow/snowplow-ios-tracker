//
//  SPForeground.m
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

#import "SPForeground.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPSelfDescribingJson.h"

@implementation SPForeground {
    NSNumber * _index;
}

+ (instancetype) build:(void(^)(id<SPForegroundBuilder>builder))buildBlock {
    SPForeground* event = [SPForeground new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_index != nil) withMessage:@"Index cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setIndex:(NSNumber *)index {
    _index = index;
}

// --- Public Methods

- (NSString *)schema {
    return kSPForegroundSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_index forKey:kSPForegroundIndex];
    return payload;
}

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    [event setObject:_index forKey:kSPForegroundIndex];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPForegroundSchema andData:event];
}

@end
