//
//  TestTrackerController.m
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
