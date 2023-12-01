//  Copyright (c) 2023 Snowplow Analytics Ltd. All rights reserved.
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
#if os(iOS) || os(tvOS)
import UIKit
#endif

class Session {
    
    // MARK: - Private properties
    
    private var dataPersistence: DataPersistence?
    /// The event index
    private var eventIndex = 0
    private var isNewSession = true
    private var isSessionCheckerEnabled = false
    private var lastSessionCheck: NSNumber = Utilities.getTimestamp()
    /// Returns the current session state
    private var state: SessionState?
    /// The current tracker associated with the session
    private weak var tracker: Tracker?
  
    // MARK: - Properties
    
    /// The session's userId
    let userId: String
    /// Whether the application is in the background or foreground
    var inBackground: Bool = false
    /// The foreground index count
    var foregroundIndex = 0
    /// The background index count
    var backgroundIndex = 0
    /// Callback to be called when the session is updated
    var onSessionStateUpdate: ((_ sessionState: SessionState) -> Void)?
    /// The currently set Foreground Timeout in milliseconds
    var foregroundTimeout = TrackerDefaults.foregroundTimeout
    /// The currently set Background Timeout in milliseconds
    var backgroundTimeout = TrackerDefaults.backgroundTimeout
    var sessionIndex: Int? { return state?.sessionIndex }
    var sessionId: String? { return state?.sessionId }
    var previousSessionId: String? { return state?.previousSessionId }
    var firstEventId: String? { return state?.firstEventId }
    
    // MARK: - Constructor and destructor

    /// Initializes a newly allocated SnowplowSession
    /// - Parameters:
    ///   - foregroundTimeout: the session timeout while it is in the foreground
    ///   - backgroundTimeout: the session timeout while it is in the background
    ///   - tracker: reference to the associated tracker of the session
    /// - Returns: a SnowplowSession
    init(foregroundTimeout: Int, backgroundTimeout: Int, trackerNamespace: String? = nil, tracker: Tracker? = nil) {
        
        self.foregroundTimeout = foregroundTimeout * 1000
        self.backgroundTimeout = backgroundTimeout * 1000
        self.tracker = tracker
        if let namespace = trackerNamespace {
            dataPersistence = DataPersistence.getFor(namespace: namespace)
        }
        let storedSessionDict = dataPersistence?.session
        userId = Session.retrieveUserId(sessionDict: storedSessionDict)
        if var storedSessionDict = storedSessionDict {
            storedSessionDict[kSPSessionUserId] = userId
            state = SessionState(storedState: storedSessionDict)
            dataPersistence?.session = storedSessionDict
        }
        if state == nil {
            logDiagnostic(message: "No previous session info available")
        }
        
        // Start session check
        startChecker()
        
        // Trigger notification for view changes
#if os(iOS) || os(tvOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateInBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateInForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
#endif
    }

    deinit {
#if os(iOS) || os(tvOS)
        NotificationCenter.default.removeObserver(self)
#endif
    }

    // MARK: - Public

    /// Starts the recurring timer check for sessions
    func startChecker() {
        isSessionCheckerEnabled = true
    }

    /// Stops the recurring timer check for sessions
    func stopChecker() {
        isSessionCheckerEnabled = false
    }

    /// Expires the current session and starts a new one
    func startNewSession() {
        // TODO: when the sesssion has been renewed programmatically, it has to be reported in the session context to the collector.
        isNewSession = true
    }

    /// Returns the session dictionary
    /// - Parameters:
    ///   - firstEventId: The potential first event id of the session
    ///   - firstEventTimestamp: Device created timestamp of the first event of the session
    ///   - userAnonymisation: Whether to anonymise user identifiers
    /// - Returns: a SnowplowPayload containing the session dictionary
    func getDictWithEventId(_ eventId: String?, eventTimestamp: Int64, userAnonymisation: Bool) -> [String : Any]? {
        var context: [String : Any]? = nil
        
        if isSessionCheckerEnabled {
            if shouldUpdate() {
                update(eventId: eventId, eventTimestamp: eventTimestamp)
                if let onSessionStateUpdate = onSessionStateUpdate, let state = state {
                    DispatchQueue.global(qos: .default).async {
                        onSessionStateUpdate(state)
                    }
                }
            }
            lastSessionCheck = Utilities.getTimestamp()
        }
        
        eventIndex += 1
        
        context = state?.sessionContext
        context?[kSPSessionEventIndex] = NSNumber(value: eventIndex)

        if userAnonymisation {
            // mask the user identifier
            var copy = context
            copy?[kSPSessionUserId] = kSPSessionAnonymousUserId
            copy?[kSPSessionPreviousId] = NSNull()
            return copy
        } else {
            return context
        }
    }


