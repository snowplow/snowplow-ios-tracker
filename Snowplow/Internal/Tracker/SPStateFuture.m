//
//  SPStateFuture.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
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
            self.computedState = [self.stateMachine transitionFromEvent:self.event state:self.previousState.state];
            self.event = nil;
            self.previousState = nil;
            self.stateMachine = nil;
        }
        return self.computedState;
    }
}

@end
