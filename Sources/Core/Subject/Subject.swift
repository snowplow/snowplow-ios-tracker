//
//  Subject.swift
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
//  Authors: Joshua Beemster
//  License: Apache License Version 2.0
//

import Foundation

/// @class Subject
/// This class is used to access and persist user information, it represents the current user being tracked.
class Subject : NSObject {
    private var standardDict = Payload()
    private var platformContextManager = PlatformContext()
    private var geoLocationDict: [String : NSObject] = [:]

    var platformContext = false
    var geoLocationContext = false
    
    // MARK: - Standard Dictionary
    
    /// Sets the standard pairs for the Subject, called automatically on object creation.

    private var _userId: String?
    /// The user's ID.
    var userId: String? {
        get {
            _userId
        }
        set(uid) {
            _userId = uid
            standardDict.addValueToPayload(uid, forKey: kSPUid)
        }
    }

    private var _networkUserId: String?
    var networkUserId: String? {
        get {
            _networkUserId
        }
        set(nuid) {
            _networkUserId = nuid
            standardDict.addValueToPayload(nuid, forKey: kSPNetworkUid)
        }
    }

    private var _domainUserId: String?
    /// The domain UID.
    var domainUserId: String? {
        get {
            _domainUserId
        }
        set(duid) {
            _domainUserId = duid
            standardDict.addValueToPayload(duid, forKey: kSPDomainUid)
        }
    }

    private var _useragent: String?
    /// The user agent (also known as browser string).
    var useragent: String? {
        get {
            _useragent
        }
        set(useragent) {
            _useragent = useragent
            standardDict.addValueToPayload(useragent, forKey: kSPUseragent)
        }
    }

    private var _ipAddress: String?
    /// The user's IP address.
    var ipAddress: String? {
        get {
            _ipAddress
        }
        set(ip) {
            _ipAddress = ip
            standardDict.addValueToPayload(ip, forKey: kSPIpAddress)
        }
    }

    private var _timezone: String?
    /// The user's timezone.
    var timezone: String? {
        get {
            _timezone
        }
        set(timezone) {
            _timezone = timezone
            standardDict.addValueToPayload(timezone, forKey: kSPTimezone)
        }
    }

    private var _language: String?
    /// The user's language.
    var language: String? {
        get {
            _language
        }
        set(lang) {
            _language = lang
            standardDict.addValueToPayload(lang, forKey: kSPLanguage)
        }
    }

    private var _colorDepth: NSNumber?
    /// The user's color depth.
    var colorDepth: NSNumber? {
        get {
            _colorDepth
        }
        set(depth) {
            _colorDepth = depth
            let res = "\(depth?.stringValue ?? "")"
            standardDict.addValueToPayload(res, forKey: kSPColorDepth)
        }
    }

    var _screenResolution: SPSize?
    var screenResolution: SPSize? {
        get {
            _screenResolution
        }
        set {
            _screenResolution = newValue
            if let size = newValue {
                let res = "\((NSNumber(value: size.width)).stringValue)x\((NSNumber(value: size.height)).stringValue)"
                standardDict.addValueToPayload(res, forKey: kSPResolution)
            } else {
                standardDict.addValueToPayload(nil, forKey: kSPResolution)
            }
        }
    }

    var _screenViewPort: SPSize?
    var screenViewPort: SPSize? {
        get {
            _screenViewPort
        }
        set {
            _screenViewPort = newValue
            if let size = newValue {
                let res = "\((NSNumber(value: size.width)).stringValue)x\((NSNumber(value: size.height)).stringValue)"
                standardDict.addValueToPayload(res, forKey: kSPViewPort)
            } else {
                standardDict.addValueToPayload(nil, forKey: kSPViewPort)
            }
            
        }
    }
    
    // MARK: - GeoLocation Dictionary

    /// Optional geolocation context, if run will allocate memory for the geolocation context

    /// Latitude value for the geolocation context.
    var geoLatitude: NSNumber? {
        get {
            return geoLocationDict[kSPGeoLatitude] as? NSNumber
        }
        set(latitude) {
            geoLocationDict[kSPGeoLatitude] = latitude
        }
    }

