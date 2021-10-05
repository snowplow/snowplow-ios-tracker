//
//  TestPlatformContext.m
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
//  Authors: Matus Tomlein
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPPlatformContext.h"
#import "SPTrackerConstants.h"

@interface TestPlatformContext : XCTestCase

@end

@implementation TestPlatformContext

- (void)testContainsPlatformInfo {
    SPPlatformContext *context = [[SPPlatformContext alloc] init];
    NSDictionary *platformDict = [[context fetchPlatformDict] getAsDictionary];
    XCTAssertNotNil([platformDict objectForKey:kSPPlatformOsType]);
    XCTAssertNotNil([platformDict objectForKey:kSPPlatformOsVersion]);
}

- (void)testContainsMobileInfo {
#if SNOWPLOW_TARGET_IOS
    SPPlatformContext *context = [[SPPlatformContext alloc] init];
    NSDictionary *platformDict = [[context fetchPlatformDict] getAsDictionary];
    XCTAssertNotNil([platformDict objectForKey:kSPMobileAvailableStorage]);
    XCTAssertNotNil([platformDict objectForKey:kSPMobileTotalStorage]);
#endif
}

- (void)testUpdatesMobileInfo {
#if SNOWPLOW_TARGET_IOS
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:0 networkDictUpdateFrequency:1];
    [context fetchPlatformDict];
    long updateCount = [context ephemeralMobileDictUpdatesCount];
    XCTAssertGreaterThan(updateCount, 0);
    [context fetchPlatformDict];
    XCTAssertGreaterThan([context ephemeralMobileDictUpdatesCount], updateCount);
#endif
}

- (void)testDoesntUpdateMobileInfoWithinUpdateWindow {
#if SNOWPLOW_TARGET_IOS
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:1000 networkDictUpdateFrequency:1];
    [context fetchPlatformDict];
    long updateCount = [context ephemeralMobileDictUpdatesCount];
    XCTAssertGreaterThan(updateCount, 0);
    [context fetchPlatformDict];
    XCTAssertEqual([context ephemeralMobileDictUpdatesCount], updateCount);
#endif
}

- (void)testUpdatesNetworkInfo {
#if SNOWPLOW_TARGET_IOS
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:1 networkDictUpdateFrequency:0];
    [context fetchPlatformDict];
    long updateCount = [context ephemeralNetworkDictUpdatesCount];
    XCTAssertGreaterThan(updateCount, 0);
    [context fetchPlatformDict];
    XCTAssertGreaterThan([context ephemeralNetworkDictUpdatesCount], updateCount);
#endif
}

- (void)testDoesntUpdateNetworkInfoWithinUpdateWindow {
#if SNOWPLOW_TARGET_IOS
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:1000 networkDictUpdateFrequency:1];
    [context fetchPlatformDict];
    long updateCount = [context ephemeralNetworkDictUpdatesCount];
    XCTAssertGreaterThan(updateCount, 0);
    [context fetchPlatformDict];
    XCTAssertEqual([context ephemeralNetworkDictUpdatesCount], updateCount);
#endif
}

- (void)testPerformanceOfFetchingNetworkDict {
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:1000 networkDictUpdateFrequency:0];
    [self measureBlock:^{
        for (int i = 0; i < 100; i++) {
            [context fetchPlatformDict];
        }
    }];
}

- (void)testPerformanceOfFetchingMobileDict {
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:0 networkDictUpdateFrequency:1000];
    [self measureBlock:^{
        for (int i = 0; i < 10000; i++) {
            [context fetchPlatformDict];
        }
    }];
}

@end
