//
//  SPTrackerConfiguration.swift
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
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Foundation

@objc(SPTrackerConfigurationProtocol)
public protocol TrackerConfigurationProtocol: AnyObject {
    /// Identifer of the app.
    @objc
    var appId: String { get set }
    /// It sets the device platform the tracker is running on.
    @objc
    var devicePlatform: DevicePlatform { get set }
    /// It indicates whether the JSON data in the payload should be base64 encoded.
    @objc
    var base64Encoding: Bool { get set }
    /// It sets the log level of tracker logs.
    @objc
    var logLevel: LogLevel { get set }
    /// It sets the logger delegate that receive logs from the tracker.
    @objc
    var loggerDelegate: LoggerDelegate? { get set }
    /// Whether application context is sent with all the tracked events.
    @objc
    var applicationContext: Bool { get set }
    /// Whether mobile/platform context is sent with all the tracked events.
    @objc
    var platformContext: Bool { get set }
    /// Whether geo-location context is sent with all the tracked events.
    @objc
    var geoLocationContext: Bool { get set }
    /// Whether session context is sent with all the tracked events.
    @objc
    var sessionContext: Bool { get set }
    /// Whether deepLink context is sent with all the ScreenView events.
    @objc
    var deepLinkContext: Bool { get set }
    /// Whether screen context is sent with all the tracked events.
    @objc
    var screenContext: Bool { get set }
    /// Whether enable automatic tracking of ScreenView events.
    @objc
    var screenViewAutotracking: Bool { get set }
    /// Whether enable automatic tracking of background and foreground transitions.
    @objc
    var lifecycleAutotracking: Bool { get set }
    /// Whether enable automatic tracking of install event.
    @objc
    var installAutotracking: Bool { get set }
    /// Whether enable crash reporting.
    @objc
    var exceptionAutotracking: Bool { get set }
    /// Whether enable diagnostic reporting.
    @objc
    var diagnosticAutotracking: Bool { get set }
    /// Whether to anonymise client-side user identifiers in session (userId, previousSessionId), subject (userId, networkUserId, domainUserId, ipAddress) and platform context entities (IDFA)
    /// Setting this property on a running tracker instance starts a new session (if sessions are tracked).
    @objc
    var userAnonymisation: Bool { get set }
    /// Decorate the v_tracker field in the tracker protocol.
    /// @note Do not use. Internal use only.
    @objc
    var trackerVersionSuffix: String? { get set }
    /// Closure called to retrieve the Identifier for Advertisers (IDFA) from AdSupport module
    /// It is called repeatedly (on each tracked event) until a UUID is returned.
    @objc
    var advertisingIdentifierRetriever: (() -> UUID?)? { get set }
}

/// This class represents the configuration of the tracker and the core tracker properties.
/// The TrackerConfiguration can be used to setup the tracker behaviour indicating what should be
/// tracked in term of automatic tracking and contexts/entities to track with the events.
@objc(SPTrackerConfiguration)
public class TrackerConfiguration: Configuration, TrackerConfigurationProtocol {
    /// Identifer of the app.
    @objc
    public var appId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
    /// It sets the device platform the tracker is running on.
    @objc
    public var devicePlatform = DevicePlatform.mobile
    /// It indicates whether the JSON data in the payload should be base64 encoded.
    @objc
    public var base64Encoding = true
    /// It sets the log level of tracker logs.
    @objc
    public var logLevel = LogLevel.off
    /// It sets the logger delegate that receive logs from the tracker.
    @objc
    public var loggerDelegate: LoggerDelegate?
    /// Whether application context is sent with all the tracked events.
    @objc
    public var applicationContext = TrackerDefaults.applicationContext
    /// Whether mobile/platform context is sent with all the tracked events.
    @objc
    public var platformContext = TrackerDefaults.platformContext
    /// Whether geo-location context is sent with all the tracked events.
    @objc
    public var geoLocationContext = TrackerDefaults.geoLocationContext
    /// Whether session context is sent with all the tracked events.
    @objc
    public var sessionContext = TrackerDefaults.sessionContext
    /// Whether deepLink context is sent with all the ScreenView events.
    @objc
    public var deepLinkContext = TrackerDefaults.deepLinkContext
    /// Whether screen context is sent with all the tracked events.
    @objc
    public var screenContext = TrackerDefaults.screenContext
    /// Whether enable automatic tracking of ScreenView events.
    @objc
    public var screenViewAutotracking = TrackerDefaults.autotrackScreenViews
    /// Whether enable automatic tracking of background and foreground transitions.
    @objc
    public var lifecycleAutotracking = TrackerDefaults.lifecycleEvents
    /// Whether enable automatic tracking of install event.
    @objc
    public var installAutotracking = TrackerDefaults.installEvent
    /// Whether enable crash reporting.
    @objc
    public var exceptionAutotracking = TrackerDefaults.exceptionEvents
    /// Whether enable diagnostic reporting.
    @objc
    public var diagnosticAutotracking: Bool = TrackerDefaults.trackerDiagnostic
    /// Whether to anonymise client-side user identifiers in session (userId, previousSessionId), subject (userId, networkUserId, domainUserId, ipAddress) and platform context entities (IDFA)
    /// Setting this property on a running tracker instance starts a new session (if sessions are tracked).
    @objc
    public var userAnonymisation: Bool = TrackerDefaults.userAnonymisation
    /// Decorate the v_tracker field in the tracker protocol.
    /// @note Do not use. Internal use only.
    @objc
    public var trackerVersionSuffix: String?
    /// Closure called to retrieve the Identifier for Advertisers (IDFA) from AdSupport module
    /// It is called repeatedly (on each tracked event) until a UUID is returned.
    @objc
    public var advertisingIdentifierRetriever: (() -> UUID?)?

