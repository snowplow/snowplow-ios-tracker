//
//  SPScreenView.m
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

#import "SPScreenView.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPScreenState.h"

@implementation SPScreenView {
    NSString * _name;
    NSString * _screenId;
    NSString * _type;
    NSString * _previousName;
    NSString * _previousId;
    NSString * _previousType;
    NSString * _transitionType;
    NSString * _viewControllerClassName;
    NSString * _topViewControllerClassName;
}

+ (instancetype)build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock {
    SPScreenView* event = [SPScreenView new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (instancetype)init {
    self = [super init];
    if (!_screenId) {
        _screenId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name screenId:(nullable NSUUID *)screenId {
    if (self = [super init]) {
        _screenId = [(screenId ?: [NSUUID UUID]) UUIDString];
        _name = name;
        [SPUtilities checkArgument:([_name length] != 0) withMessage:@"Name cannot be empty."];
        [SPUtilities checkArgument:([SPUtilities isUUIDString:_screenId]) withMessage:@"ScreenID has to be a valid UUID string."];
    }
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_name length] != 0) withMessage:@"Name cannot be empty."];
    [SPUtilities checkArgument:([SPUtilities isUUIDString:_screenId]) withMessage:@"ScreenID has to be a valid UUID string."];
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, type)
SP_BUILDER_METHOD(NSString *, previousName)
SP_BUILDER_METHOD(NSString *, previousId)
SP_BUILDER_METHOD(NSString *, previousType)
SP_BUILDER_METHOD(NSString *, transitionType)
SP_BUILDER_METHOD(NSString *, viewControllerClassName)
SP_BUILDER_METHOD(NSString *, topViewControllerClassName)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setScreenId:(NSString *)screenId {
    _screenId = screenId;
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

#pragma clang diagnostic pop

// --- Public Methods

- (NSString *)schema {
    return kSPScreenViewSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_name forKey:kSPSvName];
    [payload setValue:_screenId forKey:kSPSvScreenId];
    [payload setValue:_type forKey:kSPSvType];
    [payload setValue:_previousName forKey:kSPSvPreviousName];
    [payload setValue:_previousType forKey:kSPSvPreviousType];
    [payload setValue:_previousId forKey:kSPSvPreviousScreenId];
    [payload setValue:_transitionType forKey:kSPSvTransitionType];
    return payload;
}

- (SPScreenState *) getScreenState {
    return [[SPScreenState alloc] initWithName:_name
                                          type:_type
                                      screenId:_screenId
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
