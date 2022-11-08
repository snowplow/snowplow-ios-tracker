//
//  TestTrackerController.m
//  Snowplow-iOSTests
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
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPSnowplow.h"
#import "SPNetworkConfiguration.h"
#import "SPTrackerConfiguration.h"
#import "SPTrackerController.h"
#import "SPTracker.h"
#import "SPSession.h"

@interface TestTrackerController : XCTestCase

@end

@implementation TestTrackerController

- (void)testSessionAccessibilityWhenEnabledAndDisabled {
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" endpoint:@"https://fake-url" method:SPHttpMethodPost];
    XCTAssertNotNil(tracker.session);
    
    tracker.sessionContext = NO;
    XCTAssertNil(tracker.session);
}

- (void)testSubjectUserIdCanBeUpdated {
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" endpoint:@"https://fake-url" method:SPHttpMethodPost];
    XCTAssertNotNil(tracker.subject);
    XCTAssertNil(tracker.subject.userId);
    tracker.subject.userId = @"fakeUserId";
    XCTAssertEqualObjects(@"fakeUserId", tracker.subject.userId);
    tracker.subject.userId = nil;
    XCTAssertNil(tracker.subject.userId);
}

- (void)testSubjectGeoLocationCanBeUpdated {
    id<SPTrackerController> tracker = [SPSnowplow createTrackerWithNamespace:@"namespace" endpoint:@"https://fake-url" method:SPHttpMethodPost];
    XCTAssertNotNil(tracker.subject);
    XCTAssertNil(tracker.subject.geoLatitude);
    tracker.subject.geoLatitude = @12.3456;
    XCTAssertEqualObjects([NSNumber numberWithFloat:12.3456], tracker.subject.geoLatitude);
    tracker.subject.geoLatitude = nil;
    // TODO: On version 3 setting to nil should get back nil.
    // Here it should be nil rather than 0 but it's the way the beneith SPSubject works.
    XCTAssertEqualObjects([NSNumber numberWithFloat:0], tracker.subject.geoLatitude);
}

@end
