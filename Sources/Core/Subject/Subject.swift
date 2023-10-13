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

/// @class Subject
/// This class is used to access and persist user information, it represents the current user being tracked.
class Subject : NSObject {
    private var standardDict: [String : String] = [:]
    private var platformContextManager: PlatformContext
    private var geoDict: [String : NSObject] = [:]

    private var _platformContext = false
    var platformContext: Bool {
        get { return sync { _platformContext } }
        set { sync { _platformContext = newValue } }
    }
    
    var platformContextProperties: [PlatformContextProperty]? {
        get { return sync { platformContextManager.platformContextProperties } }
        set { sync { platformContextManager.platformContextProperties = newValue } }
    }
    
    var _geoLocationContext = false
    var geoLocationContext: Bool {
        get { return sync { _geoLocationContext } }
        set { sync { _geoLocationContext = newValue } }
    }
    
    // MARK: - Standard Dictionary
    
    /// Sets the standard pairs for the Subject, called automatically on object creation.

    private var _userId: String?
    /// The user's ID.
    var userId: String? {
        get { return sync { _userId } }
        set(uid) {
            sync {
                _userId = uid
                standardDict[kSPUid] = uid
            }
        }
    }

    private var _networkUserId: String?
    var networkUserId: String? {
        get { return sync { _networkUserId } }
        set(nuid) {
            sync {
                _networkUserId = nuid
                standardDict[kSPNetworkUid] = nuid
            }
        }
    }

    private var _domainUserId: String?
    /// The domain UID.
    var domainUserId: String? {
        get { return sync { _domainUserId } }
        set(duid) {
            sync {
                _domainUserId = duid
                standardDict[kSPDomainUid] = duid
            }
        }
    }

    private var _useragent: String?
    /// The user agent (also known as browser string).
    var useragent: String? {
        get { return sync { _useragent } }
        set(useragent) {
            sync {
                _useragent = useragent
                standardDict[kSPUseragent] = useragent
            }
        }
    }

    private var _ipAddress: String?
    /// The user's IP address.
    var ipAddress: String? {
        get { return sync { _ipAddress } }
        set(ip) {
            sync {
                _ipAddress = ip
                standardDict[kSPIpAddress] = ip
            }
        }
    }

    private var _timezone: String?
    /// The user's timezone.
    var timezone: String? {
        get { return sync { _timezone } }
        set(timezone) {
            sync {
                _timezone = timezone
                standardDict[kSPTimezone] = timezone
            }
        }
    }

    private var _language: String?
    /// The user's language.
    var language: String? {
        get { return sync { _language } }
        set(lang) {
            sync {
                _language = lang
                standardDict[kSPLanguage] = lang
            }
        }
    }

    private var _colorDepth: NSNumber?
    /// The user's color depth.
    var colorDepth: NSNumber? {
        get { return sync { _colorDepth } }
        set(depth) {
            sync {
                _colorDepth = depth
                let res = "\(depth?.stringValue ?? "")"
                standardDict[kSPColorDepth] = res
            }
        }
    }

    var _screenResolution: SPSize?
    var screenResolution: SPSize? {
        get { return sync { _screenResolution } }
        set {
            sync {
                _screenResolution = newValue
                if let size = newValue {
                    let res = "\((NSNumber(value: size.width)).stringValue)x\((NSNumber(value: size.height)).stringValue)"
                    standardDict[kSPResolution] = res
                } else {
                    standardDict.removeValue(forKey: kSPResolution)
                }
            }
        }
    }

    var _screenViewPort: SPSize?
    var screenViewPort: SPSize? {
        get { return sync { _screenViewPort } }
        set {
            sync {
                _screenViewPort = newValue
                if let size = newValue {
                    let res = "\((NSNumber(value: size.width)).stringValue)x\((NSNumber(value: size.height)).stringValue)"
                    standardDict[kSPViewPort] = res
                } else {
                    standardDict.removeValue(forKey: kSPViewPort)
                }
            }
        }
    }
    
    // MARK: - GeoLocation Dictionary

    /// Optional geolocation context, if run will allocate memory for the geolocation context

    /// Latitude value for the geolocation context.
    var geoLatitude: NSNumber? {
        get { return sync { geoDict[kSPGeoLatitude] as? NSNumber } }
        set(latitude) { sync { geoDict[kSPGeoLatitude] = latitude } }
    }

    /// Longitude value for the geo context.
    var geoLongitude: NSNumber? {
        get { return sync { geoDict[kSPGeoLongitude] as? NSNumber } }
        set(longitude) { sync { geoDict[kSPGeoLongitude] = longitude } }
    }

    /// LatitudeLongitudeAccuracy value for the geolocation context.
    var geoLatitudeLongitudeAccuracy: NSNumber? {
        get { return sync { geoDict[kSPGeoLatLongAccuracy] as? NSNumber } }
        set { sync { geoDict[kSPGeoLatLongAccuracy] = newValue } }
    }

