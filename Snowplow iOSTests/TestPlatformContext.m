//
//  TestPlatformContext.m
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
//  Authors: Matus Tomlein
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPPlatformContext.h"
#import "SPTrackerConstants.h"
#import "SPMockDeviceInfoMonitor.h"

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

- (void)testAddsAllMockedInfo {
    SPDeviceInfoMonitor *deviceInfoMonitor = [[SPMockDeviceInfoMonitor alloc] init];
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:0 networkDictUpdateFrequency:1 deviceInfoMonitor:deviceInfoMonitor];
    NSDictionary *platformDict = [[context fetchPlatformDict] getAsDictionary];
    XCTAssertTrue([@"appleIdfa" isEqualToString: [platformDict valueForKey:kSPMobileAppleIdfa]]);
    XCTAssertTrue([@"appleIdfv" isEqualToString: [platformDict valueForKey:kSPMobileAppleIdfv]]);
    XCTAssertTrue([@"Apple Inc." isEqualToString: [platformDict valueForKey:kSPPlatformDeviceManu]]);
    XCTAssertTrue([@"deviceModel" isEqualToString: [platformDict valueForKey:kSPPlatformDeviceModel]]);
    XCTAssertTrue([@"13.0.0" isEqualToString: [platformDict valueForKey:kSPPlatformOsVersion]]);
    XCTAssertTrue([@"ios" isEqualToString: [platformDict valueForKey:kSPPlatformOsType]]);
    XCTAssertTrue([@"att" isEqualToString: [platformDict valueForKey:kSPMobileCarrier]]);
    XCTAssertTrue([@"3g" isEqualToString: [platformDict valueForKey:kSPMobileNetworkTech]]);
    XCTAssertTrue([@"wifi" isEqualToString: [platformDict valueForKey:kSPMobileNetworkType]]);
    XCTAssertTrue([@20 isEqualToNumber: [platformDict valueForKey:kSPMobileBatteryLevel]]);
    XCTAssertTrue([@"charging" isEqualToString: [platformDict valueForKey:kSPMobileBatteryState]]);
    XCTAssertTrue([@NO isEqualToNumber: [platformDict valueForKey:kSPMobileLowPowerMode]]);
    XCTAssertTrue([@100000L isEqualToNumber: [platformDict valueForKey:kSPMobilePhysicalMemory]]);
    XCTAssertTrue([@1000L isEqualToNumber: [platformDict valueForKey:kSPMobileAppAvailableMemory]]);
    XCTAssertTrue([@9000L isEqualToNumber: [platformDict valueForKey:kSPMobileAvailableStorage]]);
    XCTAssertTrue([@900000L isEqualToNumber: [platformDict valueForKey:kSPMobileTotalStorage]]);
}

- (void)testUpdatesMobileInfo {
#if SNOWPLOW_TARGET_IOS
    SPMockDeviceInfoMonitor *deviceInfoMonitor = [[SPMockDeviceInfoMonitor alloc] init];
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:0 networkDictUpdateFrequency:1 deviceInfoMonitor:deviceInfoMonitor];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"batteryLevel"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appAvailableMemory"]);
    [context fetchPlatformDict];
    XCTAssertEqual(2, [deviceInfoMonitor accessCount:@"batteryLevel"]);
    XCTAssertEqual(2, [deviceInfoMonitor accessCount:@"appAvailableMemory"]);
    [context fetchPlatformDict];
    XCTAssertEqual(3, [deviceInfoMonitor accessCount:@"batteryLevel"]);
    XCTAssertEqual(3, [deviceInfoMonitor accessCount:@"appAvailableMemory"]);
#endif
}

- (void)testDoesntUpdateMobileInfoWithinUpdateWindow {
#if SNOWPLOW_TARGET_IOS
    SPMockDeviceInfoMonitor *deviceInfoMonitor = [[SPMockDeviceInfoMonitor alloc] init];
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:1000 networkDictUpdateFrequency:1 deviceInfoMonitor:deviceInfoMonitor];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"batteryLevel"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appAvailableMemory"]);
    [context fetchPlatformDict];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"batteryLevel"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appAvailableMemory"]);
    [context fetchPlatformDict];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"batteryLevel"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appAvailableMemory"]);
#endif
}

- (void)testUpdatesNetworkInfo {
#if SNOWPLOW_TARGET_IOS
    SPMockDeviceInfoMonitor *deviceInfoMonitor = [[SPMockDeviceInfoMonitor alloc] init];
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:1 networkDictUpdateFrequency:0 deviceInfoMonitor:deviceInfoMonitor];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"networkTechnology"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"networkType"]);
    [context fetchPlatformDict];
    XCTAssertEqual(2, [deviceInfoMonitor accessCount:@"networkTechnology"]);
    XCTAssertEqual(2, [deviceInfoMonitor accessCount:@"networkType"]);
    [context fetchPlatformDict];
    XCTAssertEqual(3, [deviceInfoMonitor accessCount:@"networkTechnology"]);
    XCTAssertEqual(3, [deviceInfoMonitor accessCount:@"networkType"]);
#endif
}

- (void)testDoesntUpdateNetworkInfoWithinUpdateWindow {
#if SNOWPLOW_TARGET_IOS
    SPMockDeviceInfoMonitor *deviceInfoMonitor = [[SPMockDeviceInfoMonitor alloc] init];
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:0 networkDictUpdateFrequency:1000 deviceInfoMonitor:deviceInfoMonitor];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"networkTechnology"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"networkType"]);
    [context fetchPlatformDict];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"networkTechnology"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"networkType"]);
    [context fetchPlatformDict];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"networkTechnology"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"networkType"]);
#endif
}

- (void)testDoesntUpdateNonEphemeralInfo {
#if SNOWPLOW_TARGET_IOS
    SPMockDeviceInfoMonitor *deviceInfoMonitor = [[SPMockDeviceInfoMonitor alloc] init];
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:0 networkDictUpdateFrequency:0 deviceInfoMonitor:deviceInfoMonitor];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"physicalMemory"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"totalStorage"]);
    [context fetchPlatformDict];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"physicalMemory"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"totalStorage"]);
    [context fetchPlatformDict];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"physicalMemory"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"totalStorage"]);
#endif
}

- (void)testDoesntUpdateIdfaAndIdfvIfNotNil {
#if SNOWPLOW_TARGET_IOS
    SPMockDeviceInfoMonitor *deviceInfoMonitor = [[SPMockDeviceInfoMonitor alloc] init];
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:0 networkDictUpdateFrequency:1 deviceInfoMonitor:deviceInfoMonitor];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appleIdfa"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appleIdfv"]);
    [context fetchPlatformDict];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appleIdfa"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appleIdfv"]);
#endif
}

- (void)testUpdatesIdfaAndIdfvIfNil {
#if SNOWPLOW_TARGET_IOS
    SPMockDeviceInfoMonitor *deviceInfoMonitor = [[SPMockDeviceInfoMonitor alloc] init];
    deviceInfoMonitor.customAppleIdfa = nil;
    deviceInfoMonitor.customAppleIdfv = nil;
    SPPlatformContext *context = [[SPPlatformContext alloc] initWithMobileDictUpdateFrequency:0 networkDictUpdateFrequency:1 deviceInfoMonitor:deviceInfoMonitor];
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appleIdfa"]);
    XCTAssertEqual(1, [deviceInfoMonitor accessCount:@"appleIdfv"]);
    [context fetchPlatformDict];
    XCTAssertEqual(2, [deviceInfoMonitor accessCount:@"appleIdfa"]);
    XCTAssertEqual(2, [deviceInfoMonitor accessCount:@"appleIdfv"]);
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
