//
//  TestNetworkConnection.m
//  Snowplow-iOSTests
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
#import <Nocilla/Nocilla.h>

#import "SPDefaultNetworkConnection.h"

@interface TestNetworkConnection : XCTestCase

@end

@implementation TestNetworkConnection

NSString *const TEST_URL_ENDPOINT = @"acme.test.url.com";

- (void)setUp {
    [super setUp];
    if ([[LSNocilla sharedInstance] isStarted]) {
        [[LSNocilla sharedInstance] stop];
    }
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    [super tearDown];
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
}

- (void)testGetRequestWithSuccess {
    stubRequest(@"GET", [[NSString alloc] initWithFormat:@"^%@://%@/i?(.*?)", @"https", TEST_URL_ENDPOINT].regex).andReturn(200);
    
    SPDefaultNetworkConnection *connection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        [builder setUrlEndpoint:TEST_URL_ENDPOINT];
        [builder setHttpMethod:SPHttpMethodGet];
    }];
    
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:@"value" forKey:@"key"];
    SPRequest *request = [[SPRequest alloc] initWithPayload:payload emitterEventId:1];
    NSArray<SPRequestResult *> *results = [connection sendRequests:@[request]];
    
    // Check successful result
    SPRequestResult *result = [results objectAtIndex:0];
    XCTAssertTrue(result.isSuccessful);
    XCTAssertEqualObjects(@1, result.storeIds[0]);
}

- (void)testGetRequestWithNoSuccess {
    stubRequest(@"GET", [[NSString alloc] initWithFormat:@"^%@://%@/i?(.*?)", @"https", TEST_URL_ENDPOINT].regex).andReturn(404);
    
    SPDefaultNetworkConnection *connection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        [builder setUrlEndpoint:TEST_URL_ENDPOINT];
        [builder setHttpMethod:SPHttpMethodGet];
    }];
    
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:@"value" forKey:@"key"];
    SPRequest *request = [[SPRequest alloc] initWithPayload:payload emitterEventId:1];
    NSArray<SPRequestResult *> *results = [connection sendRequests:@[request]];
    
    // Check unsuccessful result
    SPRequestResult *result = [results objectAtIndex:0];
    XCTAssertFalse(result.isSuccessful);
    XCTAssertEqualObjects(@1, [result.storeIds objectAtIndex:0]);
}

- (void)testPostRequestWithSuccess {
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"^%@://%@/i?(.*?)", @"https", TEST_URL_ENDPOINT].regex).andReturn(200);
    
    SPDefaultNetworkConnection *connection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        [builder setUrlEndpoint:TEST_URL_ENDPOINT];
        [builder setHttpMethod:SPHttpMethodPost];
    }];
    
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:@"value" forKey:@"key"];
    SPRequest *request = [[SPRequest alloc] initWithPayload:payload emitterEventId:1];
    NSArray<SPRequestResult *> *results = [connection sendRequests:@[request]];
    
    // Check successful result
    SPRequestResult *result = [results objectAtIndex:0];
    XCTAssertTrue(result.isSuccessful);
    XCTAssertEqualObjects(@1, [result.storeIds objectAtIndex:0]);
}

- (void)testPostRequestWithNoSuccess {
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"^%@://%@/i?(.*?)", @"https", TEST_URL_ENDPOINT].regex).andReturn(404);
    
    SPDefaultNetworkConnection *connection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        [builder setUrlEndpoint:TEST_URL_ENDPOINT];
        [builder setHttpMethod:SPHttpMethodPost];
    }];
    
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:@"value" forKey:@"key"];
    SPRequest *request = [[SPRequest alloc] initWithPayload:payload emitterEventId:1];
    NSArray<SPRequestResult *> *results = [connection sendRequests:@[request]];
    
    // Check unsuccessful result
    SPRequestResult *result = [results objectAtIndex:0];
    XCTAssertFalse(result.isSuccessful);
    XCTAssertEqualObjects(@1, [result.storeIds objectAtIndex:0]);
}

- (void)testFreeEndpoint_GetHttpsUrl {
    SPDefaultNetworkConnection *connection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        [builder setUrlEndpoint:@"acme.test.url.com"];
        [builder setHttpMethod:SPHttpMethodPost];
    }];
    XCTAssertTrue([connection.url.absoluteString hasPrefix:@"https://acme.test.url.com"]);
}

- (void)testHttpsEndpoint_GetHttpsUrl {
    SPDefaultNetworkConnection *connection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        [builder setUrlEndpoint:@"https://acme.test.url.com"];
        [builder setHttpMethod:SPHttpMethodPost];
    }];
    XCTAssertTrue([connection.url.absoluteString hasPrefix:@"https://acme.test.url.com"]);
}

- (void)testHttpEndpoint_GetHttpUrl {
    SPDefaultNetworkConnection *connection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        [builder setUrlEndpoint:@"http://acme.test.url.com"];
        [builder setHttpMethod:SPHttpMethodPost];
    }];
    XCTAssertTrue([connection.url.absoluteString hasPrefix:@"http://acme.test.url.com"]);
}

@end
