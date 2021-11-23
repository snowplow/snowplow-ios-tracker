//
// SPLifecycleEntity.m
// Snowplow
//
// Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.
//
// Copyright: Copyright © 2021 Snowplow Analytics.
// License: Apache License Version 2.0
//

#import "SPLifecycleEntity.h"

#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@interface SPLifecycleEntity ()
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, NSObject *> *parameters;
@end

@implementation SPLifecycleEntity

NSString * const kSPLifecycleEntitySchema = @"iglu:com.snowplowanalytics.mobile/application_lifecycle/jsonschema/1-0-0";
NSString * const kSPLifecycleEntityParamIndex = @"index";
NSString * const kSPLifecycleEntityParamIsVisible = @"isVisible";

- (instancetype)initWithIsVisible:(BOOL)isVisible {
    NSMutableDictionary<NSString *, NSObject *> *parameters = [NSMutableDictionary new];
    if (self = [super initWithSchema:kSPLifecycleEntitySchema andDictionary:parameters]) {
        self.parameters = parameters;
        [self.parameters setValue:@(isVisible) forKey:kSPLifecycleEntityParamIsVisible];
        // Set here further checks about the arguments.
        // e.g.: [SPUtilities checkArgument:([_name length] != 0) withMessage:@"Name cannot be empty."];
    }
    return self;
}

// --- Builder Methods

- (SPLifecycleEntity *)index:(NSNumber *)index {
    [self.parameters setValue:index forKey:kSPLifecycleEntityParamIndex];
    return self;
}

@end