    /// Altitude value for the geolocation context.
    var geoAltitude: NSNumber? {
        get { return sync { geoDict[kSPGeoAltitude] as? NSNumber } }
        set(altitude) { sync { geoDict[kSPGeoAltitude] = altitude } }
    }

    /// AltitudeAccuracy value for the geolocation context.
    var geoAltitudeAccuracy: NSNumber? {
        get { return sync { geoDict[kSPGeoAltitudeAccuracy] as? NSNumber } }
        set(altitudeAccuracy) { sync { geoDict[kSPGeoAltitudeAccuracy] = altitudeAccuracy } }
    }

    var geoBearing: NSNumber? {
        get { return sync { geoDict[kSPGeoBearing] as? NSNumber } }
        set(bearing) { sync { geoDict[kSPGeoBearing] = bearing } }
    }

    /// Speed value for the geolocation context.
    var geoSpeed: NSNumber? {
        get { return sync { geoDict[kSPGeoSpeed] as? NSNumber } }
        set(speed) { sync { geoDict[kSPGeoSpeed] = speed } }
    }

    /// Timestamp value for the geolocation context.
    var geoTimestamp: NSNumber? {
        get { return sync { geoDict[kSPGeoTimestamp] as? NSNumber } }
        set(timestamp) { sync { geoDict[kSPGeoTimestamp] = timestamp } }
    }

    init(platformContext: Bool = false,
         platformContextProperties: [PlatformContextProperty]? = nil,
         geoLocationContext geoContext: Bool = false,
         subjectConfiguration config: SubjectConfiguration? = nil) {
        self.platformContextManager = PlatformContext(platformContextProperties: platformContextProperties)
        super.init()
        platformContextManager.platformContextProperties = platformContextProperties
        _platformContext = platformContext
        _geoLocationContext = geoContext
        
        screenResolution = Utilities.resolution
        screenViewPort = Utilities.viewPort
        language = Utilities.language
        timezone = Utilities.timezone
        
        if let config = config {
            if let v = config.userId { userId = v }
            if let v = config.networkUserId { networkUserId = v }
            if let v = config.domainUserId { domainUserId = v }
            if let v = config.useragent { useragent = v }
            if let v = config.ipAddress { ipAddress = v }
            if let v = config.timezone { timezone = v }
            if let v = config.language { language = v }
            if let v = config.screenResolution { screenResolution = v }
            if let v = config.screenViewPort { screenViewPort = v }
            if let v = config.colorDepth { colorDepth = v }
            
            // geolocation
            if let v = config.geoLatitude { geoLatitude = v }
            if let v = config.geoLongitude { geoLongitude = v }
            if let v = config.geoLatitudeLongitudeAccuracy { geoLatitudeLongitudeAccuracy = v }
            if let v = config.geoAltitude { geoAltitude = v }
            if let v = config.geoAltitudeAccuracy { geoAltitudeAccuracy = v }
            if let v = config.geoSpeed { geoSpeed = v }
            if let v = config.geoBearing { geoBearing = v }
            if let v = config.geoTimestamp { geoTimestamp = v }
        }
    }

    /// Gets all standard dictionary pairs to decorate the event with.
    /// - Parameter userAnonymisation: Whether to anonymise user identifiers
    /// - Returns: A SPPayload with all standard pairs.

    //#pragma clang diagnostic pop

    func standardDict(userAnonymisation: Bool) -> [String : String] {
        var copy = sync { self.standardDict }
        if userAnonymisation {
            copy.removeValue(forKey: kSPUid)
            copy.removeValue(forKey: kSPDomainUid)
            copy.removeValue(forKey: kSPNetworkUid)
            copy.removeValue(forKey: kSPIpAddress)
        }
        return copy
    }

    /// Gets all platform dictionary pairs to decorate event with. Returns nil if not enabled.
    /// - Parameter userAnonymisation: Whether to anonymise user identifiers
    /// - Returns: A SPPayload with all platform specific pairs.
    func platformDict(userAnonymisation: Bool, advertisingIdentifierRetriever: (() -> UUID?)?) -> Payload? {
        return sync {
            if _platformContext {
                return platformContextManager.fetchPlatformDict(
                    userAnonymisation: userAnonymisation,
                    advertisingIdentifierRetriever: advertisingIdentifierRetriever)
            } else {
                return nil
            }
        }
    }

    /// Gets the geolocation dictionary if the required keys are available. Returns nil if not enabled.
    /// - Returns: A dictionary with key-value pairs of the geolocation context.
    public var geoLocationDict: [String : NSObject]? {
        return sync {
            if _geoLocationContext {
                if geoDict[kSPGeoLatitude] != nil && geoDict[kSPGeoLongitude] != nil {
                    return geoDict
                } else {
                    logDebug(message: "GeoLocation missing required fields; cannot get.")
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    // MARK: - Dispatch queue
    
    private let dispatchQueue = DispatchQueue(label: "snowplow.subject")
    
    private func sync<T>(_ callback: () -> T) -> T {
        dispatchPrecondition(condition: .notOnQueue(dispatchQueue))

        return dispatchQueue.sync(execute: callback)
    }
    
}