    @objc
    public override init() {
        super.init()
    }
    
    @objc
    public convenience init(appId: String) {
        self.init()
        self.appId = appId
    }

    @objc
    public convenience init?(dictionary: [String : NSObject]) {
        self.init()
        if let appId = dictionary["appId"] as? String {
            self.appId = appId
        }
        if let devicePlatform = dictionary["devicePlatform"] as? String {
            self.devicePlatform = stringToDevicePlatform(devicePlatform) ?? .mobile
        }
        // TODO: Uniform "base64encoding" string on both Android and iOS trackers
        if let base64Encoding = dictionary["base64encoding"] as? Bool {
            self.base64Encoding = base64Encoding
        }
        if let logLevelValue = dictionary["logLevel"] as? String,
           let index = ["off", "error", "debug", "verbose"].firstIndex(of: logLevelValue),
           let logLevel = LogLevel(rawValue: index) {
            self.logLevel = logLevel
        }
        if let sessionContext = dictionary["sessionContext"] as? Bool {
            self.sessionContext = sessionContext
        }
        if let applicationContext = dictionary["applicationContext"] as? Bool {
            self.applicationContext = applicationContext
        }
        if let platformContext = dictionary["platformContext"] as? Bool {
            self.platformContext = platformContext
        }
        if let geoLocationContext = dictionary["geoLocationContext"] as? Bool {
            self.geoLocationContext = geoLocationContext
        }
        if let deepLinkContext = dictionary["deepLinkContext"] as? Bool {
            self.deepLinkContext = deepLinkContext
        }
        if let screenContext = dictionary["screenContext"] as? Bool {
            self.screenContext = screenContext
        }
        if let screenViewAutotracking = dictionary["screenViewAutotracking"] as? Bool {
            self.screenViewAutotracking = screenViewAutotracking
        }
        if let lifecycleAutotracking = dictionary["lifecycleAutotracking"] as? Bool {
            self.lifecycleAutotracking = lifecycleAutotracking
        }
        if let installAutotracking = dictionary["installAutotracking"] as? Bool {
            self.installAutotracking = installAutotracking
        }
        if let exceptionAutotracking = dictionary["exceptionAutotracking"] as? Bool {
            self.exceptionAutotracking = exceptionAutotracking
        }
        if let diagnosticAutotracking = dictionary["diagnosticAutotracking"] as? Bool {
            self.diagnosticAutotracking = diagnosticAutotracking
        }
        if let userAnonymisation = dictionary["userAnonymisation"] as? Bool {
            self.userAnonymisation = userAnonymisation
        }
    }

    // MARK: - NSCopying

