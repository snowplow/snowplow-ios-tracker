//
//  SPStateUpdater.m
//  Snowplow
//
//  Created by Alex Benini on 26/06/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPStateFuture.h"


@interface SPStateFuture ()

@property (nonatomic) SPEvent *event;
@property (nonatomic) SPStateFuture *previousState;
@property (nonatomic) id<SPStateMachineProtocol> stateMachine;

@property (nonatomic) id<SPState> computedState;

@end

@implementation SPStateFuture

- (instancetype)initWithEvent:(SPEvent *)event previousState:(SPStateFuture *)previousState stateMachine:(id<SPStateMachineProtocol>)stateMachine {
    if (self = [super init]) {
        self.event = event;
        self.previousState = previousState;
        self.stateMachine = stateMachine;
    }
    return self;
}

- (id<SPState>)state {
    @synchronized (self) {
        if (!self.computedState && self.stateMachine) {
            self.computedState = [self.stateMachine transitionFromEvent:self.event currentState:self.previousState.state];
            self.event = nil;
            self.previousState = nil;
            self.stateMachine = nil;
        }
        return self.computedState;
    }
}

@end
