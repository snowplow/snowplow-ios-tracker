//
//  TestTrackerController.m
//  Snowplow-iOSTests
//
//  Created by Alex Benini on 02/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SPNetworkConfiguration.h"
#import "SPTrackerConfiguration.h"
#import "SPTrackerControlling.h"
#import "SPTracker.h"
#import "SPSession.h"

@interface TestTrackerController : XCTestCase

@end

@implementation TestTrackerController

- (void)testSessionAccessibilityWhenEnabledAndDisabled {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"fake-url" protocol:SPProtocolHttps method:SPRequestOptionsPost];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"namespace" appId:@"appid"];
    id<SPTrackerControlling> tracker = [SPTracker setupWithNetwork:networkConfig tracker:trackerConfig];
    XCTAssertNotNil(tracker.session);
    
    tracker.sessionContext = NO;
    XCTAssertNil(tracker.session);
}

@end
