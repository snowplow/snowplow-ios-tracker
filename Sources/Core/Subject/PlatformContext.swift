//
//  PlatformContext.swift
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

import Foundation
#if os(iOS)
import UIKit
#endif

/// @class PlatformContext
/// Manages a dictionary (Payload) with platform context. Some properties for mobile platforms are updated on fetch in set intervals.
class PlatformContext {
    private var platformDict: Payload = Payload()
    private var mobileDictUpdateFrequency: TimeInterval = 0.1
    private var networkDictUpdateFrequency: TimeInterval = 10.0
    private var lastUpdatedEphemeralMobileDict: TimeInterval = 0.0
    private var lastUpdatedEphemeralNetworkDict: TimeInterval = 0.0
    private var deviceInfoMonitor: DeviceInfoMonitor

    /// Initializes a newly allocated PlatformContext object with custom update frequency for mobile and network properties and a custom device info monitor
    /// - Parameters:
    ///   - mobileDictUpdateFrequency: Minimal gap between subsequent updates of mobile platform information
    ///   - networkDictUpdateFrequency: Minimal gap between subsequent updates of network platform information
    ///   - deviceInfoMonitor: Device monitor for fetching platform information
    /// - Returns: a PlatformContext object
    init(mobileDictUpdateFrequency: TimeInterval = 0.1, networkDictUpdateFrequency: TimeInterval = 10.0, deviceInfoMonitor: DeviceInfoMonitor = DeviceInfoMonitor()) {
        self.mobileDictUpdateFrequency = mobileDictUpdateFrequency
        self.networkDictUpdateFrequency = networkDictUpdateFrequency
        self.deviceInfoMonitor = deviceInfoMonitor
        #if os(iOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        #endif
        setPlatformDict()
    }

    /// Updates and returns payload dictionary with device context information.
    /// - Parameter userAnonymisation: Whether to anonymise user identifiers (IDFA values)
    func fetchPlatformDict(withUserAnonymisation userAnonymisation: Bool) -> Payload {
        #if os(iOS)
        objc_sync_enter(self)
        let now = Date().timeIntervalSince1970
        if now - lastUpdatedEphemeralMobileDict >= mobileDictUpdateFrequency {
            setEphemeralMobileDict()
        }
        if now - lastUpdatedEphemeralNetworkDict >= networkDictUpdateFrequency {
            setEphemeralNetworkDict()
        }
        objc_sync_exit(self)
        #endif
        if userAnonymisation {
            // mask user identifiers
            let copy = Payload(dictionary: platformDict.dictionary ?? [:])
            copy.addValueToPayload(nil, forKey: kSPMobileAppleIdfa)
            copy.addValueToPayload(nil, forKey: kSPMobileAppleIdfv)
            return copy
        } else {
            return platformDict
        }
    }

    // MARK: - Private methods

    func setPlatformDict() {
        platformDict = Payload()
        platformDict.addValueToPayload(deviceInfoMonitor.osType, forKey: kSPPlatformOsType)
        platformDict.addValueToPayload(deviceInfoMonitor.osVersion, forKey: kSPPlatformOsVersion)
        platformDict.addValueToPayload(deviceInfoMonitor.deviceVendor, forKey: kSPPlatformDeviceManu)
        platformDict.addValueToPayload(deviceInfoMonitor.deviceModel, forKey: kSPPlatformDeviceModel)

        #if os(iOS)
        setMobileDict()
        #endif
    }

    func setMobileDict() {
        platformDict.addValueToPayload(deviceInfoMonitor.carrierName, forKey: kSPMobileCarrier)
        if let totalStorage = deviceInfoMonitor.totalStorage {
            platformDict.addNumericValueToPayload(NSNumber(value: totalStorage), forKey: kSPMobileTotalStorage)
        }
        platformDict.addNumericValueToPayload(NSNumber(value: deviceInfoMonitor.physicalMemory), forKey: kSPMobilePhysicalMemory)
        
        setEphemeralMobileDict()
        setEphemeralNetworkDict()
    }

    func setEphemeralMobileDict() {
        lastUpdatedEphemeralMobileDict = Date().timeIntervalSince1970

        if let currentDict = platformDict.dictionary {
            if currentDict[kSPMobileAppleIdfa] == nil {
                platformDict.addValueToPayload(deviceInfoMonitor.appleIdfa, forKey: kSPMobileAppleIdfa)
            }
            if currentDict[kSPMobileAppleIdfv] == nil {
                platformDict.addValueToPayload(deviceInfoMonitor.appleIdfv, forKey: kSPMobileAppleIdfv)
            }
            
            if let batteryLevel = deviceInfoMonitor.batteryLevel {
                platformDict.addNumericValueToPayload(NSNumber(value: batteryLevel), forKey: kSPMobileBatteryLevel)
            }
            platformDict.addValueToPayload(deviceInfoMonitor.batteryState, forKey: kSPMobileBatteryState)
            if let isLowPowerModeEnabled = deviceInfoMonitor.isLowPowerModeEnabled {
                platformDict.addNumericValueToPayload(NSNumber(value: isLowPowerModeEnabled), forKey: kSPMobileLowPowerMode)
            }
            if let availableStorage = deviceInfoMonitor.availableStorage {
                platformDict.addNumericValueToPayload(NSNumber(value: availableStorage), forKey: kSPMobileAvailableStorage)
            }
            if let appAvailableMemory = deviceInfoMonitor.appAvailableMemory {
                platformDict.addNumericValueToPayload(NSNumber(value: appAvailableMemory), forKey: kSPMobileAppAvailableMemory)
            }
        }
    }

    func setEphemeralNetworkDict() {
        lastUpdatedEphemeralNetworkDict = Date().timeIntervalSince1970

        platformDict.addValueToPayload(deviceInfoMonitor.networkTechnology, forKey: kSPMobileNetworkTech)
        platformDict.addValueToPayload(deviceInfoMonitor.networkType, forKey: kSPMobileNetworkType)
    }
}
