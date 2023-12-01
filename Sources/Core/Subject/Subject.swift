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

    var platformContext = false
    
    var platformContextProperties: [PlatformContextProperty]? {
        get { return platformContextManager.platformContextProperties }
        set { platformContextManager.platformContextProperties = newValue }
    }
    
    var geoLocationContext = false
    
    // MARK: - Standard Dictionary
    
    /// Sets the standard pairs for the Subject, called automatically on object creation.

    private var _userId: String?
    /// The user's ID.
    var userId: String? {
        get { return _userId }
        set(uid) {
            _userId = uid
            standardDict[kSPUid] = uid
        }
    }

    private var _networkUserId: String?
    var networkUserId: String? {
        get { return _networkUserId }
        set(nuid) {
            _networkUserId = nuid
            standardDict[kSPNetworkUid] = nuid
        }
    }

    private var _domainUserId: String?
    /// The domain UID.
    var domainUserId: String? {
        get { return _domainUserId }
        set(duid) {
            _domainUserId = duid
            standardDict[kSPDomainUid] = duid
        }
    }

    private var _useragent: String?
    /// The user agent (also known as browser string).
    var useragent: String? {
        get { return _useragent }
        set(useragent) {
            _useragent = useragent
            standardDict[kSPUseragent] = useragent
        }
    }

    private var _ipAddress: String?
    /// The user's IP address.
    var ipAddress: String? {
        get { return _ipAddress }
        set(ip) {
            _ipAddress = ip
            standardDict[kSPIpAddress] = ip
        }
    }

    private var _timezone: String?
    /// The user's timezone.
    var timezone: String? {
        get { return _timezone }
        set(timezone) {
            _timezone = timezone
            standardDict[kSPTimezone] = timezone
        }
    }

    private var _language: String?
    /// The user's language.
    var language: String? {
        get { return _language }
        set(lang) {
            _language = lang
            standardDict[kSPLanguage] = lang
        }
    }

    private var _colorDepth: NSNumber?
    /// The user's color depth.
    var colorDepth: NSNumber? {
        get { return _colorDepth }
        set(depth) {
            _colorDepth = depth
            let res = "\(depth?.stringValue ?? "")"
            standardDict[kSPColorDepth] = res
        }
    }

    var _screenResolution: SPSize?
    var screenResolution: SPSize? {
        get { return _screenResolution }
        set {
            _screenResolution = newValue
            if let size = newValue {
                let res = "\((NSNumber(value: size.width)).stringValue)x\((NSNumber(value: size.height)).stringValue)"
                standardDict[kSPResolution] = res
            } else {
                standardDict.removeValue(forKey: kSPResolution)
            }
        }
    }

    var _screenViewPort: SPSize?
    var screenViewPort: SPSize? {
        get { return _screenViewPort }
        set {
            _screenViewPort = newValue
            if let size = newValue {
                let res = "\((NSNumber(value: size.width)).stringValue)x\((NSNumber(value: size.height)).stringValue)"
                standardDict[kSPViewPort] = res
            } else {
                standardDict.removeValue(forKey: kSPViewPort)
            }
        }
    }
    
    // MARK: - GeoLocation Dictionary

    /// Optional geolocation context, if run will allocate memory for the geolocation context

    /// Latitude value for the geolocation context.
    var geoLatitude: NSNumber? {
        get { return geoDict[kSPGeoLatitude] as? NSNumber }
        set(latitude) { geoDict[kSPGeoLatitude] = latitude }
    }

    /// Longitude value for the geo context.
    var geoLongitude: NSNumber? {
        get { return geoDict[kSPGeoLongitude] as? NSNumber }
        set(longitude) { geoDict[kSPGeoLongitude] = longitude }
    }

    /// LatitudeLongitudeAccuracy value for the geolocation context.
    var geoLatitudeLongitudeAccuracy: NSNumber? {
        get { return geoDict[kSPGeoLatLongAccuracy] as? NSNumber }
        set { geoDict[kSPGeoLatLongAccuracy] = newValue }
    }

    /// Altitude value for the geolocation context.
    var geoAltitude: NSNumber? {
        get { return geoDict[kSPGeoAltitude] as? NSNumber }
        set(altitude) { geoDict[kSPGeoAltitude] = altitude }
    }

    /// AltitudeAccuracy value for the geolocation context.
    var geoAltitudeAccuracy: NSNumber? {
        get { return geoDict[kSPGeoAltitudeAccuracy] as? NSNumber }
        set(altitudeAccuracy) { geoDict[kSPGeoAltitudeAccuracy] = altitudeAccuracy }
    }

    var geoBearing: NSNumber? {
        get { return geoDict[kSPGeoBearing] as? NSNumber }
        set(bearing) { geoDict[kSPGeoBearing] = bearing }
    }

    /// Speed value for the geolocation context.
    var geoSpeed: NSNumber? {
        get { return geoDict[kSPGeoSpeed] as? NSNumber }
        set(speed) { geoDict[kSPGeoSpeed] = speed }
    }

    /// Timestamp value for the geolocation context.
    var geoTimestamp: NSNumber? {
        get { return geoDict[kSPGeoTimestamp] as? NSNumber }
        set(timestamp) { geoDict[kSPGeoTimestamp] = timestamp }
    }

    init(platformContext: Bool = false,
         platformContextProperties: [PlatformContextProperty]? = nil,
         geoLocationContext geoContext: Bool = false,
         subjectConfiguration config: SubjectConfiguration? = nil) {
        self.platformContextManager = PlatformContext(platformContextProperties: platformContextProperties)
        super.init()
        platformContextManager.platformContextProperties = platformContextProperties
        self.platformContext = platformContext
        self.geoLocationContext = geoContext
        
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
        if userAnonymisation {
            var copy = self.standardDict
            copy.removeValue(forKey: kSPUid)
            copy.removeValue(forKey: kSPDomainUid)
            copy.removeValue(forKey: kSPNetworkUid)
            copy.removeValue(forKey: kSPIpAddress)
            return copy
        }
        return self.standardDict
    }

    /// Gets all platform dictionary pairs to decorate event with. Returns nil if not enabled.
    /// - Parameter userAnonymisation: Whether to anonymise user identifiers
    /// - Returns: A SPPayload with all platform specific pairs.
    func platformDict(userAnonymisation: Bool, advertisingIdentifierRetriever: (() -> UUID?)?) -> Payload? {
        if platformContext {
            return platformContextManager.fetchPlatformDict(
                userAnonymisation: userAnonymisation,
                advertisingIdentifierRetriever: advertisingIdentifierRetriever)
        } else {
            return nil
        }
    }

    /// Gets the geolocation dictionary if the required keys are available. Returns nil if not enabled.
    /// - Returns: A dictionary with key-value pairs of the geolocation context.
    public var geoLocationDict: [String : NSObject]? {
        if geoLocationContext {
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
