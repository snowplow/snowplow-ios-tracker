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

class TrackerDefaults {
    private(set) static var base64Encoded = true
    private(set) static var trackerVersionSuffix = ""
    private(set) static var devicePlatform: DevicePlatform = Utilities.platform
    private(set) static var foregroundTimeout = 1800
    private(set) static var backgroundTimeout = 1800
    private(set) static var sessionContext = true
    private(set) static var deepLinkContext = true
    private(set) static var screenContext = true
    private(set) static var applicationContext = true
    private(set) static var autotrackScreenViews = true
    private(set) static var lifecycleEvents = false
    private(set) static var exceptionEvents = true
    private(set) static var installEvent = true
    private(set) static var trackerDiagnostic = false
    private(set) static var userAnonymisation = false
    private(set) static var platformContext = true
    private(set) static var geoLocationContext = false
}
