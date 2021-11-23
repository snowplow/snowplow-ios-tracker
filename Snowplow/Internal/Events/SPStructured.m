//
//  SPStructured.m
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
//  Copyright: Copyright © 2021 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPStructured.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"

@interface SPStructured ()

@property (nonatomic, readwrite) NSString *category;
@property (nonatomic, readwrite) NSString *action;

@end

@implementation SPStructured

- (instancetype)initWithCategory:(NSString *)category action:(NSString *)action {
    if (self = [super init]) {
        _category = category;
        _action = action;
        [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category cannot be nil or empty."];
        [SPUtilities checkArgument:([_action length] != 0) withMessage:@"Action cannot be nil or empty."];
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, label)
SP_BUILDER_METHOD(NSString *, property)
SP_BUILDER_METHOD(NSNumber *, value)

// --- Public Methods

- (NSString *)eventName {
    return kSPEventStructured;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_category forKey:kSPStuctCategory];
    [payload setValue:_action forKey:kSPStuctAction];
    [payload setValue:_label forKey:kSPStuctLabel];
    [payload setValue:_property forKey:kSPStuctProperty];
    if (_value) [payload setObject:[NSString stringWithFormat:@"%.17g", [_value doubleValue]] forKey:kSPStuctValue];
    return payload;
}

@end
