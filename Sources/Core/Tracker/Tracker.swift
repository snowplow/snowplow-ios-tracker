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

func uncaughtExceptionHandler(_ exception: NSException) {
    let symbols = exception.callStackSymbols
    let stacktrace = "Stacktrace:\n\(symbols)"
    let message = exception.reason
    DispatchQueue.global(qos: .default).sync {
        guard let message = message else { return }
        if message.count == 0 { return }
    
        // Construct userInfo
        var userInfo: [String : Any] = [:]
        userInfo["message"] = message
        userInfo["stacktrace"] = stacktrace
    
        // Send notification to tracker
        NotificationCenter.default.post(
            name: NSNotification.Name("SPCrashReporting"),
            object: nil,
            userInfo: userInfo)
    
        Thread.sleep(forTimeInterval: 2.0)
    }
}

/// This class is used for tracking events, and delegates them to other classes responsible for sending, storage, etc.
class Tracker {
    
    // MARK: - Private properties
    
    private var dataCollection = true
    private var builderFinished = false
    private let trackerData: TrackerData
    
    /// The object used for sessionization, i.e. it characterizes user activity.
    private(set) var session: Session? {
        get { return sync { self.trackerData.session } }
        set { sync { self.trackerData.session = newValue } }
    }
    /// Previous screen view state.
    private(set) var previousScreenState: ScreenState? {
        get { return sync { self.trackerData.previousScreenState } }
        set { sync { self.trackerData.previousScreenState = newValue } }
    }
    /// Current screen view state.
    private(set) var currentScreenState: ScreenState? {
        get { return sync { self.trackerData.currentScreenState } }
        set { sync { self.trackerData.currentScreenState = newValue } }
    }
    
    private let stateManager = StateManager()
    private let _emitter: Emitter
    
    // MARK: - Properties
    
    /// The emitter used to send events.
    var emitter: Emitter {
        return sync { self._emitter }
    }
    
    /// The subject used to represent the current user and persist user information.
    var subject: Subject? {
        get { return sync { self.trackerData.subject } }
        set { sync { self.trackerData.subject = newValue } }
    }
    
    /// Whether to use Base64 encoding for events.
    var base64Encoded: Bool {
        get { return sync { self.trackerData.base64Encoded } }
        set { sync { self.trackerData.base64Encoded = newValue } }
    }
    
    /// A unique identifier for an application.
    var appId: String {
        get { return sync { self.trackerData.appId } }
        set { sync { self.trackerData.appId = newValue } }
    }
    
    /// The identifier for the current tracker.
    var trackerNamespace: String {
        get { return sync { self.trackerData.trackerNamespace } }
    }
    
    /// Version suffix for tracker wrappers.
    var trackerVersionSuffix: String {
        get { return sync { self.trackerData.trackerVersionSuffix } }
        set { sync { self.trackerData.trackerVersionSuffix = newValue } }
    }
    
    var devicePlatform: DevicePlatform {
        get { return sync { self.trackerData.devicePlatform } }
        set { sync { self.trackerData.devicePlatform = newValue } }
    }
    
    var logLevel: LogLevel {
        get { return sync { self.trackerData.logLevel } }
        set { sync { self.trackerData.logLevel = newValue } }
    }
    
    var loggerDelegate: LoggerDelegate? {
        get { return sync { self.trackerData.loggerDelegate } }
        set { sync { self.trackerData.loggerDelegate = newValue } }
    }
    
    var sessionContext: Bool {
        get { return sync { self.trackerData.sessionContext } }
        set(sessionContext) {
            sync {
                self.trackerData.sessionContext = sessionContext
                if self.trackerData.session != nil && !self.trackerData.sessionContext {
                    self.trackerData.session?.stopChecker()
                    self.trackerData.session = nil
                } else if self.builderFinished && self.trackerData.session == nil && sessionContext {
                    self.trackerData.session = Session(
                        foregroundTimeout: self.trackerData.foregroundTimeout,
                        backgroundTimeout: self.trackerData.backgroundTimeout,
                        trackerNamespace: self.trackerData.trackerNamespace,
                        tracker: self
                    )
                }
            }
        }
    }
    
    var deepLinkContext: Bool {
        get { sync { return self.trackerData.deepLinkContext } }
        set(deepLinkContext) {
            sync {
                self.trackerData.deepLinkContext = deepLinkContext
                if deepLinkContext {
                    self.stateManager.addOrReplaceStateMachine(DeepLinkStateMachine())
                } else {
                    _ = self.stateManager.removeStateMachine(DeepLinkStateMachine.identifier)
                }
            }
        }
    }
    
    var screenContext: Bool {
        get { return sync { self.trackerData.screenContext } }
        set(screenContext) {
            sync {
                self.trackerData.screenContext = screenContext
                if screenContext {
                    self.stateManager.addOrReplaceStateMachine(ScreenStateMachine())
                } else {
                    _ = self.stateManager.removeStateMachine(ScreenStateMachine.identifier)
                }
            }
        }
    }
    
