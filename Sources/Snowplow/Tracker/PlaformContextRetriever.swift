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

/// Overrides for the values for properties of the platform context.
public class PlatformContextRetriever {
    
    /// Operating system type (e.g., ios, tvos, watchos, osx, android)
    public var osType: (() -> String?)? = nil
    
    /// The current version of the operating system
    public var osVersion: (() -> String?)? = nil
    
    /// The manufacturer of the product/hardware
    public var deviceVendor: (() -> String?)? = nil
    
    /// The end-user-visible name for the end product
    public var deviceModel: (() -> String?)? = nil

    /// The carrier of the SIM inserted in the device
    public var carrier: (() -> String?)? = nil
    
    /// Type of network the device is connected to
    public var networkType: (() -> String?)? = nil
    
    /// Radio access technology that the device is using
    public var networkTechnology: (() -> String?)? = nil
    
    /// Advertising identifier on iOS
    public var appleIdfa: (() -> UUID?)? = nil
    
    /// UUID identifier for vendors on iOS
    public var appleIdfv: (() -> String?)? = nil
    
    /// Bytes of storage remaining
    public var availableStorage: (() -> Int64?)? = nil
    
    /// Total size of storage in bytes
    public var totalStorage: (() -> Int64?)? = nil
    
    /// Total physical system memory in bytes
    public var physicalMemory: (() -> UInt64?)? = nil
    
    /// Amount of memory in bytes available to the current app
    public var appAvailableMemory: (() -> Int?)? = nil
    
    /// Remaining battery level as an integer percentage of total battery capacity
    public var batteryLevel: (() -> Int?)? = nil
    
    /// Battery state for the device
    public var batteryState: (() -> String?)? = nil
    
    /// A Boolean indicating whether Low Power Mode is enabled
    public var lowPowerMode: (() -> Bool?)? = nil
    
    /// A Boolean indicating whether the device orientation is portrait (either upright or upside down)
    public var isPortrait: (() -> Bool?)? = nil
    
    /// Screen resolution in pixels. Arrives in the form of WIDTHxHEIGHT (e.g., 1200x900). Doesn't change when device orientation changes
    public var resolution: (() -> String?)? = nil
    
    /// Scale factor used to convert logical coordinates to device coordinates of the screen (uses UIScreen.scale on iOS)
    public var scale: (() -> Double?)? = nil
    
    /// System language currently used on the device (ISO 639)
    public var language: (() -> String)? = nil
    
    /// - Parameters:
    ///   - osType: Operating system type (e.g., ios, tvos, watchos, osx, android)
    ///   - osVersion: The current version of the operating system
    ///   - deviceVendor: The manufacturer of the product/hardware
    ///   - deviceModel: The end-user-visible name for the end product
    ///   - carrier: The carrier of the SIM inserted in the device
    ///   - networkType: Type of network the device is connected to
    ///   - networkTechnology: Radio access technology that the device is using
    ///   - appleIdfa: Advertising identifier on iOS
    ///   - appleIdfv: UUID identifier for vendors on iOS
    ///   - availableStorage: Bytes of storage remaining
    ///   - totalStorage: Total size of storage in bytes
    ///   - physicalMemory: Total physical system memory in bytes
    ///   - appAvailableMemory: Amount of memory in bytes available to the current app
    ///   - batteryLevel: Remaining battery level as an integer percentage of total battery capacity
    ///   - batteryState: Battery state for the device
    ///   - lowPowerMode: A Boolean indicating whether Low Power Mode is enabled
    ///   - isPortrait: A Boolean indicating whether the device orientation is portrait (either upright or upside down)
    ///   - resolution: Screen resolution in pixels. Arrives in the form of WIDTHxHEIGHT (e.g., 1200x900). Doesn't change when device orientation changes
    ///   - scale: Scale factor used to convert logical coordinates to device coordinates of the screen (uses UIScreen.scale on iOS)
    ///   - language: System language currently used on the device (ISO 639)
    public init(
        osType: (() -> String?)? = nil,
        osVersion: (() -> String?)? = nil,
        deviceVendor: (() -> String?)? = nil,
        deviceModel: (() -> String?)? = nil,
        carrier: (() -> String?)? = nil,
        networkType: (() -> String?)? = nil,
        networkTechnology: (() -> String?)? = nil,
        appleIdfa: (() -> UUID?)? = nil,
        appleIdfv: (() -> String?)? = nil,
        availableStorage: (() -> Int64?)? = nil,
        totalStorage: (() -> Int64?)? = nil,
        physicalMemory: (() -> UInt64?)? = nil,
        appAvailableMemory: (() -> Int?)? = nil,
        batteryLevel: (() -> Int?)? = nil,
        batteryState: (() -> String?)? = nil,
        lowPowerMode: (() -> Bool?)? = nil,
        isPortrait: (() -> Bool?)? = nil,
        resolution: (() -> String?)? = nil,
        scale: (() -> Double?)? = nil,
        language: (() -> String)? = nil
    ) {
        self.osType = osType
        self.osVersion = osVersion
        self.deviceVendor = deviceVendor
        self.deviceModel = deviceModel
        self.carrier = carrier
        self.networkType = networkType
        self.networkTechnology = networkTechnology
        self.appleIdfa = appleIdfa
        self.appleIdfv = appleIdfv
        self.availableStorage = availableStorage
        self.totalStorage = totalStorage
        self.physicalMemory = physicalMemory
        self.appAvailableMemory = appAvailableMemory
        self.batteryLevel = batteryLevel
        self.batteryState = batteryState
        self.lowPowerMode = lowPowerMode
        self.isPortrait = isPortrait
        self.resolution = resolution
        self.scale = scale
        self.language = language
    }
}
