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

class SubjectControllerIQWrapper: SubjectController {
    
    private let controller: SubjectController
    
    init(controller: SubjectController) {
        self.controller = controller
    }
    
    // MARK: - Properties

    var userId: String? {
        get { return InternalQueue.sync { controller.userId } }
        set { InternalQueue.sync { controller.userId = newValue } }
    }

    var networkUserId: String? {
        get { return InternalQueue.sync { controller.networkUserId } }
        set { InternalQueue.sync { controller.networkUserId = newValue } }
    }

    var domainUserId: String? {
        get { return InternalQueue.sync { controller.domainUserId } }
        set { InternalQueue.sync { controller.domainUserId = newValue } }
    }

    var useragent: String? {
        get { return InternalQueue.sync { controller.useragent } }
        set { InternalQueue.sync { controller.useragent = newValue } }
    }

    var ipAddress: String? {
        get { return InternalQueue.sync { controller.ipAddress } }
        set { InternalQueue.sync { controller.ipAddress = newValue } }
    }

    var timezone: String? {
        get { return InternalQueue.sync { controller.timezone } }
        set { InternalQueue.sync { controller.timezone = newValue } }
    }

    var language: String? {
        get { return InternalQueue.sync { controller.language } }
        set { InternalQueue.sync { controller.language = newValue } }
    }

    var screenResolution: SPSize? {
        get { return InternalQueue.sync { controller.screenResolution } }
        set { InternalQueue.sync { controller.screenResolution = newValue } }
    }

    var screenViewPort: SPSize? {
        get { return InternalQueue.sync { controller.screenViewPort } }
        set { InternalQueue.sync { controller.screenViewPort = newValue } }
    }

    var colorDepth: NSNumber? {
        get { return InternalQueue.sync { controller.colorDepth } }
        set { InternalQueue.sync { controller.colorDepth = newValue } }
    }

    // MARK: - GeoLocalization

    var geoLatitude: NSNumber? {
        get { return InternalQueue.sync { controller.geoLatitude } }
        set { InternalQueue.sync { controller.geoLatitude = newValue } }
    }

    var geoLongitude: NSNumber? {
        get { return InternalQueue.sync { controller.geoLongitude } }
        set { InternalQueue.sync { controller.geoLongitude = newValue } }
    }

    var geoLatitudeLongitudeAccuracy: NSNumber? {
        get { return InternalQueue.sync { controller.geoLatitudeLongitudeAccuracy } }
        set { InternalQueue.sync { controller.geoLatitudeLongitudeAccuracy = newValue } }
    }

    var geoAltitude: NSNumber? {
        get { return InternalQueue.sync { controller.geoAltitude } }
        set { InternalQueue.sync { controller.geoAltitude = newValue } }
    }

    var geoAltitudeAccuracy: NSNumber? {
        get { return InternalQueue.sync { controller.geoAltitudeAccuracy } }
        set { InternalQueue.sync { controller.geoAltitudeAccuracy = newValue } }
    }

    var geoSpeed: NSNumber? {
        get { return InternalQueue.sync { controller.geoSpeed } }
        set { InternalQueue.sync { controller.geoSpeed = newValue } }
    }

    var geoBearing: NSNumber? {
        get { return InternalQueue.sync { controller.geoBearing } }
        set { InternalQueue.sync { controller.geoBearing = newValue } }
    }

    var geoTimestamp: NSNumber? {
        get { return InternalQueue.sync { controller.geoTimestamp } }
        set { InternalQueue.sync { controller.geoTimestamp = newValue } }
    }

}
