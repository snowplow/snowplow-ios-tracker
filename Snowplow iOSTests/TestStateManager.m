//
//  TestStateManager.m
//  Snowplow-iOSTests
//
//  Created by Alex Benini on 24/08/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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

- (id<SPState>)transitionFromEvent:(SPEvent *)event currentState:(id<SPState>)currentState {
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
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithSchema:@"nothing" payload:@{@"value": @3}];

    NSDictionary<NSString *, SPStateFuture *> *state = [stateManager trackerStateByProcessedEvent:eventInc];
    MockState *mockState = (MockState *)[state[@"identifier"] state];
    XCTAssertEqual(1, mockState.value);
    id<SPInspectableEvent> e = [[SPTrackerEvent alloc] initWithEvent:eventInc stateCopy:state];
    NSArray<SPSelfDescribingJson *> *entities = [stateManager entitiesByProcessedEvent:e];
    XCTAssertEqualObjects(@1, ((NSDictionary<NSString *, NSNumber *> *)(entities[0].data))[@"value"]);
    
    state = [stateManager trackerStateByProcessedEvent:eventInc];
    XCTAssertEqual(2, [(MockState *)[state[@"identifier"] state] value]);
    e = [[SPTrackerEvent alloc] initWithEvent:eventInc stateCopy:state];
    entities = [stateManager entitiesByProcessedEvent:e];
    XCTAssertEqualObjects(@2, ((NSDictionary<NSString *, NSNumber *> *)(entities[0].data))[@"value"]);

    state = [stateManager trackerStateByProcessedEvent:eventDec];
    XCTAssertEqual(1, [(MockState *)[state[@"identifier"] state] value]);
    e = [[SPTrackerEvent alloc] initWithEvent:eventDec stateCopy:state];
    entities = [stateManager entitiesByProcessedEvent:e];
    XCTAssertEqualObjects(@1, ((NSDictionary<NSString *, NSNumber *> *)(entities[0].data))[@"value"]);

    state = [stateManager trackerStateByProcessedEvent:event];
    XCTAssertEqual(1, [(MockState *)[state[@"identifier"] state] value]);
    e = [[SPTrackerEvent alloc] initWithEvent:event stateCopy:state];
    entities = [stateManager entitiesByProcessedEvent:e];
    XCTAssertEqualObjects(@1, ((NSDictionary<NSString *, NSNumber *> *)(entities[0].data))[@"value"]);
}

- (void)testAddRemoveStateMachine {
    SPStateManager *stateManager = [SPStateManager new];
    [stateManager addStateMachine:[MockStateMachine new] identifier:@"identifier"];
    [stateManager removeStateMachine:@"identifier"];
    
    SPSelfDescribing *eventInc = [[SPSelfDescribing alloc] initWithSchema:@"inc" payload:@{@"value": @1}];

    NSDictionary<NSString *, SPStateFuture *> *state = [stateManager trackerStateByProcessedEvent:eventInc];
    MockState *mockState = (MockState *)[state[@"identifier"] state];
    XCTAssertNil(mockState);
    id<SPInspectableEvent> e = [[SPTrackerEvent alloc] initWithEvent:eventInc stateCopy:state];
    NSArray<SPSelfDescribingJson *> *entities = [stateManager entitiesByProcessedEvent:e];
    XCTAssertEqual(0, entities.count);
}

@end

