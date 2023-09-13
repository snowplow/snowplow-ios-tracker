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

@objc(SPDevicePlatform)
public enum DevicePlatform : Int {
    case web = 0
    case mobile
    case desktop
    case serverSideApp
    case general
    case connectedTV
    case gameConsole
    case internetOfThings
}

func devicePlatformToString(_ devicePlatform: DevicePlatform) -> String {
    switch devicePlatform {
    case .web:
        return "web"
    case .mobile:
        return "mob"
    case .desktop:
        return "pc"
    case .serverSideApp:
        return "srv"
    case .general:
        return "app"
    case .connectedTV:
        return "tv"
    case .gameConsole:
        return "cnsl"
    case .internetOfThings:
        return "iot"
    }
}

func stringToDevicePlatform(_ devicePlatformString: String) -> DevicePlatform? {
    if let index = ["web", "mob", "pc", "srv", "app", "tv", "cnsl", "iot"].firstIndex(of: devicePlatformString) {
        return DevicePlatform(rawValue: index)
    }
    return nil
}
