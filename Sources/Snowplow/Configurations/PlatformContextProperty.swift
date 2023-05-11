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

/// Optional properties tracked in the platform context entity
public enum PlatformContextProperty: Int {
    /// The carrier of the SIM inserted in the device
    case carrier
    /// Type of network the device is connected to
    case networkType
    /// Radio access technology that the device is using
    case networkTechnology
    /// Advertising identifier on iOS
    case appleIdfa
    /// UUID identifier for vendors on iOS
    case appleIdfv
    /// Total physical system memory in bytes
    case physicalMemory
    /// Amount of memory in bytes available to the current app
    /// The property is not tracked in the current version of the tracker due to the tracker not being able to access the API, see the issue here: https://github.com/snowplow/snowplow-ios-tracker/issues/772
    case appAvailableMemory
    /// Remaining battery level as an integer percentage of total battery capacity
    case batteryLevel
    /// Battery state for the device
    case batteryState
    /// A Boolean indicating whether Low Power Mode is enabled
    case lowPowerMode
    /// Bytes of storage remaining
    case availableStorage
    /// Total size of storage in bytes
    case totalStorage
    /// A Boolean indicating whether the device orientation is portrait (either upright or upside down)
    case isPortrait
    /// Screen resolution in pixels. Arrives in the form of WIDTHxHEIGHT (e.g., 1200x900). Doesn't change when device orientation changes
    case resolution
    /// Scale factor used to convert logical coordinates to device coordinates of the screen (uses UIScreen.scale on iOS)
    case scale
    /// System language currently used on the device (ISO 639)
    case language
}
