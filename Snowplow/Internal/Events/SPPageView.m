//
//  SPPageView.m
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

#import "SPPageView.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"

@implementation SPPageView {
    NSString * _pageUrl;
    NSString * _pageTitle;
    NSString * _referrer;
}

+ (instancetype)build:(void(^)(id<SPPageViewBuilder> builder))buildBlock {
    SPPageView* event = [SPPageView new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithPageUrl:(NSString *)pageUrl {
    if (self = [super init]) {
        _pageUrl = pageUrl;
        [SPUtilities checkArgument:([_pageUrl length] != 0) withMessage:@"PageURL cannot be nil or empty."];
    }
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_pageUrl length] != 0) withMessage:@"PageURL cannot be nil or empty."];
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, pageTitle)
SP_BUILDER_METHOD(NSString *, referrer)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (void) setPageUrl:(NSString *)pageUrl {
    _pageUrl = pageUrl;
}

- (void) setPageTitle:(NSString *)pageTitle {
    _pageTitle = pageTitle;
}

- (void) setReferrer:(NSString *)referrer {
    _referrer = referrer;
}

#pragma clang diagnostic pop

// --- Public Methods

- (NSString *)name {
    return kSPEventPageView;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_pageUrl forKey:kSPPageUrl];
    [payload setValue:_pageTitle forKey:kSPPageTitle];
    [payload setValue:_referrer forKey:kSPPageRefr];
    return payload;
}

@end
