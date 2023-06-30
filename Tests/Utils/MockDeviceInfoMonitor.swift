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

import Foundation
@testable import SnowplowTracker

class MockDeviceInfoMonitor: DeviceInfoMonitor {
    var methodAccessCounts: [String : Int] = [:]
    var customAppleIdfv: String? = "appleIdfv"

    override var appleIdfv: String? {
        increaseMethodAccessCount("appleIdfv")
        return customAppleIdfv
    }

    override var deviceVendor: String? {
        increaseMethodAccessCount("deviceVendor")
        return "Apple Inc."
    }

    override var deviceModel: String? {
        increaseMethodAccessCount("deviceModel")
        return "deviceModel"
    }

    override var osVersion: String? {
        increaseMethodAccessCount("osVersion")
        return "13.0.0"
    }

    override var osType: String? {
        increaseMethodAccessCount("osType")
        return "ios"
    }

    override var carrierName: String? {
        increaseMethodAccessCount("carrierName")
        return "att"
    }

    override var networkTechnology: String {
        increaseMethodAccessCount("networkTechnology")
        return "3g"
    }

    override var carrierKey: String {
        return ""
    }

    override var networkType: String {
        increaseMethodAccessCount("networkType")
        return "wifi"
    }

    override var batteryLevel: Int? {
        increaseMethodAccessCount("batteryLevel")
        return 20
    }

    override var batteryState: String {
        increaseMethodAccessCount("batteryState")
        return "charging"
    }

    override var isLowPowerModeEnabled: Bool? {
        increaseMethodAccessCount("isLowPowerModeEnabled")
        return false
    }

    override var physicalMemory: UInt64 {
        increaseMethodAccessCount("physicalMemory")
        return 100000
    }

    override var appAvailableMemory: Int? {
        increaseMethodAccessCount("appAvailableMemory")
        return 1000
    }

    override var availableStorage: Int64? {
        increaseMethodAccessCount("availableStorage")
        return 9000
    }

    override var totalStorage: Int? {
        increaseMethodAccessCount("totalStorage")
        return 900000
    }
    
    override var isPortrait: Bool? {
        return true
    }
    
    override var resolution: String? {
        return "2400x1500"
    }
    
    override var scale: Double? {
        return 2.0
    }
    
    private var _language: String? = "EN"
    override var language: String? {
        get { return _language }
        set { _language = newValue }
    }

    func accessCount(_ method: String) -> Int {
        let count = methodAccessCounts[method] ?? 0
        return count
    }

    func increaseMethodAccessCount(_ method: String) {
        methodAccessCounts[method] = accessCount(method) + 1
    }
}
