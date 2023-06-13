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

/// Configuration for session management.
@objc(SPSessionConfigurationProtocol)
public protocol SessionConfigurationProtocol: AnyObject {
    /// The amount of time that can elapse before the
    /// session id is updated while the app is in the
    /// foreground.
    @objc
    var foregroundTimeoutInSeconds: Int { get set }
    /// The amount of time that can elapse before the
    /// session id is updated while the app is in the
    /// background.
    @objc
    var backgroundTimeoutInSeconds: Int { get set }
    /// The amount of time that can elapse before the
    /// session id is updated while the app is in the
    /// foreground.
    @objc
    var foregroundTimeout: Measurement<UnitDuration> { get set }
    /// The amount of time that can elapse before the
    /// session id is updated while the app is in the
    /// background.
    @objc
    var backgroundTimeout: Measurement<UnitDuration> { get set }
    /// The callback called everytime the session is updated.
    @objc
    var onSessionStateUpdate: ((_ sessionState: SessionState) -> Void)? { get set }
}

/// This class represents the configuration from of the applications session.
/// The SessionConfiguration can be used to setup the behaviour of sessions.
///
/// A session is a context which is appended to each event sent.
/// The values it brings can change based on:
/// - the timeout set for the inactivity of app when in foreground;
/// - the timeout set for the inactivity of app when in background.
///
/// Session data is maintained for the life of the application being installed on a device.
/// A new session will be created if the session information is not accessed within a configurable timeout.
@objc(SPSessionConfiguration)
public class SessionConfiguration: SerializableConfiguration, SessionConfigurationProtocol, ConfigurationProtocol {
    internal var sourceConfig: SessionConfiguration?
    
    private var _isPaused: Bool?
    internal var isPaused: Bool {
        get { return _isPaused ?? sourceConfig?.isPaused ?? false }
        set { _isPaused = newValue }
    }
    
    private var _backgroundTimeoutInSeconds: Int?
    /// The timeout set for the inactivity of app when in background.
    @objc
    public var backgroundTimeoutInSeconds: Int {
        get { return _backgroundTimeoutInSeconds ?? sourceConfig?.backgroundTimeoutInSeconds ?? 1800 }
        set { _backgroundTimeoutInSeconds = newValue }
    }
    
    private var _foregroundTimeoutInSeconds: Int?
    /// The timeout set for the inactivity of app when in foreground.
    @objc
    public var foregroundTimeoutInSeconds: Int {
        get { return _foregroundTimeoutInSeconds ?? sourceConfig?.foregroundTimeoutInSeconds ?? 1800 }
        set { _foregroundTimeoutInSeconds = newValue }
    }
    
    private var _onSessionStateUpdate: ((_ sessionState: SessionState) -> Void)?
    /// The callback called everytime the session is updated.
    @objc
    public var onSessionStateUpdate: ((_ sessionState: SessionState) -> Void)? {
        get { return _onSessionStateUpdate ?? sourceConfig?.onSessionStateUpdate }
        set { _onSessionStateUpdate = newValue }
    }

    @objc
    public override init() {
    }

    @objc
    public convenience init?(dictionary: [String : Any]) {
        self.init()
        if let foregroundTimeout = dictionary["foregroundTimeout"] as? Int,
           let backgroundTimeout = dictionary["backgroundTimeout"] as? Int {
            self._foregroundTimeoutInSeconds = foregroundTimeout
            self._backgroundTimeoutInSeconds = backgroundTimeout
        }
    }

    /// This will setup the session behaviour of the tracker.
    /// - Parameters:
    ///   - foregroundTimeout: The timeout set for the inactivity of app when in foreground.
    ///   - backgroundTimeout: The timeout set for the inactivity of app when in background.
    @objc
    public convenience init(foregroundTimeout: Measurement<UnitDuration>, backgroundTimeout: Measurement<UnitDuration>) {
        let foreground = foregroundTimeout.converted(to: .seconds)
        let foregroundInSeconds = Int(floor(foreground.value))
        let background = backgroundTimeout.converted(to: .seconds)
        let backgroundInSeconds = Int(floor(background.value))
        self.init(foregroundTimeoutInSeconds: foregroundInSeconds, backgroundTimeoutInSeconds: Int(backgroundInSeconds))
    }

    /// This will setup the session behaviour of the tracker.
    /// - Parameters:
    ///   - foregroundTimeout: The timeout set for the inactivity of app when in foreground.
    ///   - backgroundTimeout: The timeout set for the inactivity of app when in background.
    @objc
    public init(foregroundTimeoutInSeconds foregroundTimeout: Int, backgroundTimeoutInSeconds backgroundTimeout: Int) {
        self._backgroundTimeoutInSeconds = backgroundTimeout
        self._foregroundTimeoutInSeconds = foregroundTimeout
    }

    /// The timeout set for the inactivity of app when in foreground.
    @objc
    public var foregroundTimeout: Measurement<UnitDuration> {
        get {
            return Measurement(value: Double(foregroundTimeoutInSeconds), unit: .seconds)
        }
        set(foregroundTimeout) {
            let foreground = foregroundTimeout.converted(to: .seconds)
            foregroundTimeoutInSeconds = Int(floor(foreground.value))
        }
    }

    /// The timeout set for the inactivity of app when in background.
    @objc
    public var backgroundTimeout: Measurement<UnitDuration> {
        get {
            return Measurement(value: Double(backgroundTimeoutInSeconds), unit: .seconds)
        }
        set(backgroundTimeout) {
            let background = backgroundTimeout.converted(to: .seconds)
            backgroundTimeoutInSeconds = Int(floor(background.value))
        }
    }

    // MARK: - Builders

    /// The callback called everytime the session is updated.
    public func onSessionStateUpdate(_ value: ((_ sessionState: SessionState) -> Void)?) -> Self {
        onSessionStateUpdate = value
        return self
    }

    // MARK: - NSCopying

    @objc
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = SessionConfiguration()
        copy.backgroundTimeoutInSeconds = backgroundTimeoutInSeconds
        copy.foregroundTimeoutInSeconds = foregroundTimeoutInSeconds
        copy.onSessionStateUpdate = onSessionStateUpdate
        return copy
    }

    // MARK: - NSSecureCoding
    
    @objc
    public override class var supportsSecureCoding: Bool { return true }
    
    @objc
    public override func encode(with coder: NSCoder) {
        coder.encode(backgroundTimeoutInSeconds, forKey: "backgroundTimeoutInSeconds")
        coder.encode(foregroundTimeoutInSeconds, forKey: "foregroundTimeoutInSeconds")
    }

    required init?(coder: NSCoder) {
        super.init()
        backgroundTimeoutInSeconds = coder.decodeInteger(forKey: "backgroundTimeoutInSeconds")
        foregroundTimeoutInSeconds = coder.decodeInteger(forKey: "foregroundTimeoutInSeconds")
    }
}
