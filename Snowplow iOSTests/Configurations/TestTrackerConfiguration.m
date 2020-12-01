//
//  TestTrackerConfiguration.m
//  Snowplow-iOSTests
//
//  Created by Alex Benini on 27/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SPNetworkConfiguration.h"
#import "SPTrackerConfiguration.h"
#import "SPSession.h"

@interface TestTrackerConfiguration : XCTestCase

@end

@implementation TestTrackerConfiguration

- (void)testBasicInitialization {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"fake-url" protocol:SPProtocolHttps method:SPRequestOptionsPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    trackerConfig.platformContext = YES;
    SPTracker *tracker = [SPTracker setupWithNetwork:networkConfig tracker:trackerConfig];

    XCTAssertNotNil(tracker);
    XCTAssertNotNil(tracker.emitter);
    NSURL *url = tracker.emitter.urlEndpoint;
    XCTAssertNotNil(url);
    NSString *host = url.host;
    NSString *scheme = url.scheme;

    NSString *protocol = networkConfig.protocol == SPProtocolHttp ? @"http" : networkConfig.protocol == SPProtocolHttps ? @"https" : nil;
    
    XCTAssertEqualObjects(networkConfig.endpoint, host);
    XCTAssertEqualObjects(protocol, scheme);
    
    XCTAssertEqual(trackerConfig.appId, tracker.appId);
    XCTAssertEqual(trackerConfig.namespace, tracker.trackerNamespace);
    
    XCTAssertNotNil(tracker.subject);
}

- (void)testSessionInitialization {
    NSInteger expectedForeground = 42;
    NSInteger expectedBackground = 24;
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"fake-url" protocol:SPProtocolHttps method:SPRequestOptionsPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    SPSessionConfiguration *sessionConfig = [[SPSessionConfiguration alloc] initWithForegroundTimeoutInSeconds:expectedForeground
                                                                                    backgroundTimeoutInSeconds:expectedBackground];
    SPTracker *tracker = [SPTracker setupWithNetwork:networkConfig tracker:trackerConfig configurations:@[sessionConfig]];

    NSInteger foreground = [tracker.session getForegroundTimeout] / 1000;
    NSInteger background = [tracker.session getBackgroundTimeout] / 1000;
    XCTAssertEqual(expectedForeground, foreground);
    XCTAssertEqual(expectedBackground, background);
}

@end
