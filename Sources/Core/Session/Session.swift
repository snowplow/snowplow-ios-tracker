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
    
    private var _backgroundIndex = 0
    private var _backgroundTimeout = TrackerDefaults.backgroundTimeout
    private var dataPersistence: DataPersistence?
    /// The event index
    private var eventIndex = 0
    private var _foregroundIndex = 0
    private var _foregroundTimeout = TrackerDefaults.foregroundTimeout
    private var isNewSession = true
    private var isSessionCheckerEnabled = false
    private var _inBackground = false
    private var lastSessionCheck: NSNumber = Utilities.getTimestamp()
    private var _onSessionStateUpdate: ((_ sessionState: SessionState) -> Void)?
    /// Returns the current session state
    private var state: SessionState?
    /// The current tracker associated with the session
    private weak var tracker: Tracker?
  
    // MARK: - Properties
    
    /// The session's userId
    let userId: String
    /// Whether the application is in the background or foreground
    var inBackground: Bool { return sync { self._inBackground } }
    /// The foreground index count
    var foregroundIndex: Int { return sync { self._foregroundIndex } }
    /// The background index count
    var backgroundIndex: Int { return sync { self._backgroundIndex } }
    /// Callback to be called when the session is updated
    var onSessionStateUpdate: ((_ sessionState: SessionState) -> Void)? {
        get { return sync { self._onSessionStateUpdate } }
        set { sync { self._onSessionStateUpdate = newValue } }
    }
    /// The currently set Foreground Timeout in milliseconds
    var foregroundTimeout: Int {
        get { return sync { self._foregroundTimeout } }
        set { sync { self._foregroundTimeout = newValue } }
    }
    /// The currently set Background Timeout in milliseconds
    var backgroundTimeout: Int {
        get { return sync { self._backgroundTimeout } }
        set { sync { self._backgroundTimeout = newValue } }
    }
    var sessionIndex: Int? { return sync { state?.sessionIndex } }
    var sessionId: String? { return sync { state?.sessionId } }
    var previousSessionId: String? { return sync { state?.previousSessionId } }
    var firstEventId: String? { return sync { state?.firstEventId } }
    
    // MARK: - Constructor and destructor

    /// Initializes a newly allocated SnowplowSession
    /// - Parameters:
    ///   - foregroundTimeout: the session timeout while it is in the foreground
    ///   - backgroundTimeout: the session timeout while it is in the background
    ///   - tracker: reference to the associated tracker of the session
    /// - Returns: a SnowplowSession
    init(foregroundTimeout: Int, backgroundTimeout: Int, trackerNamespace: String? = nil, tracker: Tracker? = nil) {
        
        self._foregroundTimeout = foregroundTimeout * 1000
        self._backgroundTimeout = backgroundTimeout * 1000
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
        sync { isSessionCheckerEnabled = true }
    }

    /// Stops the recurring timer check for sessions
    func stopChecker() {
        sync { isSessionCheckerEnabled = false }
    }

    /// Expires the current session and starts a new one
    func startNewSession() {
        // TODO: when the sesssion has been renewed programmatically, it has to be reported in the session context to the collector.
        sync { isNewSession = true }
    }

    /// Returns the session dictionary
    /// - Parameters:
    ///   - firstEventId: The potential first event id of the session
    ///   - firstEventTimestamp: Device created timestamp of the first event of the session
    ///   - userAnonymisation: Whether to anonymise user identifiers
    /// - Returns: a SnowplowPayload containing the session dictionary
    func getDictWithEventId(_ eventId: String?, eventTimestamp: Int64, userAnonymisation: Bool) -> [String : Any]? {
        var context: [String : Any]? = nil
        
        sync {
            if isSessionCheckerEnabled {
                if shouldUpdate() {
                    update(eventId: eventId, eventTimestamp: eventTimestamp)
                    if let onSessionStateUpdate = _onSessionStateUpdate, let state = state {
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
        }

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
        let timeout = _inBackground ? _backgroundTimeout : _foregroundTimeout
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
        backgroundUpdateSync {
            if tracker?.lifecycleEvents ?? false {
                guard let backgroundIndex = self.incrementBackgroundIndexIfNotInBackground() else { return }
                _ = self.tracker?.track(Background(index: backgroundIndex), synchronous: true)
                sync { self._inBackground = true }
            }
        }
    }

    @objc func updateInForeground() {
        backgroundUpdateSync {
            if tracker?.lifecycleEvents ?? false {
                guard let foregroundIndex = self.incrementForegroundIndexIfInBackground() else { return }
                _ = self.tracker?.track(Foreground(index: foregroundIndex), synchronous: true)
                sync { self._inBackground = false }
            }
        }
    }
    
    private func incrementBackgroundIndexIfNotInBackground() -> Int? {
        return sync {
            if self._inBackground { return nil }
            self._backgroundIndex += 1
            return self._backgroundIndex
        }
    }
  
    private func incrementForegroundIndexIfInBackground() -> Int? {
        return sync {
            if !self._inBackground { return nil }
            self._foregroundIndex += 1
            return self._foregroundIndex
        }
    }
    
    // MARK: - Dispatch queues
    
    private let dispatchQueue = DispatchQueue(label: "snowplow.session")
    
    private func sync<T>(_ callback: () -> T) -> T {
        dispatchPrecondition(condition: .notOnQueue(dispatchQueue))

        return dispatchQueue.sync(execute: callback)
    }
    
    private let backgroundUpdateQueue = DispatchQueue(label: "snowplow.session.background")
    
    private func backgroundUpdateSync<T>(_ callback: () -> T) -> T {
        dispatchPrecondition(condition: .notOnQueue(backgroundUpdateQueue))

        return backgroundUpdateQueue.sync(execute: callback)
    }
}
