//
//  TestPlatformContext.swift
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

import XCTest
@testable import SnowplowTracker

class TestPlatformContext: XCTestCase {
    func testContainsPlatformInfo() {
        let context = PlatformContext()
        let platformDict = context.fetchPlatformDict(withUserAnonymisation: false).dictionary
        XCTAssertNotNil(platformDict)
        XCTAssertNotNil(platformDict)
    }

    func testContainsMobileInfo() {
        #if os(iOS)
        let context = PlatformContext()
        let platformDict = context.fetchPlatformDict(withUserAnonymisation: false).dictionary
        XCTAssertNotNil(platformDict)
        XCTAssertNotNil(platformDict)
        #endif
    }

    func testAddsAllMockedInfo() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        guard let platformDict = context.fetchPlatformDict(withUserAnonymisation: false).dictionary else {
            return XCTFail()
        }
        XCTAssertEqual("appleIdfa" as NSObject, platformDict[kSPMobileAppleIdfa])
        XCTAssertEqual("appleIdfv" as NSObject, platformDict[kSPMobileAppleIdfv])
        XCTAssertEqual("Apple Inc." as NSObject, platformDict[kSPPlatformDeviceManu])
        XCTAssertEqual("deviceModel" as NSObject, platformDict[kSPPlatformDeviceModel])
        XCTAssertEqual("13.0.0" as NSObject, platformDict[kSPPlatformOsVersion])
        XCTAssertEqual("ios" as NSObject, platformDict[kSPPlatformOsType])
        XCTAssertEqual("att" as NSObject, platformDict[kSPMobileCarrier])
        XCTAssertEqual("3g" as NSObject, platformDict[kSPMobileNetworkTech])
        XCTAssertEqual("wifi" as NSObject, platformDict[kSPMobileNetworkType])
        XCTAssertEqual(NSNumber(value: 20), platformDict[kSPMobileBatteryLevel])
        XCTAssertEqual("charging" as NSObject, platformDict[kSPMobileBatteryState])
        XCTAssertEqual(NSNumber(value: false), platformDict[kSPMobileLowPowerMode])
        XCTAssertEqual(NSNumber(value: 100000), platformDict[kSPMobilePhysicalMemory])
        XCTAssertEqual(NSNumber(value: 1000), platformDict[kSPMobileAppAvailableMemory])
        XCTAssertEqual(NSNumber(value: 9000), platformDict[kSPMobileAvailableStorage])
        XCTAssertEqual(NSNumber(value: 900000), platformDict[kSPMobileTotalStorage])
    }

    func testUpdatesMobileInfo() {
        #if os(iOS)
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("appAvailableMemory"))
        #endif
    }

    func testDoesntUpdateMobileInfoWithinUpdateWindow() {
        #if os(iOS)
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 1000, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        #endif
    }

    func testUpdatesNetworkInfo() {
        #if os(iOS)
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 1, networkDictUpdateFrequency: 0, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("networkType"))
        #endif
    }

    func testDoesntUpdateNetworkInfoWithinUpdateWindow() {
        #if os(iOS)
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1000, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        #endif
    }

    func testDoesntUpdateNonEphemeralInfo() {
        #if os(iOS)
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 0, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("totalStorage"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("totalStorage"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("totalStorage"))
        #endif
    }

    func testDoesntUpdateIdfaAndIdfvIfNotNil() {
        #if os(iOS)
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfa"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfa"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
        #endif
    }

    func testUpdatesIdfaAndIdfvIfNil() {
        #if os(iOS)
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        deviceInfoMonitor.customAppleIdfa = nil
        deviceInfoMonitor.customAppleIdfv = nil
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfa"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
        _ = context.fetchPlatformDict(withUserAnonymisation: false)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("appleIdfa"))
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("appleIdfv"))
        #endif
    }

    func testAnonymisesUserIdentifiers() {
        #if os(iOS)
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        guard let platformDict = context.fetchPlatformDict(withUserAnonymisation: true).dictionary else {
            return XCTFail()
        }
        XCTAssertNil(platformDict[kSPMobileAppleIdfa])
        XCTAssertNil(platformDict[kSPMobileAppleIdfv])
        #endif
    }

//    func testPerformanceOfFetchingNetworkDict() {
//        let context = PlatformContext(mobileDictUpdateFrequency: 1000, networkDictUpdateFrequency: 0)
//        measure({
//            for _ in 0..<100 {
//                _ = context.fetchPlatformDict(withUserAnonymisation: false)
//            }
//        })
//    }
//
//    func testPerformanceOfFetchingMobileDict() {
//        _ = XCTSkip()
//        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1000)
//        measure({
//            for _ in 0..<10000 {
//                _ = context.fetchPlatformDict(withUserAnonymisation: false)
//            }
//        })
//    }
}
