//
//  SPDeviceInfoMonitor.swift
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
import os
#if os(watchOS)
import WatchKit
#endif
#if os(iOS)
import CoreTelephony
#endif
#if os(iOS) || os(tvOS)
import UIKit
#endif

class DeviceInfoMonitor {
    /// Returns a generated string unique to each device, used only for serving advertisements. This works only if you have the AdSupport library in your project and you enable the compiler flag <code>SNOWPLOW_IDFA_ENABLED</code> to your build settings.
    /// - Returns: A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
    /*
     The IDFA can be retrieved using selectors rather than proper instance methods because
     the compiler would complain about the missing AdSupport framework.
     As stated in the header file, this only works if you have the AdSupport library in your project.
     If you have it and you want to use IDFA, add the compiler flag <code>SNOWPLOW_IDFA_ENABLED</code> to your build settings.
     If you haven't AdSupport framework in your project or SNOWPLOW_IDFA_ENABLED it's not set, it just compiles returning a nil advertisingIdentifier.

     Note that `advertisingIdentifier` returns a sequence of 0s when used in the simulator.
     Use a real device if you want a proper IDFA.
     */
    var appleIdfa: String? {
        #if os(iOS) || os(tvOS)
        #if SNOWPLOW_IDFA_ENABLED
        var errorMsg = "ASIdentifierManager not found. Please, add the AdSupport.framework if you want to use it."
        let identifierManagerClass: AnyClass? = NSClassFromString("ASIdentifierManager")
        if identifierManagerClass == nil {
            logError(message: errorMsg)
            return nil
        }

        let sharedManagerSelector = NSSelectorFromString("sharedManager")
        if !(identifierManagerClass?.responds(to: sharedManagerSelector) ?? false) {
            logError(message: errorMsg)
            return nil
        }

        let identifierManager = (identifierManagerClass?.method(for: sharedManagerSelector))(identifierManagerClass, sharedManagerSelector)

        if #available(iOS 14.0, *) {
            errorMsg = "ATTrackingManager not found. Please, add the AppTrackingTransparency.framework if you want to use it."
            let trackingManagerClass: AnyClass? = NSClassFromString("ATTrackingManager")
            if trackingManagerClass == nil {
                logError(message: errorMsg)
                return nil
            }

            let trackingStatusSelector = NSSelectorFromString("trackingAuthorizationStatus")
            if !(trackingManagerClass?.responds(to: trackingStatusSelector) ?? false) {
                logError(message: errorMsg)
                return nil
            }

            //notDetermined = 0, restricted = 1, denied = 2, authorized = 3
            let authorizationStatus = (Int(trackingManagerClass?.method(for: trackingStatusSelector) ?? 0))(trackingManagerClass, trackingStatusSelector)

            if authorizationStatus != 3 {
                logDebug(message: String(format: "The user didn't let tracking of IDFA. Authorization status is: %d", authorizationStatus))
                return nil
            }
        } else {
            let isAdvertisingTrackingEnabledSelector = NSSelectorFromString("isAdvertisingTrackingEnabled")
            if !(identifierManager?.responds(to: isAdvertisingTrackingEnabledSelector) ?? false) {
                logError(message: errorMsg)
                return nil
            }

            let isAdvertisingTrackingEnabled = (Bool(identifierManager?.method(for: isAdvertisingTrackingEnabledSelector) ?? false))(identifierManager, isAdvertisingTrackingEnabledSelector)
            if !isAdvertisingTrackingEnabled {
                logError(message: "The user didn't let tracking of IDFA.")
                return nil
            }
        }

        let advertisingIdentifierSelector = NSSelectorFromString("advertisingIdentifier")
        if !(identifierManager?.responds(to: advertisingIdentifierSelector) ?? false) {
            logError(message: "ASIdentifierManager doesn't respond to selector `advertisingIdentifier`.")
            return nil
        }