    // MARK: - Private

    private static func retrieveUserId(sessionDict: [String : Any]?) -> String {
        var userId = sessionDict?[kSPSessionUserId] as? String ?? Utilities.getUUIDString()
        // Session_UserID is available only if the session context is enabled.
        // In a future version we would like to make it available even if the session context is disabled.
        // For this reason, we store the Session_UserID in a separate storage (decoupled by session values)
        // calling it Installation_UserID in order to remark that it isn't related to the session context.
        // Although, for legacy, we need to copy its value in the Session_UserID of the session context
        // as the session context schema (and related data modelling) requires it.
        // For further details: https://discourse.snowplow.io/t/rfc-mobile-trackers-v2-0
        let userDefaults = UserDefaults.standard
        let storedUserId = userDefaults.string(forKey: kSPInstallationUserId)
        if let storedUserId = storedUserId {
            userId = storedUserId
        } else {
            userDefaults.set(userId, forKey: kSPInstallationUserId)
        }
        return userId
    }

    private func shouldUpdate() -> Bool {
        if isNewSession {
            return true
        }
        let lastAccess = lastSessionCheck.int64Value
        let now = Utilities.getTimestamp().int64Value
        let timeout = inBackground ? backgroundTimeout : foregroundTimeout
        return now < lastAccess || Int(now - lastAccess) > timeout
    }

    private func update(eventId: String?, eventTimestamp: Int64) {
        isNewSession = false
        let sessionIndex = (state?.sessionIndex ?? 0) + 1
        let eventISOTimestamp = Utilities.timestamp(toISOString: eventTimestamp)
        state = SessionState(
            firstEventId: eventId,
            firstEventTimestamp: eventISOTimestamp,
            currentSessionId: Utilities.getUUIDString(),
            previousSessionId: state?.sessionId,
            sessionIndex: sessionIndex,
            userId: userId,
            storage: "LOCAL_STORAGE")
        var sessionToPersist = state?.sessionContext
        // Remove previousSessionId if nil because dictionaries with nil values aren't plist serializable
        // and can't be stored with SPDataPersistence.
        if state?.previousSessionId == nil {
            var sessionCopy = sessionToPersist
            sessionCopy?.removeValue(forKey: kSPSessionPreviousId)
            sessionToPersist = sessionCopy
        }
        dataPersistence?.session = sessionToPersist
        eventIndex = 0
    }
    
    // MARK: - background and foreground notifications

    @objc func updateInBackground() {
        InternalQueue.async {
            if self.tracker?.lifecycleEvents ?? false {
                guard let backgroundIndex = self.incrementBackgroundIndexIfNotInBackground() else { return }
                _ = self.tracker?.track(Background(index: backgroundIndex))
                self.inBackground = true
            }
        }
    }

    @objc func updateInForeground() {
        InternalQueue.async {
            if self.tracker?.lifecycleEvents ?? false {
                guard let foregroundIndex = self.incrementForegroundIndexIfInBackground() else { return }
                _ = self.tracker?.track(Foreground(index: foregroundIndex))
                self.inBackground = false
            }
        }
    }
    
    private func incrementBackgroundIndexIfNotInBackground() -> Int? {
        if self.inBackground { return nil }
        self.backgroundIndex += 1
        return self.backgroundIndex
    }
  
    private func incrementForegroundIndexIfInBackground() -> Int? {
        if !self.inBackground { return nil }
        self.foregroundIndex += 1
        return self.foregroundIndex
    }
}
