//
//  TestStateManager.m
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

#import <XCTest/XCTest.h>
#import "SPStateManager.h"
#import "SPTrackerEvent.h"

// MARK: - MockState

@interface MockState : NSObject <SPState>
@property NSInteger value;
- (instancetype)initWithValue:(NSInteger)value;
@end

@implementation MockState
- (instancetype)initWithValue:(NSInteger)value {
    if (self = [super init]) {
        self.value = value;
    }
    return self;
}
@end

// MARK: - MockStateMachine

@interface MockStateMachine : NSObject <SPStateMachineProtocol>
@end

@implementation MockStateMachine

- (NSArray<NSString *> *)subscribedEventSchemasForTransitions {
    return @[@"inc",@"dec"];
}

- (id<SPState>)transitionFromEvent:(SPEvent *)event state:(id<SPState>)currentState {
    SPSelfDescribingAbstract *e = (SPSelfDescribingAbstract *)event;
    MockState *state = (MockState *)currentState ?: [[MockState alloc] initWithValue:0];
    if ([e.schema isEqualToString:@"inc"]) {
        return [[MockState alloc] initWithValue:state.value+1];
    } else if ([e.schema isEqualToString:@"dec"]) {
        return [[MockState alloc] initWithValue:state.value-1];
    } else {
        return [[MockState alloc] initWithValue:0];
    }
}

- (NSArray<NSString *> *)subscribedEventSchemasForEntitiesGeneration {
    return @[@"*"];
}

- (NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(id<SPState>)state {
    MockState *mockState = (MockState *)state;
    SPSelfDescribingJson *sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"entity" andDictionary:@{@"value":@(mockState.value)}];
    return @[sdj];
}

- (nonnull NSArray<NSString *> *)subscribedEventSchemasForPayloadUpdating {
    return @[@"event"];
}

- (nullable NSDictionary<NSString *,NSObject *> *)payloadValuesFromEvent:(nonnull id<SPInspectableEvent>)event state:(nullable id<SPState>)state {
    return @{@"newParam": @"value"};
}

@end

// MARK: - Test

@interface TestStateManager : XCTestCase
@end

@implementation TestStateManager

- (void)testStateManager {
    SPStateManager *stateManager = [SPStateManager new];
    [stateManager addStateMachine:[MockStateMachine new] identifier:@"identifier"];
    
    SPSelfDescribing *eventInc = [[SPSelfDescribing alloc] initWithSchema:@"inc" payload:@{@"value": @1}];
    SPSelfDescribing *eventDec = [[SPSelfDescribing alloc] initWithSchema:@"dec" payload:@{@"value": @2}];
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithSchema:@"event" payload:@{@"value": @3}];

    id<SPTrackerStateSnapshot> trackerState = [stateManager trackerStateForProcessedEvent:eventInc];
    MockState *mockState = (MockState *)[trackerState stateWithIdentifier:@"identifier"];
    XCTAssertEqual(1, mockState.value);
    id<SPInspectableEvent> e = [[SPTrackerEvent alloc] initWithEvent:eventInc state:trackerState];
    NSArray<SPSelfDescribingJson *> *entities = [stateManager entitiesForProcessedEvent:e];
    XCTAssertEqualObjects(@1, ((NSDictionary<NSString *, NSNumber *> *)(entities[0].data))[@"value"]);
    XCTAssertTrue([stateManager addPayloadValuesToEvent:e]);
    XCTAssertNil((e.payload)[@"newParam"]);

    trackerState = [stateManager trackerStateForProcessedEvent:eventInc];
    XCTAssertEqual(2, [(MockState *)[trackerState stateWithIdentifier:@"identifier"] value]);
    e = [[SPTrackerEvent alloc] initWithEvent:eventInc state:trackerState];
    entities = [stateManager entitiesForProcessedEvent:e];
    XCTAssertEqualObjects(@2, ((NSDictionary<NSString *, NSNumber *> *)(entities[0].data))[@"value"]);
    XCTAssertTrue([stateManager addPayloadValuesToEvent:e]);
    XCTAssertNil((e.payload)[@"newParam"]);

    trackerState = [stateManager trackerStateForProcessedEvent:eventDec];
    XCTAssertEqual(1, [(MockState *)[trackerState stateWithIdentifier:@"identifier"] value]);
    e = [[SPTrackerEvent alloc] initWithEvent:eventDec state:trackerState];
    entities = [stateManager entitiesForProcessedEvent:e];
    XCTAssertEqualObjects(@1, ((NSDictionary<NSString *, NSNumber *> *)(entities[0].data))[@"value"]);
    XCTAssertTrue([stateManager addPayloadValuesToEvent:e]);
    XCTAssertNil((e.payload)[@"newParam"]);

    trackerState = [stateManager trackerStateForProcessedEvent:event];
    XCTAssertEqual(1, [(MockState *)[trackerState stateWithIdentifier:@"identifier"] value]);
    e = [[SPTrackerEvent alloc] initWithEvent:event state:trackerState];
    entities = [stateManager entitiesForProcessedEvent:e];
    XCTAssertEqualObjects(@1, ((NSDictionary<NSString *, NSNumber *> *)(entities[0].data))[@"value"]);
    XCTAssertTrue([stateManager addPayloadValuesToEvent:e]);
    XCTAssertEqualObjects(@"value", (e.payload)[@"newParam"]);
}

- (void)testAddRemoveStateMachine {
    SPStateManager *stateManager = [SPStateManager new];
    [stateManager addStateMachine:[MockStateMachine new] identifier:@"identifier"];
    [stateManager removeStateMachine:@"identifier"];
    
    SPSelfDescribing *eventInc = [[SPSelfDescribing alloc] initWithSchema:@"inc" payload:@{@"value": @1}];

    id<SPTrackerStateSnapshot> trackerState = [stateManager trackerStateForProcessedEvent:eventInc];
    MockState *mockState = (MockState *)[trackerState stateWithIdentifier:@"identifier"];
    XCTAssertNil(mockState);
    id<SPInspectableEvent> e = [[SPTrackerEvent alloc] initWithEvent:eventInc state:trackerState];
    NSArray<SPSelfDescribingJson *> *entities = [stateManager entitiesForProcessedEvent:e];
    XCTAssertEqual(0, entities.count);
}

@end

