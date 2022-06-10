//
//  TestRequestResult.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPTrackerConstants.h"
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

- (void)testSuccessfulRequest {
    NSMutableArray<NSNumber *> *emitterEventIds = [NSMutableArray new];
    [emitterEventIds addObject:@1];
    SPRequestResult *result = [[SPRequestResult alloc] initWithStatusCode:200 oversize:NO storeIds:emitterEventIds];

    XCTAssertNotNil(result);
    XCTAssertEqual(result.isSuccessful, YES);
    XCTAssertEqual([result shouldRetry:@{}], NO);
    XCTAssertEqual(result.storeIds, emitterEventIds);
}

- (void)testFailedRequest {
    NSMutableArray<NSNumber *> *emitterEventIds = [NSMutableArray new];
    [emitterEventIds addObject:@1];
    SPRequestResult *result = [[SPRequestResult alloc] initWithStatusCode:500 oversize:NO storeIds:emitterEventIds];
    XCTAssertEqual(result.isSuccessful, NO);
    XCTAssertEqual([result shouldRetry:@{}], YES);
}

- (void)testDefaultResult {
    SPRequestResult *result = [SPRequestResult new];

    XCTAssertNotNil(result);
    XCTAssertEqual(result.isSuccessful, NO);
    XCTAssertEqual(result.storeIds.count, 0);
}

- (void)testOversizedFailedRequest {
    SPRequestResult *result = [[SPRequestResult alloc] initWithStatusCode:500 oversize:YES storeIds:@[]];
    XCTAssertEqual(result.isSuccessful, NO);
    XCTAssertEqual([result shouldRetry:@{}], NO);
}

- (void)testFailedRequestWithNoRetryStatus {
    SPRequestResult *result = [[SPRequestResult alloc] initWithStatusCode:403 oversize:NO storeIds:@[]];
    XCTAssertEqual(result.isSuccessful, NO);
    XCTAssertEqual([result shouldRetry:@{}], NO);
}

- (void)testFailedRequestWithCustomNoRetryStatus {
    NSMutableDictionary *customRetryRules = [[NSMutableDictionary alloc] init];
    [customRetryRules setObject:@YES forKey:@403];
    [customRetryRules setObject:@NO forKey:@500];
    
    SPRequestResult *result = [[SPRequestResult alloc] initWithStatusCode:403 oversize:NO storeIds:@[]];
    XCTAssertEqual([result shouldRetry:customRetryRules], YES);

    result = [[SPRequestResult alloc] initWithStatusCode:500 oversize:NO storeIds:@[]];
    XCTAssertEqual([result shouldRetry:customRetryRules], NO);
}

@end
