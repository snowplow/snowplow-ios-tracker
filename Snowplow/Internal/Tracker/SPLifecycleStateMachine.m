//
//  SPLifecycleStateMachine.m
//  Snowplow
//
// Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
// License: Apache License Version 2.0
//

#import "SPLifecycleStateMachine.h"
#import "SPLifecycleState.h"
#import "SPBackground.h"
#import "SPForeground.h"
#import "SPLifecycleEntity.h"

@implementation SPLifecycleStateMachine

- (NSArray<NSString *> *)subscribedEventSchemasForTransitions {
    return @[kSPBackgroundSchema, kSPForegroundSchema];
}

- (id<SPState>)transitionFromEvent:(SPEvent *)event state:(id<SPState>)currentState {
    if ([event isKindOfClass:SPForeground.class]) {
        SPForeground *e = (SPForeground *)event;
        return [[SPLifecycleState alloc] initAsForegroundWithIndex:e.index];
    }
    if ([event isKindOfClass:SPBackground.class]) {
        SPBackground *e = (SPBackground *)event;
        return [[SPLifecycleState alloc] initAsBackgroundWithIndex:e.index];
    }
    return nil;
}

- (NSArray<NSString *> *)subscribedEventSchemasForEntitiesGeneration {
    return @[@"*"];
}

- (NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    if (!state) return @[[[[SPLifecycleEntity alloc] initWithIsVisible:YES] index:0]];
    SPLifecycleState *s = (SPLifecycleState *)state;
    return @[[[[SPLifecycleEntity alloc] initWithIsVisible:s.isForeground] index:s.index]];
}

- (nonnull NSArray<NSString *> *)subscribedEventSchemasForPayloadUpdating {
    return @[];
}

- (NSDictionary<NSString *,NSObject *> *)payloadValuesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    return nil;
}

@end
