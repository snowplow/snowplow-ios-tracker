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

class InstallTracker: NSObject {
    /// Installation status
    var isNewInstall = false

    var previousInstallTimestamp: Date? {
        let userDefaults = UserDefaults.standard
        let value = userDefaults.object(forKey: kSPInstallTimestamp)
        if value == nil {
            return nil
        } else if let value = value as? Date {
            // v2.0 format
            return value
        } else if let value = value as? NSNumber {
            // v1.7 format
            let timeInterval = TimeInterval(value.doubleValue / 1000)
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }

    override init() {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: kSPInstalledBefore) == nil {
            // mark the install if there's no value in userDefaults
            userDefaults.set(NSNumber(value: true), forKey: kSPInstalledBefore)
            userDefaults.set(Date(), forKey: kSPInstallTimestamp)
            // since the value was missing in userDefaults, we're assuming this is a new install
            isNewInstall = true
        } else {
            // if there's an object in standardUserDefaults - someone has been there!
            isNewInstall = false
        }
    }

    func clearPreviousInstallTimestamp() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: kSPInstallTimestamp)
    }

    func saveBuildAndVersion() {
        if let build = Utilities.appBuild,
           let version = Utilities.appVersion {
            let userDefaults = UserDefaults.standard
            userDefaults.set(build, forKey: kSPPreviousInstallBuild)
            userDefaults.set(version, forKey: kSPPreviousInstallVersion)
        }
    }
}
