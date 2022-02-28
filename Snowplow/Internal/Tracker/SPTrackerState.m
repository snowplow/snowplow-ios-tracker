//
//  SPTrackerState.m
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

#import "SPTrackerState.h"

@interface SPTrackerState ()

@property (nonatomic) NSMutableDictionary<NSString *, SPStateFuture *> *trackerState;

@end

@implementation SPTrackerState

- (instancetype)init {
    if (self = [super init]) {
        self.trackerState = [NSMutableDictionary new];
    }
    return self;
}

- (void)setStateFuture:(SPStateFuture *)state identifier:(NSString *)stateIdentifier {
    @synchronized (self) {
        self.trackerState[stateIdentifier] = state;
    }
}

- (SPStateFuture *)stateFutureWithIdentifier:(NSString *)stateIdentifier {
    @synchronized (self) {
        return self.trackerState[stateIdentifier];
    }
}

- (void)removeStateWithIdentifier:(NSString *)stateIdentifer {
    @synchronized (self) {
        [self.trackerState removeObjectForKey:stateIdentifer];
    }
}

- (id<SPTrackerStateSnapshot>)snapshot {
    @synchronized (self) {
        SPTrackerState *newTrackerState = [SPTrackerState new];
        newTrackerState.trackerState = [self.trackerState mutableCopy];
        return newTrackerState;
    }
}

// Protocol SPTrackerStateSnapshot

- (id<SPState>)stateWithIdentifier:(NSString *)stateIdentifier {
    return [self stateFutureWithIdentifier:stateIdentifier].state;
}

@end
