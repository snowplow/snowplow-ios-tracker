//
//  TestServiceProvider.m
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
//  Authors: Alex Benini, Matus Tomlein
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPSnowplow.h"
#import "SPNetworkConfiguration.h"
#import "SPTrackerConfiguration.h"
#import "SPSession.h"
#import "SPMockEventStore.h"
#import "SPDataPersistence.h"
#import "SPMockNetworkConnection.h"
#import "SPLogger.h"
#import "SPServiceProvider.h"
#import "SPEmitterControllerImpl.h"
#import "SPEmitterConfigurationUpdate.h"
#import "SPTrackerController.h"


@interface TestServiceProvider : XCTestCase

@end

@implementation TestServiceProvider

- (void)setUp {
    [super setUp];
    [SPLogger setLogLevel:SPLogLevelVerbose];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testUpdatingConfigurationRetainsPausedEmitter {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodPost statusCode:200];
    SPEmitterConfiguration *emitterConfig = [[SPEmitterConfiguration alloc] init];
    emitterConfig.eventStore = [SPMockEventStore new];
    emitterConfig.bufferOption = SPBufferOptionSingle;
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"" method:SPHttpMethodPost];
    networkConfig.networkConnection = networkConnection;
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"appid"];
    trackerConfig.installAutotracking = false;
    trackerConfig.screenViewAutotracking = false;
    trackerConfig.lifecycleAutotracking = false;
    SPServiceProvider *serviceProvider = [[SPServiceProvider alloc] initWithNamespace:@"ns" network:networkConfig configurations:@[emitterConfig, trackerConfig]];
    XCTAssertNotNil(serviceProvider);

    // pause emitter
    [[serviceProvider emitterController] pause];

    // refresh configuration
    [serviceProvider resetWithConfigurations:@[[[SPEmitterConfigurationUpdate alloc] init]]];

    // track event and check that emitter is paused
    [[serviceProvider trackerController] track:[[SPStructured alloc] initWithCategory:@"cat" action:@"act"]];
    [NSThread sleepForTimeInterval:3];
    XCTAssertEqual(1, [[serviceProvider emitter] getDbCount]);
    XCTAssertEqual(0, [networkConnection sendingCount]);

    // resume emitting
    [[serviceProvider emitterController] resume];
    [NSThread sleepForTimeInterval:3];
    XCTAssertEqual(1, [networkConnection sendingCount]);
    XCTAssertEqual(0, [[serviceProvider emitter] getDbCount]);
}


@end
