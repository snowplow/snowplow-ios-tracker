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

class SubjectControllerImpl: Controller, SubjectController {
    // MARK: - Properties

    var userId: String? {
        get {
            return subject?.userId
        }
        set {
            dirtyConfig.userId = newValue
            subject?.userId = newValue
        }
    }

    var networkUserId: String? {
        get {
            return subject?.networkUserId
        }
        set {
            dirtyConfig.networkUserId = newValue
            subject?.networkUserId = newValue
        }
    }

    var domainUserId: String? {
        get {
            return subject?.domainUserId
        }
        set {
            dirtyConfig.domainUserId = newValue
            subject?.domainUserId = newValue
        }
    }

    var useragent: String? {
        get {
            return subject?.useragent
        }
        set {
            dirtyConfig.useragent = newValue
            subject?.useragent = newValue
        }
    }

    var ipAddress: String? {
        get {
            return subject?.ipAddress
        }
        set {
            dirtyConfig.ipAddress = newValue
            subject?.ipAddress = newValue
        }
    }

    var timezone: String? {
        get {
            return subject?.timezone
        }
        set {
            dirtyConfig.timezone = newValue
            subject?.timezone = newValue
        }
    }

    var language: String? {
        get {
            return subject?.language
        }
        set {
            dirtyConfig.language = newValue
            subject?.language = newValue
        }
    }

    var screenResolution: SPSize? {
        get {
            return subject?.screenResolution
        }
        set {
            dirtyConfig.screenResolution = newValue
            subject?.screenResolution = newValue
        }
    }

    var screenViewPort: SPSize? {
        get {
            return subject?.screenViewPort
        }
        set {
            dirtyConfig.screenViewPort = newValue
            subject?.screenViewPort = newValue
        }
    }

    var colorDepth: NSNumber? {
        get {
            if let subject = subject {
                return subject.colorDepth
            }
            return nil
        }
        set {
            dirtyConfig.colorDepth = newValue
            subject?.colorDepth = newValue
        }
    }

    // MARK: - GeoLocalization

    var geoLatitude: NSNumber? {
        get {
            return subject?.geoLatitude
        }
        set {
            subject?.geoLatitude = newValue
        }
    }

    var geoLongitude: NSNumber? {
        get {
            return subject?.geoLongitude
        }
        set {
            subject?.geoLongitude = newValue
        }
    }

    var geoLatitudeLongitudeAccuracy: NSNumber? {
        get {
            return subject?.geoLatitudeLongitudeAccuracy
        }
        set {
            subject?.geoLatitudeLongitudeAccuracy = newValue
        }
    }

    var geoAltitude: NSNumber? {
        get {
            return subject?.geoAltitude
        }
        set {
            subject?.geoAltitude = newValue
        }
    }

    var geoAltitudeAccuracy: NSNumber? {
        get {
            return subject?.geoAltitudeAccuracy
        }
        set {
            subject?.geoAltitudeAccuracy = newValue
        }
    }

    var geoSpeed: NSNumber? {
        get {
            return subject?.geoSpeed
        }
        set {
            subject?.geoSpeed = newValue
        }
    }

    var geoBearing: NSNumber? {
        get {
            return subject?.geoBearing
        }
        set {
            subject?.geoBearing = newValue
        }
    }

    var geoTimestamp: NSNumber? {
        get {
            return subject?.geoTimestamp
        }
        set {
            subject?.geoTimestamp = newValue
        }
    }

    // MARK: - Private methods

    private var subject: Subject? {
        get {
            return serviceProvider.tracker.subject
        }
    }

    private var dirtyConfig: SubjectConfiguration {
        return serviceProvider.subjectConfiguration
    }
}