    var applicationContext: Bool {
        get { return sync { self.trackerData.applicationContext } }
        set { sync { self.trackerData.applicationContext = newValue } }
    }
    
    var autotrackScreenViews: Bool {
        get { return sync { self.trackerData.autotrackScreenViews } }
        set { sync { self.trackerData.autotrackScreenViews = newValue } }
    }
    
    var foregroundTimeout: Int {
        get { return sync { self.trackerData.foregroundTimeout } }
        set(foregroundTimeout) {
            sync {
                self.trackerData.foregroundTimeout = foregroundTimeout
                if self.builderFinished {
                    self.trackerData.session?.foregroundTimeout = foregroundTimeout
                }
            }
        }
    }
    
    var backgroundTimeout: Int {
        get { return sync { self.trackerData.backgroundTimeout } }
        set(backgroundTimeout) {
            sync {
                self.trackerData.backgroundTimeout = backgroundTimeout
                if self.builderFinished {
                    self.trackerData.session?.backgroundTimeout = backgroundTimeout
                }
            }
        }
    }
    
    /// Returns whether lifecyle events is enabled.
    /// - Returns: Whether background and foreground events are sent.
    var lifecycleEvents: Bool {
        get { return sync { self.trackerData.lifecycleEvents } }
        set(lifecycleEvents) {
            sync {
                self.trackerData.lifecycleEvents = lifecycleEvents
                if lifecycleEvents {
                    self.stateManager.addOrReplaceStateMachine(LifecycleStateMachine())
                } else {
                    _ = self.stateManager.removeStateMachine(LifecycleStateMachine.identifier)
                }
            }
        }
    }
    
    var exceptionEvents: Bool {
        get { return sync { self.trackerData.exceptionEvents } }
        set { sync { self.trackerData.exceptionEvents = newValue } }
    }
    var installEvent: Bool {
        get { return sync { self.trackerData.installEvent } }
        set { sync { self.trackerData.installEvent = newValue } }
    }
    var trackerDiagnostic: Bool {
        get { return sync { self.trackerData.trackerDiagnostic } }
        set { sync { self.trackerData.trackerDiagnostic = newValue } }
    }
    
    var userAnonymisation: Bool {
        get { return sync { self.trackerData.userAnonymisation } }
        set(userAnonymisation) {
            sync {
                if self.trackerData.userAnonymisation != userAnonymisation {
                    self.trackerData.userAnonymisation = userAnonymisation
                    if self.builderFinished {
                        self.trackerData.session?.startNewSession()
                    }
                }
            }
        }
    }
    
    /// GDPR context
    /// You can enable or disable the context by setting this property
    var gdprContext: GDPRContext? {
        get { return sync { self.trackerData.gdprContext } }
        set { sync { self.trackerData.gdprContext = newValue } }
    }
    
    var inBackground: Bool {
        return sync { self.trackerData.session?.inBackground ?? false }
    }
    
    var isTracking: Bool {
        return sync { self.dataCollection }
    }
    
    var advertisingIdentifierRetriever: (() -> UUID?)? {
        get { return sync { self.trackerData.advertisingIdentifierRetriever } }
        set { sync { self.trackerData.advertisingIdentifierRetriever = newValue } }
    }
    
    // MARK: - Constructor and destructor and related functions
    
    init(trackerNamespace: String,
         appId: String?,
         emitter: Emitter,
         builder: ((Tracker) -> (Void))) {
        self.trackerData = TrackerData(appId: appId ?? "", trackerNamespace: trackerNamespace)
        self._emitter = emitter
        
        builder(self)
        
        setup()
        checkInstall()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setup() {
        if sessionContext {
            self.trackerData.session = Session(
                foregroundTimeout: self.trackerData.foregroundTimeout,
                backgroundTimeout: self.trackerData.backgroundTimeout,
                trackerNamespace: self.trackerData.trackerNamespace,
                tracker: self)
        }
        
        UIKitScreenViewTracking.setup()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveScreenViewNotification(_:)),
            name: NSNotification.Name("SPScreenViewDidAppear"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveDiagnosticNotification(_:)),
            name: NSNotification.Name("SPTrackerDiagnostic"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveCrashReporting(_:)),
            name: NSNotification.Name("SPCrashReporting"),
            object: nil)
        
