//
//  TestScreenState.m
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
#import "SPSubject.h"
#import "SPTrackerConstants.h"
#import "SPEvent.h"
#import "SPScreenState.h"
#import "SPMockEventStore.h"

@interface TestScreenState : XCTestCase

@end

@implementation TestScreenState

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInvalidScreenState {
    SPScreenState * screenState = [[SPScreenState alloc] initWithName:@"name" screenId:@"some id"];
    
    // Test builder setting properly
    XCTAssertEqual([screenState isValid], NO);
    
    // ID and name required
    screenState = [[SPScreenState alloc] initWithName:nil type:@"some type" screenId:@"some id"];
    
    // Test builder setting properly
    XCTAssertEqual([screenState isValid], NO);
    
    // ID and name required (screen id generated)
    screenState = [[SPScreenState alloc] initWithName:@"some name" type:@"some type" screenId:nil];
    
    // Test builder setting properly
    XCTAssertEqual([screenState isValid], YES);
}

- (void)testValidScreenState {
    NSString *uuid = [NSUUID UUID].UUIDString;
    SPScreenState * screenState = [[SPScreenState alloc] initWithName:@"some name" type:@"some type" screenId:uuid];
    
    // Test builder
    XCTAssertEqual([screenState isValid], YES);
    XCTAssertNotNil([screenState payload]);
    
    // ID and name required
    screenState = [[SPScreenState alloc] initWithName:@"some name" screenId:uuid];
    
    // Test builder setting properly
    XCTAssertEqual([screenState isValid], YES);
    XCTAssertNotNil([screenState payload]);
    SPPayload * payload = [screenState payload];
    NSDictionary * dictionary = [payload getAsDictionary];
    XCTAssertEqual([dictionary objectForKey:kSPScreenName], @"some name");
    XCTAssertEqual([dictionary objectForKey:kSPScreenId], uuid);
}

- (void)testScreenStateMachine {
    SPMockEventStore *eventStore = [SPMockEventStore new];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setEmitter:[SPEmitter build:^(id<SPEmitterBuilder> builder) {
            [builder setUrlEndpoint:@"http://snowplow-fake-url.com"];
            [builder setEventStore:eventStore];
        }]];
        [builder setTrackerNamespace:@"namespace"];
        [builder setBase64Encoded:NO];
        [builder setScreenContext:YES];
    }];
    
    // Send events
    [tracker track:[[SPTiming alloc] initWithCategory:@"category" variable:@"variable" timing:@123]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    SPPayload *payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    NSString *entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertNil(entities);
    
    NSUUID *uuid = [NSUUID UUID];
    [tracker track:[[SPScreenView alloc] initWithName:@"screen1" screenId:uuid]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertNotNil(entities);
    XCTAssertTrue([entities containsString:uuid.UUIDString]);

    [tracker track:[[SPTiming alloc] initWithCategory:@"category" variable:@"variable" timing:@123]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertTrue([entities containsString:uuid.UUIDString]);

    NSUUID *uuid2 = [NSUUID UUID];
    [tracker track:[[SPScreenView alloc] initWithName:@"screen2" screenId:uuid2]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertTrue([entities containsString:uuid2.UUIDString]);
    NSString *eventPayload = (NSString *)(payload.getAsDictionary[@"ue_pr"]);
    XCTAssertTrue([eventPayload containsString:uuid.UUIDString]);
    XCTAssertTrue([eventPayload containsString:uuid2.UUIDString]);

    [tracker track:[[SPTiming alloc] initWithCategory:@"category" variable:@"variable" timing:@123]];
    [NSThread sleepForTimeInterval:1];
    if (eventStore.lastInsertedRow == -1) XCTFail();
    payload = eventStore.db[@(eventStore.lastInsertedRow)];
    [eventStore removeAllEvents];
    entities = (NSString *)(payload.getAsDictionary[@"co"]);
    XCTAssertTrue([entities containsString:uuid2.UUIDString]);
}

@end
