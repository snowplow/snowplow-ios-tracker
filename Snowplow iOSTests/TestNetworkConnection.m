//
//  TestNetworkConnection.m
//  Snowplow-iOSTests
//
//  Created by Alex Benini on 25/08/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    [super tearDown];
    [[LSNocilla sharedInstance] clearStubs];
}

- (void)testGetRequestWithSuccess {
    stubRequest(@"GET", [[NSString alloc] initWithFormat:@"^%@://%@/i?(.*?)", @"https", TEST_URL_ENDPOINT].regex).andReturn(200);
    
    SPDefaultNetworkConnection *connection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        [builder setUrlEndpoint:TEST_URL_ENDPOINT];
        [builder setProtocol:SPHttps];
        [builder setHttpMethod:SPRequestGet];
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
        [builder setProtocol:SPHttps];
        [builder setHttpMethod:SPRequestGet];
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
        [builder setProtocol:SPHttps];
        [builder setHttpMethod:SPRequestPost];
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
        [builder setProtocol:SPHttps];
        [builder setHttpMethod:SPRequestPost];
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

@end
