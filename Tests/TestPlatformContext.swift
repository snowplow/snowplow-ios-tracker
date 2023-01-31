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

#if os(iOS)
class TestPlatformContext: XCTestCase {
    func testContainsPlatformInfo() {
        let context = PlatformContext(deviceInfoMonitor: MockDeviceInfoMonitor())
        let platformDict = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil).dictionary
        XCTAssertNotNil(platformDict)
        XCTAssertNotNil(platformDict)
    }

    func testContainsMobileInfo() {
        let context = PlatformContext(deviceInfoMonitor: MockDeviceInfoMonitor())
        let platformDict = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil).dictionary
        XCTAssertNotNil(platformDict)
        XCTAssertNotNil(platformDict)
    }

    func testAddsAllMockedInfo() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        let idfa = UUID()
        let platformDict = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: { idfa })
        XCTAssertEqual(idfa.uuidString, platformDict[kSPMobileAppleIdfa] as? String)
        XCTAssertEqual("appleIdfv", platformDict[kSPMobileAppleIdfv] as? String)
        XCTAssertEqual("Apple Inc.", platformDict[kSPPlatformDeviceManu] as? String)
        XCTAssertEqual("deviceModel", platformDict[kSPPlatformDeviceModel] as? String)
        XCTAssertEqual("13.0.0", platformDict[kSPPlatformOsVersion] as? String)
        XCTAssertEqual("ios", platformDict[kSPPlatformOsType] as? String)
        XCTAssertEqual("att", platformDict[kSPMobileCarrier] as? String)
        XCTAssertEqual("3g", platformDict[kSPMobileNetworkTech] as? String)
        XCTAssertEqual("wifi", platformDict[kSPMobileNetworkType] as? String)
        XCTAssertEqual(20, platformDict[kSPMobileBatteryLevel] as? Int)
        XCTAssertEqual("charging", platformDict[kSPMobileBatteryState] as? String)
    }

    func testUpdatesMobileInfo() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("appAvailableMemory"))
    }

    func testDoesntUpdateMobileInfoWithinUpdateWindow() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 1000, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
    }

    func testUpdatesNetworkInfo() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 1, networkDictUpdateFrequency: 0, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("networkType"))
    }

    func testDoesntUpdateNetworkInfoWithinUpdateWindow() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1000, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
    }

    func testDoesntUpdateNonEphemeralInfo() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 0, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("totalStorage"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("totalStorage"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("totalStorage"))
    }

    func testDoesntUpdateIdfvIfNotNil() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
    }

    func testUpdatesIdfvIfNil() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        deviceInfoMonitor.customAppleIdfv = nil
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
        _ = context.fetchPlatformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("appleIdfv"))
    }
    
    func testUpdatesIdfaIfNil() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        
        let platformDict1 = context.fetchPlatformDict(
            userAnonymisation: false,
            advertisingIdentifierRetriever: { nil }
        )
        XCTAssertNil(platformDict1[kSPMobileAppleIdfa])
        
        let idfa = UUID()
        let platformDict2 = context.fetchPlatformDict(
            userAnonymisation: false,
            advertisingIdentifierRetriever: { idfa }
        )
        XCTAssertEqual(idfa.uuidString, platformDict2[kSPMobileAppleIdfa] as? String)
    }

    func testDoesntUpdateIdfaIfAlreadyRetrieved() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        
        let idfa1 = UUID()
        let platformDict1 = context.fetchPlatformDict(
            userAnonymisation: false,
            advertisingIdentifierRetriever: { idfa1 }
        )
        XCTAssertEqual(idfa1.uuidString, platformDict1[kSPMobileAppleIdfa] as? String)
        
        let platformDict2 = context.fetchPlatformDict(
            userAnonymisation: false,
            advertisingIdentifierRetriever: { UUID() }
        )
        XCTAssertEqual(idfa1.uuidString, platformDict2[kSPMobileAppleIdfa] as? String)
    }

    func testAnonymisesUserIdentifiers() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        let platformDict = context.fetchPlatformDict(
            userAnonymisation: true,
            advertisingIdentifierRetriever: { UUID() }
        )
        XCTAssertNil(platformDict[kSPMobileAppleIdfa])
        XCTAssertNil(platformDict[kSPMobileAppleIdfv])
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
#endif