    /// Longitude value for the geo context.
    var geoLongitude: NSNumber? {
        get {
            return geoLocationDict[kSPGeoLongitude] as? NSNumber
        }
        set(longitude) {
            geoLocationDict[kSPGeoLongitude] = longitude
        }
    }

    /// LatitudeLongitudeAccuracy value for the geolocation context.
    var geoLatitudeLongitudeAccuracy: NSNumber? {
        get {
            return geoLocationDict[kSPGeoLatLongAccuracy] as? NSNumber
        }
        set(latitudeLongitudeAccuracy) {
            geoLocationDict[kSPGeoLatLongAccuracy] = latitudeLongitudeAccuracy
        }
    }

    /// Altitude value for the geolocation context.
    var geoAltitude: NSNumber? {
        get {
            return geoLocationDict[kSPGeoAltitude] as? NSNumber
        }
        set(altitude) {
            geoLocationDict[kSPGeoAltitude] = altitude
        }
    }

    /// AltitudeAccuracy value for the geolocation context.
    var geoAltitudeAccuracy: NSNumber? {
        get {
            return geoLocationDict[kSPGeoAltitudeAccuracy] as? NSNumber
        }
        set(altitudeAccuracy) {
            geoLocationDict[kSPGeoAltitudeAccuracy] = altitudeAccuracy
        }
    }

    var geoBearing: NSNumber? {
        get {
            return geoLocationDict[kSPGeoBearing] as? NSNumber
        }
        set(bearing) {
            geoLocationDict[kSPGeoBearing] = bearing
        }
    }

    /// Speed value for the geolocation context.
    var geoSpeed: NSNumber? {
        get {
            return geoLocationDict[kSPGeoSpeed] as? NSNumber
        }
        set(speed) {
            geoLocationDict[kSPGeoSpeed] = speed
        }
    }

    /// Timestamp value for the geolocation context.
    var geoTimestamp: NSNumber? {
        get {
            return geoLocationDict[kSPGeoTimestamp] as? NSNumber
        }
        set(timestamp) {
            geoLocationDict[kSPGeoTimestamp] = timestamp
        }
    }

    /// Creates a subject which optionally adds platform and geolocation pairs.
    /// - Parameters:
    ///   - platformContext: Whether to enable the platform context.
    ///   - geoContext: Whether to enabled the geolocation context.
    /// - Returns: A new SPSubject.
    convenience init(platformContext: Bool = false, andGeoContext geoContext: Bool = false) {
        self.init(platformContext: platformContext, geoLocationContext: geoContext, subjectConfiguration: nil)
    }

    /// @warning Internal method - do not use in production
    init(platformContext: Bool, geoLocationContext geoContext: Bool, subjectConfiguration config: SubjectConfiguration?) {
        super.init()
        
        self.platformContext = platformContext
        geoLocationContext = geoContext
        
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

    func getStandardDict(withUserAnonymisation userAnonymisation: Bool) -> Payload? {
        if userAnonymisation {
            var copy = standardDict.dictionary ?? [:]
            copy.removeValue(forKey: kSPUid)
            copy.removeValue(forKey: kSPDomainUid)
            copy.removeValue(forKey: kSPNetworkUid)
            copy.removeValue(forKey: kSPIpAddress)
            return Payload(dictionary: copy)
        }
        return standardDict
    }

    /// Gets all platform dictionary pairs to decorate event with. Returns nil if not enabled.
    /// - Parameter userAnonymisation: Whether to anonymise user identifiers
    /// - Returns: A SPPayload with all platform specific pairs.
    func getPlatformDict(withUserAnonymisation userAnonymisation: Bool) -> Payload? {
        if platformContext {
            return platformContextManager.fetchPlatformDict(withUserAnonymisation: userAnonymisation)
        } else {
            return nil
        }
    }

    /// Gets the geolocation dictionary if the required keys are available. Returns nil if not enabled.
    /// - Returns: A dictionary with key-value pairs of the geolocation context.
    func getGeoLocationDict() -> [String : NSObject]? {
        if geoLocationContext {
            if geoLocationDict[kSPGeoLatitude] != nil && geoLocationDict[kSPGeoLongitude] != nil {
                return geoLocationDict
            } else {
                logDebug(message: "GeoLocation missing required fields; cannot get.")
                return nil
            }
        } else {
            return nil
        }
    }
}
