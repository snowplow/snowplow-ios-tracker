//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
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

import XCTest
@testable import SnowplowTracker

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
        XCTAssertEqual("Apple Inc.", platformDict[kSPPlatformDeviceManu] as? String)
        XCTAssertEqual("deviceModel", platformDict[kSPPlatformDeviceModel] as? String)
        XCTAssertEqual("13.0.0", platformDict[kSPPlatformOsVersion] as? String)
        XCTAssertEqual("ios", platformDict[kSPPlatformOsType] as? String)
#if os(iOS)
        XCTAssertEqual("2400x1500", platformDict[kSPMobileResolution] as? String)
        XCTAssertEqual(2.0, platformDict[kSPMobileScale] as? Double)
        XCTAssertEqual("EN", platformDict[kSPMobileLanguage] as? String)
        XCTAssertEqual("appleIdfv", platformDict[kSPMobileAppleIdfv] as? String)
        XCTAssertEqual("att", platformDict[kSPMobileCarrier] as? String)
        XCTAssertEqual("3g", platformDict[kSPMobileNetworkTech] as? String)
        XCTAssertEqual("wifi", platformDict[kSPMobileNetworkType] as? String)
        XCTAssertEqual(20, platformDict[kSPMobileBatteryLevel] as? Int)
        XCTAssertEqual("charging", platformDict[kSPMobileBatteryState] as? String)
        XCTAssertEqual(true, platformDict[kSPMobileIsPortrait] as? Bool)
#endif
    }
    
#if os(iOS)
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
    
    func testTruncatesLanguageToMax8Chars() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        deviceInfoMonitor.language = "1234567890"
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        let platformDict = context.fetchPlatformDict(
            userAnonymisation: true,
            advertisingIdentifierRetriever: { UUID() }
        )
        XCTAssertEqual("12345678", platformDict[kSPMobileLanguage] as? String)
    }
#endif

    func testOnlyAddsRequestedProperties() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(
            platformContextProperties: [.appAvailableMemory, .availableStorage, .language],
            mobileDictUpdateFrequency: 0,
            networkDictUpdateFrequency: 1,
            deviceInfoMonitor: deviceInfoMonitor)
        let platformDict = context.fetchPlatformDict(
            userAnonymisation: false,
            advertisingIdentifierRetriever: { UUID() }
        )
        
        XCTAssertNotNil(platformDict[kSPPlatformDeviceManu])
#if os(iOS)
        XCTAssertNotNil(platformDict[kSPMobileLanguage])
        XCTAssertNil(platformDict[kSPMobileScale])
        XCTAssertNil(platformDict[kSPMobileResolution])
        XCTAssertNotNil(platformDict[kSPMobileAppAvailableMemory])
        XCTAssertNotNil(platformDict[kSPMobileAvailableStorage])
        XCTAssertNil(platformDict[kSPMobilePhysicalMemory])
        XCTAssertNil(platformDict[kSPMobileIsPortrait])
        XCTAssertNil(platformDict[kSPMobileAppleIdfa])
#endif
    }
}
