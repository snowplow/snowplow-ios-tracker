//
//  SPScreenStateMachine.m
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

#import "SPScreenStateMachine.h"
#import "SPScreenView.h"
#import "SPScreenState.h"
#import "SPUtilities.h"

@implementation SPScreenStateMachine

- (NSArray<NSString *> *)subscribedEventSchemasForTransitions {
    return @[kSPScreenViewSchema];
}

- (NSArray<NSString *> *)subscribedEventSchemasForEntitiesGeneration {
    return @[@"*"];
}

- (NSArray<NSString *> *)subscribedEventSchemasForPayloadUpdating {
    return @[kSPScreenViewSchema];
}

- (id<SPState>)transitionFromEvent:(SPEvent *)event state:(id<SPState>)currentState {
    SPScreenView *screenView = (SPScreenView *)event;
    SPScreenState *oldState = (SPScreenState *)currentState;
    SPScreenState *newState = [self screenStateFromScreenView:screenView];
    newState.previousState = oldState;
    return newState;
}

- (NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    if ([state isKindOfClass:SPScreenState.class]) {
        SPSelfDescribingJson *entity = [self screenContextFromScreenState:(SPScreenState *)state];
        return @[entity];
    }
    return nil;
}

- (NSDictionary<NSString *,NSObject *> *)payloadValuesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    if ([state isKindOfClass:SPScreenState.class]) {
        SPScreenState *previousState = ((SPScreenState *)state).previousState;
        NSMutableDictionary<NSString *,NSObject *> *addedValues = [NSMutableDictionary new];
        [addedValues setValue:previousState.name forKey:kSPSvPreviousName];
        [addedValues setValue:previousState.type forKey:kSPSvPreviousType];
        [addedValues setValue:previousState.screenId forKey:kSPSvPreviousScreenId];
        return addedValues;
    }
    return nil;
}

// Private methods

- (SPScreenState *)screenStateFromScreenView:(SPScreenView *)screenView {
    return [[SPScreenState alloc] initWithName:screenView.name
                                          type:screenView.type
                                      screenId:screenView.screenId
                                transitionType:screenView.transitionType
                    topViewControllerClassName:screenView.topViewControllerClassName
                       viewControllerClassName:screenView.viewControllerClassName];
}

- (SPSelfDescribingJson *)screenContextFromScreenState:(SPScreenState *)screenState {
    SPPayload *contextPayload = [screenState payload];
    if (!contextPayload) {
        return nil;
    }
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPScreenContextSchema andPayload:contextPayload];
}

@end
