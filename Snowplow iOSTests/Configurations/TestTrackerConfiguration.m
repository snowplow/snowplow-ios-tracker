//
//  TestTrackerConfiguration.m
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
#import "SPSnowplow.h"
#import "SPNetworkConfiguration.h"
#import "SPTrackerConfiguration.h"
#import "SPSession.h"

@interface TestTrackerConfiguration : XCTestCase

@end

@implementation TestTrackerConfiguration

- (void)testNetworkConfiguration_EmptyEndpoint_Fails {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"" method:SPHttpMethodPost];
    XCTAssertEqualObjects(@"", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttps, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodPost, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithoutProtocol_SuccessWithHttps {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"fake-url.com" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"fake-url.com", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttps, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithHttpsProtocol_SuccessWithHttps {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"https://fake-url.com" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"fake-url.com", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttps, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithHttpProtocol_SuccessWithHttps {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"http://fake-url.com" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"fake-url.com", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttp, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithWrongProtocol_UseItAsEndpoint {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"wrong://fake-url.com" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"wrong://fake-url.com", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttps, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithOnlyProtocol_UseItAsEndpoint {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"http://" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttp, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNotNil(tracker);
}

- (void)testBasicInitialization {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"https://fake-url" method:SPHttpMethodPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    trackerConfig.platformContext = YES;
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];

    XCTAssertNotNil(tracker);
    XCTAssertNotNil(tracker.emitter);
    NSURL *url = [NSURL URLWithString:tracker.network.endpoint];
    XCTAssertNotNil(url);
    NSString *host = url.host;
    NSString *scheme = url.scheme;

    NSString *protocol = networkConfig.protocol == SPProtocolHttp ? @"http" : networkConfig.protocol == SPProtocolHttps ? @"https" : nil;
    
    XCTAssertEqualObjects(networkConfig.endpoint, host);
    XCTAssertEqualObjects(protocol, scheme);
    
    XCTAssertEqual(trackerConfig.appId, tracker.appId);
    XCTAssertEqual(trackerConfig.namespace, tracker.namespace);
}

- (void)testSessionInitialization {
    NSInteger expectedForeground = 42;
    NSInteger expectedBackground = 24;
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"https://fake-url" method:SPHttpMethodPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    SPSessionConfiguration *sessionConfig = [[SPSessionConfiguration alloc] initWithForegroundTimeoutInSeconds:expectedForeground
                                                                                    backgroundTimeoutInSeconds:expectedBackground];
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig configurations:@[sessionConfig]];

    NSInteger foreground = tracker.session.foregroundTimeoutInSeconds;
    NSInteger background = tracker.session.backgroundTimeoutInSeconds;
    XCTAssertEqual(expectedForeground, foreground);
    XCTAssertEqual(expectedBackground, background);
    
    NSMeasurement *foregroundMeasure = [tracker.session foregroundTimeout];
    NSMeasurement *backgroundMeasure = [tracker.session backgroundTimeout];
    XCTAssertEqualObjects([[NSMeasurement alloc] initWithDoubleValue:expectedForeground unit:NSUnitDuration.seconds], foregroundMeasure);
    XCTAssertEqualObjects([[NSMeasurement alloc] initWithDoubleValue:expectedBackground unit:NSUnitDuration.seconds], backgroundMeasure);
}

- (void)testSessionControllerUnavailableWhenContextTurnedOff {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"https://fake-url" method:SPHttpMethodPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    trackerConfig.sessionContext = YES;
    id<SPTrackerController> tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNotNil(tracker.session);

    trackerConfig.sessionContext = NO;
    tracker = [SPSnowplow setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNil(tracker.session);
}

@end
