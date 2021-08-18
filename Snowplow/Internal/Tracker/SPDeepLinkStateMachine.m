//
//  SPDeepLinkStateMachine.m
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPDeepLinkStateMachine.h"
#import "SPDeepLinkReceived.h"
#import "SPDeepLinkState.h"
#import "SPDeepLinkEntity.h"

@implementation SPDeepLinkStateMachine

/*
 States: Init, DeepLink, ReadyForOutput
 Events: DL (DeepLinkReceived), SV (ScreenView)
 Transitions:
  - Init (DL) DeepLink
  - DeepLink (SV) ReadyForOutput
  - ReadyForOutput (DL) DeepLink
  - ReadyForOutput (SV) Init
 Entity Generation:
  - ReadyForOutput
 */

- (nonnull NSArray<NSString *> *)subscribedEventSchemasForTransitions {
    return @[kSPDeepLinkReceivedSchema, kSPScreenViewSchema];
}

- (nonnull NSArray<NSString *> *)subscribedEventSchemasForEntitiesGeneration {
    return @[kSPScreenViewSchema];
}

- (nonnull NSArray<NSString *> *)subscribedEventSchemasForPayloadUpdating {
    return @[];
}

- (id<SPState>)transitionFromEvent:(SPEvent *)event state:(id<SPState>)state {
    if ([event isKindOfClass:SPDeepLinkReceived.class]) {
        SPDeepLinkReceived *dlEvent = (SPDeepLinkReceived *)event;
        return [[SPDeepLinkState alloc] initWithUrl:dlEvent.url referrer:dlEvent.referrer];
    } else {
        if (!state) {
            return nil;
        }
        SPDeepLinkState *dlState = (SPDeepLinkState *)state;
        if (dlState.readyForOutput) {
            return nil;
        }
        SPDeepLinkState *currentState = [[SPDeepLinkState alloc] initWithUrl:dlState.url referrer:dlState.referrer];
        currentState.readyForOutput = YES;
        return currentState;
    }
}

- (NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    if (!state) return nil;
    SPDeepLinkState *deepLinkState = (SPDeepLinkState *)state;
    if (!deepLinkState.readyForOutput) return nil;
    SPDeepLinkEntity *entity = [[[SPDeepLinkEntity alloc] initWithUrl:deepLinkState.url]
                          referrer:deepLinkState.referrer];
    return @[entity];
}

- (NSDictionary<NSString *,NSObject *> *)payloadValuesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    return nil;
}

@end
