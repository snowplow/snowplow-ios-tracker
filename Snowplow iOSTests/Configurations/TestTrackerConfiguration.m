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

@interface TestTrackerConfiguration : XCTestCase

@end

@implementation TestTrackerConfiguration

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

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

@end
