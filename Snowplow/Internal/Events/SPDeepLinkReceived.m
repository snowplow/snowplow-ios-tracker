//
// SPDeepLinkReceived.m
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

#import "SPDeepLinkReceived.h"

#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@interface SPDeepLinkReceived ()

@property (nonatomic, nonnull, readwrite) NSString *url;

@end

@implementation SPDeepLinkReceived

NSString * const kSPDeepLinkReceivedSchema = @"iglu:com.snowplowanalytics.mobile/deep_link_received/jsonschema/1-0-0";
NSString * const kSPDeepLinkReceivedParamReferrer = @"referrer";
NSString * const kSPDeepLinkReceivedParamUrl = @"url";

- (instancetype)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        _url = url;
        // Set here further checks about the arguments.
        // e.g.: [SPUtilities checkArgument:([_name length] != 0) withMessage:@"Name cannot be empty."];
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, referrer)

// --- Tracker Methods

- (NSString *)schema {
    return kSPDeepLinkReceivedSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_referrer forKey:kSPDeepLinkReceivedParamReferrer];
    [payload setValue:_url forKey:kSPDeepLinkReceivedParamUrl];
    return payload;
}

@end

