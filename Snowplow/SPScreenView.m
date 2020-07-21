//
//  SPScreenView.m
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

#import "SPScreenView.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPScreenState.h"

@implementation SPScreenView {
    NSString * _name;
    NSString * _id;
    NSString * _type;
    NSString * _previousName;
    NSString * _previousId;
    NSString * _previousType;
    NSString * _transitionType;
    NSString * _viewControllerClassName;
    NSString * _topViewControllerClassName;
}

+ (instancetype) build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock {
    SPScreenView* event = [SPScreenView new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    if (!_id) {
        _id = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_name length] != 0) withMessage:@"Name cannot be empty."];
    [SPUtilities checkArgument:([SPUtilities isUUIDString:_id]) withMessage:@"ScreenID has to be a valid UUID string."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setScreenId:(NSString *)screenId {
    _id = screenId;
}

- (void) setType:(NSString *)type {
    _type = type;
}

- (void) setPreviousScreenName:(NSString *)name {
    _previousName = name;
}

- (void) setPreviousScreenId:(NSString *)screenId {
    _previousId = screenId;
}

- (void) setPreviousScreenType:(NSString *)type {
    _previousType = type;
}

- (void) setTransitionType:(NSString *)type {
    _transitionType = type;
}

- (void) setViewControllerClassName:(NSString *)className {
    _viewControllerClassName = className;
}

- (void) setTopViewControllerClassName:(NSString *)className {
    _topViewControllerClassName = className;
}

// --- Public Methods

- (NSString *)schema {
    return kSPScreenViewSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_name forKey:kSPSvName];
    [payload setValue:_id forKey:kSPSvScreenId];
    [payload setValue:_type forKey:kSPSvType];
    [payload setValue:_previousName forKey:kSPSvPreviousName];
    [payload setValue:_previousType forKey:kSPSvPreviousType];
    [payload setValue:_previousId forKey:kSPSvPreviousScreenId];
    [payload setValue:_transitionType forKey:kSPSvTransitionType];
    return payload;
}

- (SPSelfDescribingJson *) getPayload {
    SPPayload * payload = [[SPPayload alloc] init];
    [payload addValueToPayload:_name forKey:kSPSvName];
    [payload addValueToPayload:_type forKey:kSPSvType];
    [payload addValueToPayload:_id forKey:kSPSvScreenId];
    [payload addValueToPayload:_previousName forKey:kSPSvPreviousName];
    [payload addValueToPayload:_previousType forKey:kSPSvPreviousType];
    [payload addValueToPayload:_previousId forKey:kSPSvPreviousScreenId];
    [payload addValueToPayload:_transitionType forKey:kSPSvTransitionType];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPScreenViewSchema
                                             andPayload:payload];
}

- (SPScreenState *) getScreenState {
    return [[SPScreenState alloc] initWithName:_name
                                          type:_type
                                      screenId:_id
                                transitionType:_transitionType
                    topViewControllerClassName:_topViewControllerClassName
                       viewControllerClassName:_viewControllerClassName];
}

- (BOOL) updateWithPreviousState:(SPScreenState *)previousState {
    if (![previousState isValid]) {
        return NO;
    }
    _previousName = previousState.name;
    _previousId = previousState.screenId;
    _previousType = previousState.type;
    return YES;
}

@end
