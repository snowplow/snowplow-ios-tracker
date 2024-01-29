//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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
        let platformDict = context.fetchPlatformDict(userAnonymisation: false).dictionary
        XCTAssertNotNil(platformDict)
        XCTAssertNotNil(platformDict)
    }
    
    func testContainsMobileInfo() {
        let context = PlatformContext(deviceInfoMonitor: MockDeviceInfoMonitor())
        let platformDict = context.fetchPlatformDict(userAnonymisation: false).dictionary
        XCTAssertNotNil(platformDict)
        XCTAssertNotNil(platformDict)
    }
    
    func testAddsAllMockedInfo() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let idfa = UUID()
        let retriever = PlatformContextRetriever(appleIdfa: { idfa })
        let context = PlatformContext(platformContextRetriever: retriever, mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        let platformDict = context.fetchPlatformDict(userAnonymisation: false)
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
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("appAvailableMemory"))
    }
    
    func testDoesntUpdateMobileInfoWithinUpdateWindow() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 1000, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("batteryLevel"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appAvailableMemory"))
    }
    
    func testUpdatesNetworkInfo() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 1, networkDictUpdateFrequency: 0, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(3, deviceInfoMonitor.accessCount("networkType"))
    }
    
    func testDoesntUpdateNetworkInfoWithinUpdateWindow() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1000, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkTechnology"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("networkType"))
    }
    
    func testDoesntUpdateNonEphemeralInfo() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 0, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("carrierName"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("carrierName"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("physicalMemory"))
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("carrierName"))
    }
    
    func testDoesntUpdateIdfvIfNotNil() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
    }
    
    func testUpdatesIdfvIfNil() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        deviceInfoMonitor.customAppleIdfv = nil
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        XCTAssertEqual(1, deviceInfoMonitor.accessCount("appleIdfv"))
        _ = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(2, deviceInfoMonitor.accessCount("appleIdfv"))
    }
    
    func testUpdatesIdfaIfNil() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        var idfa: UUID? = nil
        let retriever = PlatformContextRetriever(appleIdfa: { idfa })
        let context = PlatformContext(
            platformContextRetriever: retriever,
            mobileDictUpdateFrequency: 0,
            networkDictUpdateFrequency: 1,
            deviceInfoMonitor: deviceInfoMonitor
        )
        
        let platformDict1 = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertNil(platformDict1[kSPMobileAppleIdfa])
        
        idfa = UUID()
        let platformDict2 = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(idfa?.uuidString, platformDict2[kSPMobileAppleIdfa] as? String)
    }
    
    func testDoesntUpdateIdfaIfAlreadyRetrieved() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        
        let idfa1 = UUID()
        var idfa = idfa1
        
        let retriever = PlatformContextRetriever(appleIdfa: { idfa })
        let context = PlatformContext(
            platformContextRetriever: retriever,
            mobileDictUpdateFrequency: 0,
            networkDictUpdateFrequency: 1,
            deviceInfoMonitor: deviceInfoMonitor
        )
        
        let platformDict1 = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(idfa1.uuidString, platformDict1[kSPMobileAppleIdfa] as? String)
        
        idfa = UUID()
        let platformDict2 = context.fetchPlatformDict(userAnonymisation: false)
        XCTAssertEqual(idfa1.uuidString, platformDict2[kSPMobileAppleIdfa] as? String)
    }
    
    func testAnonymisesUserIdentifiers() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let retriever = PlatformContextRetriever(appleIdfa: { UUID() })
        let context = PlatformContext(
            platformContextRetriever: retriever,
            mobileDictUpdateFrequency: 0,
            networkDictUpdateFrequency: 1,
            deviceInfoMonitor: deviceInfoMonitor
        )
        let platformDict = context.fetchPlatformDict(userAnonymisation: true)
        XCTAssertNil(platformDict[kSPMobileAppleIdfa])
        XCTAssertNil(platformDict[kSPMobileAppleIdfv])
    }
    
    func testTruncatesLanguageToMax8Chars() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        deviceInfoMonitor.language = "1234567890"
        let context = PlatformContext(mobileDictUpdateFrequency: 0, networkDictUpdateFrequency: 1, deviceInfoMonitor: deviceInfoMonitor)
        let platformDict = context.fetchPlatformDict(userAnonymisation: true)
        XCTAssertEqual("12345678", platformDict[kSPMobileLanguage] as? String)
    }
