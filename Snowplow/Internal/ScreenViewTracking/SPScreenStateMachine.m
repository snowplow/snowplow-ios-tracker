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

- (id<SPState>)transitionFromEvent:(SPEvent *)event currentState:(id<SPState>)currentState {
    SPScreenView *screenView = (SPScreenView *)event;
    return [[SPScreenState alloc] initWithName:screenView.name
                                          type:screenView.type
                                      screenId:screenView.screenId
                                transitionType:screenView.transitionType
                    topViewControllerClassName:screenView.topViewControllerClassName
                       viewControllerClassName:screenView.viewControllerClassName];
}

- (NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    if ([state isKindOfClass:SPScreenState.class]) {
        SPSelfDescribingJson *entity = [SPUtilities getScreenContextWithScreenState:(SPScreenState *)state];
        return @[entity];
    }
    return nil;
}

@end
