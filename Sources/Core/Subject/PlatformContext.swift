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
#if os(iOS)
import UIKit
#endif

/// @class PlatformContext
/// Manages a dictionary (Payload) with platform context. Some properties for mobile platforms are updated on fetch in set intervals.
class PlatformContext {
    private var platformDict: Payload = Payload()
    private var mobileDictUpdateFrequency: TimeInterval = 1.0
    private var networkDictUpdateFrequency: TimeInterval = 10.0
    private var lastUpdatedEphemeralMobileDict: TimeInterval = 0.0
    private var lastUpdatedEphemeralNetworkDict: TimeInterval = 0.0
    private var deviceInfoMonitor: DeviceInfoMonitor
    
    /// List of properties of the platform context to track
    var platformContextProperties: [PlatformContextProperty]?

    /// Initializes a newly allocated PlatformContext object with custom update frequency for mobile and network properties and a custom device info monitor
    /// - Parameters:
    ///   - platformContextProperties: List of properties of the platform context to track
    ///   - mobileDictUpdateFrequency: Minimal gap between subsequent updates of mobile platform information
    ///   - networkDictUpdateFrequency: Minimal gap between subsequent updates of network platform information
    ///   - deviceInfoMonitor: Device monitor for fetching platform information
    /// - Returns: a PlatformContext object
    init(platformContextProperties: [PlatformContextProperty]? = nil,
         mobileDictUpdateFrequency: TimeInterval = 1.0,
         networkDictUpdateFrequency: TimeInterval = 10.0,
         deviceInfoMonitor: DeviceInfoMonitor = DeviceInfoMonitor()) {
        self.platformContextProperties = platformContextProperties
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
    func fetchPlatformDict(userAnonymisation: Bool, advertisingIdentifierRetriever: (() -> UUID?)?) -> Payload {
        #if os(iOS)
        let now = Date().timeIntervalSince1970
        if now - lastUpdatedEphemeralMobileDict >= mobileDictUpdateFrequency {
            setEphemeralMobileDict()
        }
        if now - lastUpdatedEphemeralNetworkDict >= networkDictUpdateFrequency {
            setEphemeralNetworkDict()
        }
        #endif
        if userAnonymisation {
            // mask user identifiers
            let copy = Payload(dictionary: platformDict.dictionary)
            copy[kSPMobileAppleIdfa] = nil
            copy[kSPMobileAppleIdfv] = nil
            return copy
        } else {
            if let retriever = advertisingIdentifierRetriever {
                if shouldTrack(.appleIdfa) && platformDict.dictionary[kSPMobileAppleIdfa] == nil {
                    platformDict[kSPMobileAppleIdfa] = retriever()?.uuidString
                }
            }
            return platformDict
        }
    }

    // MARK: - Private methods

    func setPlatformDict() {
        platformDict = Payload()
        platformDict[kSPPlatformOsType] = deviceInfoMonitor.osType
        platformDict[kSPPlatformOsVersion] = deviceInfoMonitor.osVersion
        platformDict[kSPPlatformDeviceManu] = deviceInfoMonitor.deviceVendor
        platformDict[kSPPlatformDeviceModel] = deviceInfoMonitor.deviceModel

        #if os(iOS)
        setMobileDict()
        #endif
    }

    func setMobileDict() {
        if shouldTrack(.resolution) {
            platformDict[kSPMobileResolution] = deviceInfoMonitor.resolution
        }
        if shouldTrack(.language) {
            // the schema has a max-length 8 for language which iOS exceeds sometimes
            if let language = deviceInfoMonitor.language { platformDict[kSPMobileLanguage] = String(language.prefix(8)) }
        }
        if shouldTrack(.scale) {
            platformDict[kSPMobileScale] = deviceInfoMonitor.scale
        }
        if shouldTrack(.carrier) {
            platformDict[kSPMobileCarrier] = deviceInfoMonitor.carrierName
        }
        if shouldTrack(.totalStorage) {
            platformDict[kSPMobileTotalStorage] = deviceInfoMonitor.totalStorage
        }
        if shouldTrack(.physicalMemory) {
            platformDict[kSPMobilePhysicalMemory] = deviceInfoMonitor.physicalMemory
        }
        
        setEphemeralMobileDict()
        setEphemeralNetworkDict()
    }

    func setEphemeralMobileDict() {
        lastUpdatedEphemeralMobileDict = Date().timeIntervalSince1970

        if shouldTrack(.appleIdfv) && platformDict[kSPMobileAppleIdfv] == nil {
            platformDict[kSPMobileAppleIdfv] = deviceInfoMonitor.appleIdfv
        }
        
        if shouldTrack(.batteryLevel) {
            platformDict[kSPMobileBatteryLevel] = deviceInfoMonitor.batteryLevel
        }
        if shouldTrack(.batteryState) {
            platformDict[kSPMobileBatteryState] = deviceInfoMonitor.batteryState
        }
        if shouldTrack(.lowPowerMode) {
            platformDict[kSPMobileLowPowerMode] = deviceInfoMonitor.isLowPowerModeEnabled
        }
        if shouldTrack(.availableStorage) {
            platformDict[kSPMobileAvailableStorage] = deviceInfoMonitor.availableStorage
        }
        if shouldTrack(.appAvailableMemory) {
            platformDict[kSPMobileAppAvailableMemory] = deviceInfoMonitor.appAvailableMemory
        }
        if shouldTrack(.isPortrait) {
            platformDict[kSPMobileIsPortrait] = deviceInfoMonitor.isPortrait
        }
    }

    func setEphemeralNetworkDict() {
        lastUpdatedEphemeralNetworkDict = Date().timeIntervalSince1970

        if shouldTrack(.networkTechnology) {
            platformDict[kSPMobileNetworkTech] = deviceInfoMonitor.networkTechnology
        }
        if shouldTrack(.networkType) {
            platformDict[kSPMobileNetworkType] = deviceInfoMonitor.networkType
        }
    }
    
    private func shouldTrack(_ property: PlatformContextProperty) -> Bool {
        if let platformContextProperties = platformContextProperties {
            return platformContextProperties.contains(property)
        }
        return true
    }
}
