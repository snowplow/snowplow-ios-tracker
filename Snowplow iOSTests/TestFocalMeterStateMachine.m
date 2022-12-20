//
//  TestFocalMeterStateMachine.h
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
//  Authors: Matus Tomlein
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import <Nocilla/Nocilla.h>

#import "SPSnowplow.h"
#import "SPMockLoggerDelegate.h"
#import "SPMockNetworkConnection.h"
#import "SPFocalMeterConfiguration.h"

@interface TestFocalMeterStateMachine : XCTestCase

@property (nonatomic) id<SPTrackerController> tracker;
@property (nonatomic) SPMockLoggerDelegate *logger;

@end

@implementation TestFocalMeterStateMachine

NSString * const endpoint = @"https://fake-snowplow.io";

- (void)setUp {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodPost statusCode:200];
    
    _logger = [SPMockLoggerDelegate new];
    
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithNetworkConnection:networkConnection];
    SPFocalMeterConfiguration *focalMeterConfig = [[SPFocalMeterConfiguration alloc] initWithKantarEndpoint:endpoint];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] init];
    [trackerConfig installAutotracking: NO];
    [trackerConfig diagnosticAutotracking:NO];
    [trackerConfig logLevel:SPLogLevelDebug];
    [trackerConfig loggerDelegate:_logger];

    [SPSnowplow removeAllTrackers];
    self.tracker = [SPSnowplow createTrackerWithNamespace:[[NSUUID UUID] UUIDString]
                                                  network:networkConfig
                                           configurations:@[focalMeterConfig, trackerConfig]];
    
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    self.tracker = nil;
    [SPSnowplow removeAllTrackers];
    [[LSNocilla sharedInstance] stop];
}

- (void)testMakesRequestToKantarEndpointWithUserId {
    NSString *userId = [[_tracker session] userId];

    [self stubRequestForUserID:userId];
    [self.tracker track:[[SPStructured alloc] initWithCategory:@"cat" action:@"act"]];

    [NSThread sleepForTimeInterval:1];

    [self checkForLogWithUserID:userId];
}

- (void)testMakesRequestToKantarEndpointWhenUserIdChanges {
    // enable user anonymisation, should trigger request with anonymous user id
    [self.tracker setUserAnonymisation:YES];
    NSString *userId = @"00000000-0000-0000-0000-000000000000";
    [self stubRequestForUserID:userId];

    [self.tracker track:[[SPStructured alloc] initWithCategory:@"cat" action:@"act"]];
    [NSThread sleepForTimeInterval:1];
    [self checkForLogWithUserID:userId];

    // disable user anonymisation, should trigger new request
    [self.tracker setUserAnonymisation:NO];
    userId = [[self.tracker session] userId];
    [self stubRequestForUserID:userId];

    [self.tracker track:[[SPStructured alloc] initWithCategory:@"cat" action:@"act"]];
    [NSThread sleepForTimeInterval:1];
    [self checkForLogWithUserID:userId];
}

- (void)stubRequestForUserID:(NSString *)userId {
    NSString *requestUrl = [NSString stringWithFormat:@"%@?vendor=snowplow&cs_fpid=%@&c12=not_set", endpoint, userId];
    stubRequest(@"GET", requestUrl)
        .andReturn(200)
        .withBody(@"");
}

- (void)checkForLogWithUserID:(NSString *)userId {
    NSString *log = [NSString stringWithFormat:@"Request to Kantar endpoint sent with user ID: %@", userId];
    XCTAssertTrue([self.logger.debugLogs containsObject:log]);
}

@end
