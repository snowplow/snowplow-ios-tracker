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
#import "SPMockEventStore.h"

@interface TestTrackerConfiguration : XCTestCase

@end

@implementation TestTrackerConfiguration

- (void)testNetworkConfiguration_EmptyEndpoint_Fails {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"" method:SPHttpMethodPost];
    XCTAssertEqualObjects(@"https://", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttps, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodPost, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithoutProtocol_SuccessWithHttps {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"fake-url.com" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"https://fake-url.com", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttps, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithHttpsProtocol_SuccessWithHttps {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"https://fake-url.com" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"https://fake-url.com", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttps, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithHttpProtocol_SuccessWithHttps {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"http://fake-url.com" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"http://fake-url.com", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttp, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithWrongProtocol_UseItAsEndpoint {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"wrong://fake-url.com" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"https://wrong://fake-url.com", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttps, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];
    XCTAssertNotNil(tracker);
}

- (void)testNetworkConfiguration_EndpointWithOnlyProtocol_UseItAsEndpoint {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"http://" method:SPHttpMethodGet];
    XCTAssertEqualObjects(@"http://", networkConfig.endpoint);
    XCTAssertEqual(SPProtocolHttp, networkConfig.protocol);
    XCTAssertEqual(SPHttpMethodGet, networkConfig.method);
    
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];
    XCTAssertNotNil(tracker);
}

- (void)testBasicInitialization {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"https://fake-url" method:SPHttpMethodPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    trackerConfig.platformContext = YES;
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];

    XCTAssertNotNil(tracker);
    XCTAssertNotNil(tracker.emitter);
    NSURL *url = [NSURL URLWithString:tracker.network.endpoint];
    XCTAssertNotNil(url);
    NSString *host = url.host;
    NSString *scheme = url.scheme;
    NSString *derivedEndpoint = [NSString stringWithFormat:@"%@://%@", scheme, host];

    NSString *protocol = networkConfig.protocol == SPProtocolHttp ? @"http" : networkConfig.protocol == SPProtocolHttps ? @"https" : nil;
    
    XCTAssertEqualObjects(networkConfig.endpoint, derivedEndpoint);
    XCTAssertEqualObjects(protocol, scheme);
    
    XCTAssertEqualObjects(trackerConfig.appId, tracker.appId);
    XCTAssertEqualObjects(@"namespace", tracker.namespace);
}

- (void)testSessionInitialization {
    NSInteger expectedForeground = 42;
    NSInteger expectedBackground = 24;
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"https://fake-url" method:SPHttpMethodPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    SPSessionConfiguration *sessionConfig = [[SPSessionConfiguration alloc] initWithForegroundTimeoutInSeconds:expectedForeground
                                                                                    backgroundTimeoutInSeconds:expectedBackground];
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig, sessionConfig]];

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
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    trackerConfig.sessionContext = YES;
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];
    XCTAssertNotNil(tracker.session);

    trackerConfig.sessionContext = NO;
    tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfig configurations:@[trackerConfig]];
    XCTAssertNil(tracker.session);
}

- (void)testGDPRConfiguration {
    SPMockEventStore *eventStore = [SPMockEventStore new];
    SPNetworkConfiguration *networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:@"fake-url" method:SPHttpMethodPost];
    SPTrackerConfiguration *trackerConfiguration = [[[SPTrackerConfiguration alloc] init] appId:@"appid"];
    trackerConfiguration.base64Encoding = NO;
    SPEmitterConfiguration *emitterConfiguration = [[SPEmitterConfiguration alloc] init];
    emitterConfiguration.eventStore = eventStore;
    emitterConfiguration.threadPoolSize = 10;
    SPGDPRConfiguration *gdprConfiguration = [[SPGDPRConfiguration alloc] initWithBasis:SPGdprProcessingBasisConsent documentId:@"id" documentVersion:@"ver" documentDescription:@"desc"];
    id<SPTrackerController> trackerController = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfiguration configurations:@[trackerConfiguration, gdprConfiguration, emitterConfiguration]];
    id<SPGDPRController> gdprController = trackerController.gdpr;

    // Check gdpr settings
    XCTAssertEqual(SPGdprProcessingBasisConsent, gdprController.basisForProcessing);
    XCTAssertEqualObjects(@"id", gdprController.documentId);

    // Check gdpr settings reset
    [gdprController resetWithBasis:SPGdprProcessingBasisContract documentId:@"id1" documentVersion:@"ver1" documentDescription:@"desc1"];
    XCTAssertEqual(SPGdprProcessingBasisContract, gdprController.basisForProcessing);
    XCTAssertEqualObjects(@"id1", gdprController.documentId);
    XCTAssertTrue(gdprController.isEnabled);

    // Check gdpr context added
    SPStructured *event = [[SPStructured alloc] initWithCategory:@"category" action:@"action"];
    [trackerController track:event];
    for (int i=0; eventStore.count < 1 && i < 10; i++) {
        [NSThread sleepForTimeInterval:1];
    }
    NSArray<SPEmitterEvent *> *events = [eventStore emittableEventsWithQueryLimit:10];
    [eventStore removeAllEvents];
    XCTAssertEqual(1, events.count);
    SPPayload *payload = [[events firstObject] payload];
    NSString *contexts = (NSString *)[[payload getAsDictionary] objectForKey:@"co"];
    XCTAssertTrue([contexts containsString:@"\"basisForProcessing\":\"contract\""]);
    XCTAssertTrue([contexts containsString:@"\"documentId\":\"id1\""]);

    // Check gdpr disabled
    [gdprController disable];
    XCTAssertFalse(gdprController.isEnabled);
    XCTAssertEqual(SPGdprProcessingBasisContract, gdprController.basisForProcessing);
    XCTAssertEqualObjects(@"id1", gdprController.documentId);
    
    // Check gdpr context not added
    event = [[SPStructured alloc] initWithCategory:@"category" action:@"action"];
    [trackerController track:event];
    for (int i=0; eventStore.count < 1 && i < 10; i++) {
        [NSThread sleepForTimeInterval:1];
    }
    events = [eventStore emittableEventsWithQueryLimit:10];
    [eventStore removeAllEvents];
    XCTAssertEqual(1, events.count);
    payload = [[events firstObject] payload];
    contexts = (NSString *)[[payload getAsDictionary] objectForKey:@"co"];
    XCTAssertFalse([contexts containsString:@"\"basisForProcessing\":\"contract\""]);
    XCTAssertFalse([contexts containsString:@"\"documentId\":\"id1\""]);
    
    // Check gdpr enabled again
    [gdprController enable];
    XCTAssertTrue(gdprController.isEnabled);
}

@end