    @objc
    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TrackerConfiguration()
        copy.appId = appId
        copy.devicePlatform = devicePlatform
        copy.base64Encoding = base64Encoding
        copy.logLevel = logLevel
        copy.loggerDelegate = loggerDelegate
        copy.sessionContext = sessionContext
        copy.applicationContext = applicationContext
        copy.platformContext = platformContext
        copy.geoLocationContext = geoLocationContext
        copy.deepLinkContext = deepLinkContext
        copy.screenContext = screenContext
        copy.screenViewAutotracking = screenViewAutotracking
        copy.lifecycleAutotracking = lifecycleAutotracking
        copy.installAutotracking = installAutotracking
        copy.exceptionAutotracking = exceptionAutotracking
        copy.diagnosticAutotracking = diagnosticAutotracking
        copy.trackerVersionSuffix = trackerVersionSuffix
        copy.userAnonymisation = userAnonymisation
        copy.advertisingIdentifierRetriever = advertisingIdentifierRetriever
        return copy
    }

    // MARK: - NSSecureCoding
    
    @objc
    public override class var supportsSecureCoding: Bool { return true }

    @objc
    public override func encode(with coder: NSCoder) {
        coder.encode(appId, forKey: "appId")
        coder.encode(devicePlatform, forKey: "devicePlatform")
        coder.encode(base64Encoding, forKey: "base64Encoding")
        coder.encode(logLevel, forKey: "logLevel")
        coder.encode(loggerDelegate, forKey: "loggerDelegate")
        coder.encode(sessionContext, forKey: "sessionContext")
        coder.encode(applicationContext, forKey: "applicationContext")
        coder.encode(platformContext, forKey: "platformContext")
        coder.encode(geoLocationContext, forKey: "geoLocationContext")
        coder.encode(deepLinkContext, forKey: "deepLinkContext")
        coder.encode(screenContext, forKey: "screenContext")
        coder.encode(screenViewAutotracking, forKey: "screenViewAutotracking")
        coder.encode(lifecycleAutotracking, forKey: "lifecycleAutotracking")
        coder.encode(installAutotracking, forKey: "installAutotracking")
        coder.encode(exceptionAutotracking, forKey: "exceptionAutotracking")
        coder.encode(diagnosticAutotracking, forKey: "diagnosticAutotracking")
        coder.encode(trackerVersionSuffix, forKey: "trackerVersionSuffix")
        coder.encode(userAnonymisation, forKey: "userAnonymisation")
    }

    required init?(coder: NSCoder) {
        super.init()
        if let appId = coder.decodeObject(forKey: "appId") as? String {
            self.appId = appId
        }
        if let devicePlatform = DevicePlatform(rawValue: coder.decodeInteger(forKey: "devicePlatform")) {
            self.devicePlatform = devicePlatform
        }
        base64Encoding = coder.decodeBool(forKey: "base64Encoding")
        if let logLevel = LogLevel(rawValue: coder.decodeInteger(forKey: "logLevel")) {
            self.logLevel = logLevel
        }
        if let loggerDelegate = coder.decodeObject(forKey: "loggerDelegate") as? LoggerDelegate {
            self.loggerDelegate = loggerDelegate
        }
        sessionContext = coder.decodeBool(forKey: "sessionContext")
        applicationContext = coder.decodeBool(forKey: "applicationContext")
        platformContext = coder.decodeBool(forKey: "platformContext")
        geoLocationContext = coder.decodeBool(forKey: "geoLocationContext")
        deepLinkContext = coder.decodeBool(forKey: "deepLinkContext")
        screenContext = coder.decodeBool(forKey: "screenContext")
        screenViewAutotracking = coder.decodeBool(forKey: "screenViewAutotracking")
        lifecycleAutotracking = coder.decodeBool(forKey: "lifecycleAutotracking")
        installAutotracking = coder.decodeBool(forKey: "installAutotracking")
        exceptionAutotracking = coder.decodeBool(forKey: "exceptionAutotracking")
        diagnosticAutotracking = coder.decodeBool(forKey: "diagnosticAutotracking")
        if let trackerVersionSuffix = coder.decodeObject(forKey: "trackerVersionSuffix") as? String {
            self.trackerVersionSuffix = trackerVersionSuffix
        }
        userAnonymisation = coder.decodeBool(forKey: "userAnonymisation")
    }
}
