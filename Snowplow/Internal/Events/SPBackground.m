//
//  SPBackground.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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

#import "SPBackground.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"

@implementation SPBackground {
    NSNumber * _index;
}

+ (instancetype)build:(void(^)(id<SPBackgroundBuilder> builder))buildBlock {
    SPBackground* event = [SPBackground new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithIndex:(NSNumber *)index {
    if (self = [super init]) {
        _index = index;
    }
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_index != nil) withMessage:@"Index cannot be nil or empty."];
}

// --- Builder Methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (void) setIndex:(NSNumber *)index {
    _index = index;
}

#pragma clang diagnostic pop

// --- Public Methods

- (NSString *)schema {
    return kSPBackgroundSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_index forKey:kSPBackgroundIndex];
    return payload;

}

@end
