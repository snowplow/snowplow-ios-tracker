//
//  TestLifecycleState.m
//  Snowplow-iOSTests
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
//  Authors: Michael Hadam
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPPayload.h"
#import "SPEvent.h"
#import "SPMockEventStore.h"

@interface TestLifecycleState : XCTestCase

@end

@implementation TestLifecycleState

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testLifeycleStateMachine {
    SPMockEventStore *eventStore = [SPMockEventStore new];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setEmitter:[SPEmitter build:^(id<SPEmitterBuilder> builder) {
            [builder setUrlEndpoint:@"http://snowplow-fake-url.com"];
            [builder setEventStore:eventStore];
        }]];
        [builder setTrackerNamespace:@"namespace"];
        [builder setBase64Encoded:NO];
        [builder setLifecycleEvents:YES];
    }];
    
    // Send events
    [tracker track:[[SPTiming alloc] initWithCategory:@"category" variable:@"variable" timing:@123]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    SPPayload *payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    NSString *entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertNotNil(entities);
    XCTAssertTrue([entities containsString:@"\"isVisible\":true"]);
    
    [tracker track:[[SPBackground alloc] initWithIndex:@1]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertNotNil(entities);
    XCTAssertTrue([entities containsString:@"\"isVisible\":false"]);

    [tracker track:[[SPTiming alloc] initWithCategory:@"category" variable:@"variable" timing:@123]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertTrue([entities containsString:@"\"isVisible\":false"]);
    
    [tracker track:[[SPForeground alloc] initWithIndex:@1]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertNotNil(entities);
    XCTAssertTrue([entities containsString:@"\"isVisible\":true"]);

    NSUUID *uuid = [NSUUID UUID];
    [tracker track:[[SPScreenView alloc] initWithName:@"screen1" screenId:uuid]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertTrue([entities containsString:@"\"isVisible\":true"]);
}

@end