#endif

    func testOnlyAddsRequestedProperties() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let retriever = PlatformContextRetriever(appleIdfa: { UUID() })
        let context = PlatformContext(
            platformContextProperties: [.appAvailableMemory, .language],
            platformContextRetriever: retriever,
            mobileDictUpdateFrequency: 0,
            networkDictUpdateFrequency: 1,
            deviceInfoMonitor: deviceInfoMonitor)
        let platformDict = context.fetchPlatformDict(userAnonymisation: false)
        
        XCTAssertNotNil(platformDict[kSPPlatformDeviceManu])
#if os(iOS)
        XCTAssertNotNil(platformDict[kSPMobileLanguage])
        XCTAssertNil(platformDict[kSPMobileScale])
        XCTAssertNil(platformDict[kSPMobileResolution])
        XCTAssertNotNil(platformDict[kSPMobileAppAvailableMemory])
        XCTAssertNil(platformDict[kSPMobilePhysicalMemory])
        XCTAssertNil(platformDict[kSPMobileIsPortrait])
        XCTAssertNil(platformDict[kSPMobileAppleIdfa])
#endif
    }
    
    func testPlatformContextRetrieverOverridesProperties() {
        let deviceInfoMonitor = MockDeviceInfoMonitor()
        let idfa = UUID()
        let retriever = PlatformContextRetriever(
            osType: { "r1" },
            osVersion: { "r2" },
            deviceVendor: { "r3" },
            deviceModel: { "r4" },
            carrier: { "r5" },
            networkType: { "r6" },
            networkTechnology: { "r7" },
            appleIdfa: { idfa },
            appleIdfv: { "r9" },
            availableStorage: { 100 },
            totalStorage: { 101 },
            physicalMemory: { 102 },
            appAvailableMemory: { 103 },
            batteryLevel: { 104 },
            batteryState: { "r10" },
            lowPowerMode: { true },
            isPortrait: { false },
            resolution: { "r11" },
            scale: { 105 },
            language: { "r12" }
        )
        let context = PlatformContext(
            platformContextRetriever: retriever,
            deviceInfoMonitor: deviceInfoMonitor)
        let platformDict = context.fetchPlatformDict(userAnonymisation: false)
        
        XCTAssertEqual(platformDict[kSPPlatformOsType] as? String, "r1")
        XCTAssertEqual(platformDict[kSPPlatformOsVersion] as? String, "r2")
        XCTAssertEqual(platformDict[kSPPlatformDeviceManu] as? String, "r3")
        XCTAssertEqual(platformDict[kSPPlatformDeviceModel] as? String, "r4")
        
#if os(iOS) || os(visionOS)
        XCTAssertEqual(platformDict[kSPMobileCarrier] as? String, "r5")
        XCTAssertEqual(platformDict[kSPMobileNetworkType] as? String, "r6")
        XCTAssertEqual(platformDict[kSPMobileNetworkTech] as? String, "r7")
        XCTAssertEqual(platformDict[kSPMobileAppleIdfa] as? String, idfa.uuidString)
        XCTAssertEqual(platformDict[kSPMobileAppleIdfv] as? String, "r9")
        XCTAssertEqual(platformDict[kSPMobileAvailableStorage] as? Int64, 100)
        XCTAssertEqual(platformDict[kSPMobileTotalStorage] as? Int64, 101)
        XCTAssertEqual(platformDict[kSPMobilePhysicalMemory] as? UInt64, 102)
        XCTAssertEqual(platformDict[kSPMobileAppAvailableMemory] as? Int, 103)
        XCTAssertEqual(platformDict[kSPMobileBatteryLevel] as? Int, 104)
        XCTAssertEqual(platformDict[kSPMobileBatteryState] as? String, "r10")
        XCTAssertEqual(platformDict[kSPMobileLowPowerMode] as? Bool, true)
        XCTAssertEqual(platformDict[kSPMobileIsPortrait] as? Bool, false)
        XCTAssertEqual(platformDict[kSPMobileResolution] as? String, "r11")
        XCTAssertEqual(platformDict[kSPMobileScale] as? Double, 105)
        XCTAssertEqual(platformDict[kSPMobileLanguage] as? String, "r12")
#endif
    }
}