        if exceptionEvents {
            NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)
        }
        
        builderFinished = true
    }
    
    private func checkInstall() {
        if installEvent {
            DispatchQueue.global(qos: .default).async { [weak self] in
                let installTracker = InstallTracker()
                let previousTimestamp = installTracker.previousInstallTimestamp
                installTracker.clearPreviousInstallTimestamp()
                if !installTracker.isNewInstall && previousTimestamp == nil {
                    return
                }
                let data: [String: Any] = [:]
                let installEvent = SelfDescribingJson(schema: kSPApplicationInstallSchema, andDictionary: data)
                let event = SelfDescribing(eventData: installEvent)
                event.trueTimestamp = previousTimestamp // it can be nil
                let _ = self?.track(event)
            }
        }
    }
    
    // MARK: - Functions
    
    /// Add or replace state machine in the state manager
    func addOrReplace(stateMachine: StateMachineProtocol) {
        sync {
            self.stateManager.addOrReplaceStateMachine(stateMachine)
        }
    }
    
    /// Remove stata machine from the state manager
    func remove(stateMachineIdentifier: String) {
        sync {
            _ = self.stateManager.removeStateMachine(stateMachineIdentifier)
        }
    }
    
    /// Pauses all event tracking, storage and session checking.
    func pauseEventTracking() {
        sync {
            self.dataCollection = false
            self._emitter.pauseTimer()
            self.trackerData.session?.stopChecker()
        }
    }
    
    func resumeEventTracking() {
        sync {
            self.dataCollection = true
            self._emitter.resumeTimer()
            self.trackerData.session?.startChecker()
        }
    }
    
    // MARK: - Notifications management
    
    @objc func receiveScreenViewNotification(_ notification: Notification) {
        asyncNotification {
            guard let name = notification.userInfo?["name"] as? String else { return }
            
            var type: String?
            if let typeId = (notification.userInfo?["type"] as? NSNumber)?.intValue,
               let screenType = ScreenType(rawValue: typeId) {
                type = ScreenView.stringWithScreenType(screenType)
            }
            
            let topViewControllerClassName = notification.userInfo?["topViewControllerClassName"] as? String
            let viewControllerClassName = notification.userInfo?["viewControllerClassName"] as? String
            
            if self.autotrackScreenViews {
                let event = ScreenView(name: name, screenId: nil)
                event.type = type
                event.viewControllerClassName = viewControllerClassName
                event.topViewControllerClassName = topViewControllerClassName
                let _ = self.track(event)
            }
        }
    }
    
    @objc func receiveDiagnosticNotification(_ notification: Notification) {
        asyncNotification {
            let userInfo = notification.userInfo
            guard let tag = userInfo?["tag"] as? String,
                  let message = userInfo?["message"] as? String else { return }
            let error = userInfo?["error"] as? Error
            let exception = userInfo?["exception"] as? NSException
            
            if self.trackerDiagnostic {
                let event = TrackerError(source: tag, message: message, error: error, exception: exception)
                let _ = self.track(event)
            }
        }
    }
    
    @objc func receiveCrashReporting(_ notification: Notification) {
        asyncNotification {
            let userInfo = notification.userInfo
            guard let message = userInfo?["message"] as? String else { return }
            let stacktrace = userInfo?["stacktrace"] as? String
            
            if self.exceptionEvents {
                let event = SNOWError(message: message)
                event.stackTrace = stacktrace
                let _ = self.track(event)
            }
        }
    }
    
    // MARK: - Event Tracking Functions
    
    /// Tracks an event despite its specific type.
    /// - Parameter event: The event to track
    /// - Parameter synchronous: Whether to track the event synchronously or asynchronously
    /// - Returns: The event ID
    func track(_ event: Event, synchronous: Bool = false) -> UUID {
        let eventId = UUID()
        
        let track = {
            if !self.dataCollection { return }
            
            event.beginProcessing(withTracker: self)
            self.processEvent(event, eventId)
            event.endProcessing(withTracker: self)
        }
        
        if synchronous {
            self.sync(track)
        } else {
            self.async(track)
        }
        
        return eventId
    }
    
    // MARK: - Event Decoration

    private func processEvent(_ event: Event, _ eventId: UUID) {
        let stateSnapshot = stateManager.trackerState(forProcessedEvent: event)
        let trackerEvent = TrackerEvent(event: event, eventId: eventId, state: stateSnapshot)
        let payloadBuilder = TrackerPayloadBuilder()
        if let payload = payloadBuilder.payload(event: trackerEvent, tracker: self.trackerData, stateManager: self.stateManager) {
            _emitter.addPayload(toBuffer: payload)
            stateManager.afterTrack(event: trackerEvent)
        } else {
            logDebug(message: "Event not tracked due to filtering")
        }
    }
    
    // MARK: - Serial dispatch queue
    
    private let serialQueue = DispatchQueue(label: "snowplow.tracker")
    
    private func sync<T>(_ callback: () -> T) -> T {
        dispatchPrecondition(condition: .notOnQueue(serialQueue))

        return serialQueue.sync(execute: callback)
    }
    
    private func async(_ callback: @escaping () -> Void) {
        serialQueue.async(execute: callback)
    }
    
    // MARK: - Notification dispatch queue
    
    private let notificationQueue = DispatchQueue(label: "snowplow.tracker.notifications", attributes: .concurrent)
    
    private func asyncNotification(_ callback: @escaping () -> Void) {
        notificationQueue.async(execute: callback)
    }
}