        if let uuid = (identifierManager?.method(for: advertisingIdentifierSelector) as? UUID)(identifierManager, advertisingIdentifierSelector) {
            return uuid.uuidString
        }
        #endif
        #endif
        return nil
    }

    /// Returns the generated identifier for vendors. More info can be found in UIDevice's identifierForVendor documentation. If you do not want to use IDFV, add the comiler flag <code>SNOWPLOW_NO_IDFV</code> to your build settings.
    /// - Returns: A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
    var appleIdfv: String? {
        #if os(iOS) || os(tvOS)
        #if !SNOWPLOW_NO_IDFV
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            return idfv
        }
        #endif
        #endif
        return nil
    }

    /// Returns the current device's vendor in the form of a string.
    /// - Returns: A string with vendor, i.e. "Apple Inc."
    var deviceVendor: String? {
        return "Apple Inc."
    }

    /// Returns the current device's model in the form of a string.
    /// - Returns: A string with device model.
    var deviceModel: String? {
        let simulatorModel = (ProcessInfo.processInfo.environment)["SIMULATOR_MODEL_IDENTIFIER"]
        if simulatorModel != nil {
            return simulatorModel
        }
        
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    /// This is to detect what the version of mobile OS of the current device.
    /// - Returns: The current device's OS version type as a string.
    var osVersion: String? {
        #if os(iOS) || os(tvOS)
        return UIDevice.current.systemVersion
        #elseif os(watchOS)
        return WKInterfaceDevice.current().systemVersion
        #else
        var osxMajorVersion: Int32
        var osxMinorVersion: Int32
        var osxPatchFixVersion: Int32
        let info = ProcessInfo.processInfo
        let systemVersion = info.operatingSystemVersion
        osxMajorVersion = Int32(systemVersion.majorVersion)
        osxMinorVersion = Int32(systemVersion.minorVersion)
        osxPatchFixVersion = Int32(systemVersion.patchVersion)
        let versionString = "\(osxMajorVersion).\(osxMinorVersion).\(osxPatchFixVersion)"
        return versionString
        #endif
    }

    var osType: String? {
        #if os(iOS)
        return "ios"
        #elseif os(tvOS)
        return "tvos"
        #elseif os(watchOS)
        return "watchos"
        #else
        return "osx"
        #endif
    }

    /// Returns the carrier of the SIM inserted in the device.
    /// - Returns: A string containing the carrier name of the service provider.
    var carrierName: String? {
        #if os(iOS)
        let networkInfo = CTTelephonyNetworkInfo()
        var carrier: CTCarrier?
        if #available(iOS 12.1, *) {
            // `serviceSubscribersCellularProviders` has a bug in the iOS 12.0 so we use it from iOS 12.1
            let carrierKey = self.carrierKey
            let services = networkInfo.serviceSubscriberCellularProviders
            carrier = services?[carrierKey]
        } else {
            carrier = networkInfo.subscriberCellularProvider
        }
        return carrier?.carrierName
        #else
        return nil
        #endif
    }

    /// Returns the Network Technology the device is using.
    /// - Returns: A string containing the Network Technology.
    var networkTechnology: String? {
        #if os(iOS)
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.1, *) {
            // `serviceCurrentRadioAccessTechnology` has a bug in the iOS 12.0 so we use it from iOS 12.1
            let carrierKey = self.carrierKey
            let services = networkInfo.serviceCurrentRadioAccessTechnology
            return services?[carrierKey]
        } else {
            return networkInfo.currentRadioAccessTechnology
        }
        #else
        return nil
        #endif
    }

    var carrierKey: String {
        #if os(iOS)
        if #available(iOS 12.1, *) {
            let networkInfo = CTTelephonyNetworkInfo()
            // `serviceSubscribersCellularProviders` has a bug in the iOS 12.0 so we use it from iOS 12.1
            let services = networkInfo.serviceSubscriberCellularProviders
            let carrierKeys = services?.keys
            // From iOS 12, iPhones with eSIMs can return multiple carrier providers.
            // We can't prefer anyone of them so we track the first reported.
            return carrierKeys?.first ?? ""
        }
        #endif
        return ""
    }

    /// Returns the Network Type the device is connected to.
    /// - Returns: A string containing the Network Type.
    var networkType: String? {
        #if os(iOS)
        let networkStatus = SNOWReachability.forInternetConnection()?.networkStatus
        switch networkStatus {
        case .offline:
            return "offline"
        case .wifi:
            return "wifi"
        case .wwan:
            return "mobile"
        default:
            break
        }
        #endif
        return "offline"
    }

    /// Returns remaining battery level as an integer percentage of total battery capacity.
    /// - Returns: Battery level.
    var batteryLevel: Int? {
        #if os(iOS)
        let batteryLevel = UIDevice.current.batteryLevel
        if batteryLevel != Float(UIDevice.BatteryState.unknown.rawValue) && batteryLevel >= 0 {
            return Int(batteryLevel * 100)
        }
        #endif
        return nil
    }

    /// Returns battery state for the device.
    /// - Returns: One of "charging", "full", "unplugged" or NULL
    var batteryState: String {
        #if os(iOS)
        switch UIDevice.current.batteryState {
        case .charging:
            return "charging"
        case .full:
            return "full"
        case .unplugged:
            return "unplugged"
        default:
            return ""
        }
        #else
        return ""
        #endif
    }

    /// Returns whether low power mode is activated.
    /// - Returns: Boolean indicating the state of low power mode.
    var isLowPowerModeEnabled: Bool? {
        #if os(iOS)
        return ProcessInfo.processInfo.isLowPowerModeEnabled
        #else
        return nil
        #endif
    }

    /// Returns total physical system memory in bytes.
    /// - Returns: Total physical system memory in bytes.
    var physicalMemory: UInt64 {
        return ProcessInfo.processInfo.physicalMemory
    }

    /// Returns the amount of memory in bytes available to the current app (iOS 13+).
    /// - Returns: Amount of memory in bytes available to the current app (or 0 if not supported).
    var appAvailableMemory: Int? {
        // TODO: couldn't find a way to import <os/proc.h>
//        #if os(iOS)
//        if #available(iOS 13.0, *) {
//            return os_proc_available_memory()
//        }
//        #endif
        return nil
    }

    /// Returns number of bytes of storage remaining. The information is requested from the home directory.
    /// - Returns: Bytes of storage remaining.
    var availableStorage: Int64? {
        #if os(iOS)
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            return values.volumeAvailableCapacityForImportantUsage
        } catch {
            logError(message: "Failed to read available storage size: \(error.localizedDescription)")
        }
        #endif
        return nil
    }

    /// Returns the total number of bytes of storage. The information is requested from the home directory.
    /// - Returns: Total size of storage in bytes.
    var totalStorage: Int? {
        #if os(iOS)
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey])
            return values.volumeTotalCapacity
        } catch {
            logError(message: "Failed to read available storage size: \(error.localizedDescription)")
        }
        #endif
        return nil
    }
}
