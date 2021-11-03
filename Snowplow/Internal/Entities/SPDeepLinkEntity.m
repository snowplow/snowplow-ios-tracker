//
// SPDeepLinkEntity.m
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

#import "SPDeepLinkEntity.h"

#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@interface SPDeepLinkEntity ()
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, NSObject *> *parameters;
@end

@implementation SPDeepLinkEntity

NSString * const kSPDeepLinkSchema = @"iglu:com.snowplowanalytics.mobile/deep_link/jsonschema/1-0-0";
NSString * const kSPDeepLinkParamReferrer = @"referrer";
NSString * const kSPDeepLinkParamUrl = @"url";

- (instancetype)initWithUrl:(NSString *)url {
    NSMutableDictionary<NSString *, NSObject *> *parameters = [NSMutableDictionary new];
    if (self = [super initWithSchema:kSPDeepLinkSchema andDictionary:parameters]) {
        self.parameters = parameters;
        [self.parameters setValue:url forKey:kSPDeepLinkParamUrl];
        // Set here further checks about the arguments.
        // e.g.: [SPUtilities checkArgument:([_name length] != 0) withMessage:@"Name cannot be empty."];
    }
    return self;
}

// --- Builder Methods

- (SPDeepLinkEntity *)referrer:(NSString *)referrer {
    [self.parameters setValue:referrer forKey:kSPDeepLinkParamReferrer];
    return self;
}

@end

