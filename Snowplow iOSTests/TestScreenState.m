//
//  TestScreenState.m
//  Snowplow-iOSTests
//
//  Created by Michael Hadam on 4/1/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
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
    SPScreenState * screenState = [[SPScreenState alloc] initWithName:@"some name" type:@"some type" screenId:@"some id"];
    
    // Test builder
    XCTAssertEqual([screenState isValid], YES);
    XCTAssertNotNil([screenState getValidPayload]);
    
    // ID and name required
    screenState = [[SPScreenState alloc] initWithName:@"some name" screenId:@"some id"];
    
    // Test builder setting properly
    XCTAssertEqual([screenState isValid], YES);
    XCTAssertNotNil([screenState getValidPayload]);
    SPPayload * payload = [screenState getValidPayload];
    NSDictionary * dictionary = [payload getAsDictionary];
    XCTAssertEqual([dictionary objectForKey:kSPScreenName], @"some name");
    XCTAssertEqual([dictionary objectForKey:kSPScreenId], @"some id");
}

@end
