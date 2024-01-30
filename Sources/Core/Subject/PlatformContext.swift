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

import Foundation
#if os(iOS) || os(visionOS)
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
    
    /// Overrides for retrieving property values
    var platformContextRetriever: PlatformContextRetriever
    
    /// List of properties of the platform context to track
    var platformContextProperties: [PlatformContextProperty]?

    /// Initializes a newly allocated PlatformContext object with custom update frequency for mobile and network properties and a custom device info monitor
    /// - Parameters:
    ///   - platformContextProperties: List of properties of the platform context to track
    ///   - platformContextRetriever: Overrides for the property retrieving behavior
    ///   - mobileDictUpdateFrequency: Minimal gap between subsequent updates of mobile platform information
    ///   - networkDictUpdateFrequency: Minimal gap between subsequent updates of network platform information
    ///   - deviceInfoMonitor: Device monitor for fetching platform information
    /// - Returns: a PlatformContext object
    init(platformContextProperties: [PlatformContextProperty]? = nil,
         platformContextRetriever: PlatformContextRetriever? = nil,
         mobileDictUpdateFrequency: TimeInterval = 1.0,
         networkDictUpdateFrequency: TimeInterval = 10.0,
         deviceInfoMonitor: DeviceInfoMonitor = DeviceInfoMonitor()) {
        self.platformContextProperties = platformContextProperties
        self.platformContextRetriever = platformContextRetriever ?? PlatformContextRetriever()
        self.mobileDictUpdateFrequency = mobileDictUpdateFrequency
        self.networkDictUpdateFrequency = networkDictUpdateFrequency
        self.deviceInfoMonitor = deviceInfoMonitor
        #if os(iOS) || os(visionOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        #endif
        setPlatformDict()
    }

    /// Updates and returns payload dictionary with device context information.
    /// - Parameter userAnonymisation: Whether to anonymise user identifiers (IDFA values)
    func fetchPlatformDict(userAnonymisation: Bool) -> Payload {
        #if os(iOS) || os(visionOS)
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
            if shouldTrack(.appleIdfa) && platformDict.dictionary[kSPMobileAppleIdfa] == nil {
                platformDict[kSPMobileAppleIdfa] = platformContextRetriever.appleIdfa?()?.uuidString
            }
            return platformDict
        }
    }

    // MARK: - Private methods

    func setPlatformDict() {
        platformDict = Payload()
        platformDict[kSPPlatformOsType] = (
            platformContextRetriever.osType == nil ?
            deviceInfoMonitor.osType : platformContextRetriever.osType?()
        )
        platformDict[kSPPlatformOsVersion] = (
            platformContextRetriever.osVersion == nil ?
            deviceInfoMonitor.osVersion : platformContextRetriever.osVersion?()
        )
        platformDict[kSPPlatformDeviceManu] = (
            platformContextRetriever.deviceVendor == nil ?
            deviceInfoMonitor.deviceVendor : platformContextRetriever.deviceVendor?()
        )
        platformDict[kSPPlatformDeviceModel] = (
            platformContextRetriever.deviceModel == nil ?
            deviceInfoMonitor.deviceModel : platformContextRetriever.deviceModel?()
        )

        #if os(iOS) || os(visionOS)
        setMobileDict()
        #endif
    }

    func setMobileDict() {
        if shouldTrack(.resolution) {
            platformDict[kSPMobileResolution] = (
                platformContextRetriever.resolution == nil ?
                deviceInfoMonitor.resolution : platformContextRetriever.resolution?()
            )
        }
        if shouldTrack(.language) {
            // the schema has a max-length 8 for language which iOS exceeds sometimes
            let language = (
                platformContextRetriever.language == nil ?
                deviceInfoMonitor.language : platformContextRetriever.language?()
            )
            if let language = language { platformDict[kSPMobileLanguage] = String(language.prefix(8)) }
        }
        if shouldTrack(.scale) {
            platformDict[kSPMobileScale] = (
                platformContextRetriever.scale == nil ?
                deviceInfoMonitor.scale : platformContextRetriever.scale?()
            )
        }
        if shouldTrack(.carrier) {
            platformDict[kSPMobileCarrier] = (
                platformContextRetriever.carrier == nil ?
                deviceInfoMonitor.carrierName : platformContextRetriever.carrier?()
            )
        }
        if shouldTrack(.totalStorage) {
            platformDict[kSPMobileTotalStorage] = platformContextRetriever.totalStorage?()
        }
        if shouldTrack(.physicalMemory) {
            platformDict[kSPMobilePhysicalMemory] = (
                platformContextRetriever.physicalMemory == nil ?
                deviceInfoMonitor.physicalMemory : platformContextRetriever.physicalMemory?()
            )
        }
        
        setEphemeralMobileDict()
        setEphemeralNetworkDict()
    }

    func setEphemeralMobileDict() {
        lastUpdatedEphemeralMobileDict = Date().timeIntervalSince1970

        if shouldTrack(.appleIdfv) && platformDict[kSPMobileAppleIdfv] == nil {
            platformDict[kSPMobileAppleIdfv] = (
                platformContextRetriever.appleIdfv == nil ?
                deviceInfoMonitor.appleIdfv : platformContextRetriever.appleIdfv?()
            )
        }
        
        if shouldTrack(.batteryLevel) {
            platformDict[kSPMobileBatteryLevel] = (
                platformContextRetriever.batteryLevel == nil ?
                deviceInfoMonitor.batteryLevel : platformContextRetriever.batteryLevel?()
            )
        }
        if shouldTrack(.batteryState) {
            platformDict[kSPMobileBatteryState] = (
                platformContextRetriever.batteryState == nil ?
                deviceInfoMonitor.batteryState : platformContextRetriever.batteryState?()
            )
        }
        if shouldTrack(.lowPowerMode) {
            platformDict[kSPMobileLowPowerMode] = (
                platformContextRetriever.lowPowerMode == nil ?
                deviceInfoMonitor.isLowPowerModeEnabled : platformContextRetriever.lowPowerMode?()
            )
        }
        if shouldTrack(.availableStorage) {
            platformDict[kSPMobileAvailableStorage] = platformContextRetriever.availableStorage?()
        }
        if shouldTrack(.appAvailableMemory) {
            platformDict[kSPMobileAppAvailableMemory] = (
                platformContextRetriever.appAvailableMemory == nil ?
                deviceInfoMonitor.appAvailableMemory : platformContextRetriever.appAvailableMemory?()
            )
        }
        if shouldTrack(.isPortrait) {
            platformDict[kSPMobileIsPortrait] = (
                platformContextRetriever.isPortrait == nil ?
                deviceInfoMonitor.isPortrait : platformContextRetriever.isPortrait?()
            )
        }
    }

    func setEphemeralNetworkDict() {
        lastUpdatedEphemeralNetworkDict = Date().timeIntervalSince1970

        if shouldTrack(.networkTechnology) {
            platformDict[kSPMobileNetworkTech] = (
                platformContextRetriever.networkTechnology == nil ?
                deviceInfoMonitor.networkTechnology : platformContextRetriever.networkTechnology?()
            )
        }
        if shouldTrack(.networkType) {
            platformDict[kSPMobileNetworkType] = (
                platformContextRetriever.networkType == nil ?
                deviceInfoMonitor.networkType : platformContextRetriever.networkType?()
            )
        }
    }
    
    private func shouldTrack(_ property: PlatformContextProperty) -> Bool {
        if let platformContextProperties = platformContextProperties {
            return platformContextProperties.contains(property)
        }
        return true
    }
}
