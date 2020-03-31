//
//  TestScreenState.m
//  Snowplow-iOSTests
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPPayload.h"
#import "SPSubject.h"
#import "SPScreenState.h"
#import "Snowplow.h"

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
    SPScreenState * screenState = [[SPScreenState alloc] init];
    
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
    XCTAssertNotNil([screenState getValidPayload]);
    
    // ID and name required
    screenState = [[SPScreenState alloc] initWithName:@"some name" screenId:uuid];
    
    // Test builder setting properly
    XCTAssertEqual([screenState isValid], YES);
    XCTAssertNotNil([screenState getValidPayload]);
    SPPayload * payload = [screenState getValidPayload];
    NSDictionary * dictionary = [payload getAsDictionary];
    XCTAssertEqual([dictionary objectForKey:kSPScreenName], @"some name");
    XCTAssertEqual([dictionary objectForKey:kSPScreenId], uuid);
}

@end
