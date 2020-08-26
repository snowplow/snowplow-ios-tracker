//
//  TestRequestResult.m
//  Snowplow
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "Snowplow.h"
#import "SPRequestResult.h"

@interface TestRequestResult : XCTestCase

@end

@implementation TestRequestResult

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    NSMutableArray<NSNumber *> *emitterEventIds = [NSMutableArray new];
    [emitterEventIds addObject:@1];
    SPRequestResult *result = [[SPRequestResult alloc] initWithSuccess:YES storeIds:emitterEventIds];
    
    XCTAssertNotNil(result);
    XCTAssertEqual(result.isSuccessful, YES);
    XCTAssertEqual(result.storeIds, emitterEventIds);
    
    result = [SPRequestResult new];
    
    XCTAssertNotNil(result);
    XCTAssertEqual(result.isSuccessful, NO);
    XCTAssertEqual(result.storeIds.count, 0);
}

@end
