//
//  SPScreenStateMachine.m
//  Snowplow
//
//  Created by Alex Benini on 19/08/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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

- (id<SPState>)transitionFromEvent:(SPEvent *)event currentState:(id<SPState>)currentState {
    SPScreenView *screenView = (SPScreenView *)event;
    SPScreenState *oldState = (SPScreenState *)currentState;
    SPScreenState *newState = [screenView getScreenState];
    newState.previousState = oldState;
    return newState;
}

- (NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    if ([state isKindOfClass:SPScreenState.class]) {
        SPSelfDescribingJson *entity = [SPUtilities getScreenContextWithScreenState:(SPScreenState *)state];
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

@end
