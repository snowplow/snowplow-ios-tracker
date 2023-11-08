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
class Tracker: NSObject {
    private var platformContextSchema: String = ""
    private var dataCollection = true
    private var builderFinished = false

    /// The object used for sessionization, i.e. it characterizes user activity.
    private(set) var session: Session?
    /// Previous screen view state.
    private(set) var previousScreenState: ScreenState?
    /// Current screen view state.
    private(set) var currentScreenState: ScreenState?
    
    private func trackerPayloadData() -> [String : String] {
        var trackerVersion = kSPVersion
        if trackerVersionSuffix.count != 0 {
            var allowedCharSet = CharacterSet.alphanumerics
            allowedCharSet.formUnion(CharacterSet(charactersIn: ".-"))
            let suffix = trackerVersionSuffix.components(separatedBy: allowedCharSet.inverted).joined(separator: "")
            if suffix.count != 0 {
                trackerVersion = "\(trackerVersion) \(suffix)"
            }
        }
        return [
            kSPTrackerVersion: trackerVersion,
            kSPNamespace: trackerNamespace,
            kSPAppId: appId
        ]
    }

    // MARK: - Setter

    /// The emitter used to send events.
    let emitter: Emitter

    /// The subject used to represent the current user and persist user information.
    var subject: Subject?
    
    /// Whether to use Base64 encoding for events.
    var base64Encoded = TrackerDefaults.base64Encoded
    
    /// A unique identifier for an application.
    var appId: String
    
    /// The identifier for the current tracker.
    let trackerNamespace: String
    
    /// Version suffix for tracker wrappers.
    var trackerVersionSuffix: String = TrackerDefaults.trackerVersionSuffix
    
    var devicePlatform: DevicePlatform = TrackerDefaults.devicePlatform

    var logLevel: LogLevel {
        get {
            return Logger.logLevel
        }
        set {
            Logger.logLevel = newValue
        }
    }

    var loggerDelegate: LoggerDelegate? {
        get {
            return Logger.delegate
        }
        set(delegate) {
            Logger.delegate = delegate
        }
    }
    
    private var _sessionContext = false
    var sessionContext: Bool {
        get {
            return _sessionContext
        }
        set(sessionContext) {
            _sessionContext = sessionContext
            if session != nil && !sessionContext {
                session?.stopChecker()
                session = nil
            } else if builderFinished && session == nil && sessionContext {
                session = Session(
                    foregroundTimeout: foregroundTimeout,
                    backgroundTimeout: backgroundTimeout,
                    trackerNamespace: trackerNamespace,
                    tracker: self)
            }
        }
    }
    
    private var _deepLinkContext = false
    var deepLinkContext: Bool {
        get {
            return _deepLinkContext
        }
        set(deepLinkContext) {
            self._deepLinkContext = deepLinkContext
            if deepLinkContext {
                self.addOrReplace(stateMachine: DeepLinkStateMachine())
            } else {
                _ = self.stateManager.removeStateMachine(DeepLinkStateMachine.identifier)
            }
        }
    }
    
    private var _screenContext = false
    var screenContext: Bool {
        get {
            return _screenContext
        }
        set(screenContext) {
            self._screenContext = screenContext
            if screenContext {
                self.addOrReplace(stateMachine: ScreenStateMachine())
            } else {
                _ = self.stateManager.removeStateMachine(ScreenStateMachine.identifier)
            }
        }
    }
    
    var applicationContext = TrackerDefaults.applicationContext
    
    var autotrackScreenViews = TrackerDefaults.autotrackScreenViews
    
    private var _foregroundTimeout = TrackerDefaults.foregroundTimeout
    var foregroundTimeout: Int {
        get {
            return _foregroundTimeout
        }
        set(foregroundTimeout) {
            _foregroundTimeout = foregroundTimeout
            if builderFinished && session != nil {
                session?.foregroundTimeout = foregroundTimeout
            }
        }
    }
    
    private var _backgroundTimeout = TrackerDefaults.backgroundTimeout
    var backgroundTimeout: Int {
        get {
            return _backgroundTimeout
        }
        set(backgroundTimeout) {
            _backgroundTimeout = backgroundTimeout
            if builderFinished && session != nil {
                session?.backgroundTimeout = backgroundTimeout
            }
        }
    }
    
    private var _lifecycleEvents = false
    /// Returns whether lifecyle events is enabled.
    /// - Returns: Whether background and foreground events are sent.
    var lifecycleEvents: Bool {
        get {
            return _lifecycleEvents
        }
        set(lifecycleEvents) {
            self._lifecycleEvents = lifecycleEvents
            if lifecycleEvents {
                self.addOrReplace(stateMachine: LifecycleStateMachine())
            } else {
                _ = self.stateManager.removeStateMachine(LifecycleStateMachine.identifier)
            }
        }
    }
    
    var exceptionEvents = TrackerDefaults.exceptionEvents
    var installEvent = TrackerDefaults.installEvent
    var trackerDiagnostic = TrackerDefaults.trackerDiagnostic
    
    private var _userAnonymisation = TrackerDefaults.userAnonymisation
    var userAnonymisation: Bool {
        get {
            return _userAnonymisation
        }
        set(userAnonymisation) {
            if _userAnonymisation != userAnonymisation {
                _userAnonymisation = userAnonymisation
                if let session = session { session.startNewSession() }
            }
        }
    }

    /// GDPR context
    /// You can enable or disable the context by setting this property
    var gdprContext: GDPRContext?
    
    private var stateManager = StateManager()

    var inBackground: Bool {
        return session?.inBackground ?? false
    }

    var isTracking: Bool {
        return dataCollection
    }
    
    var advertisingIdentifierRetriever: (() -> UUID?)?

    init(trackerNamespace: String,
         appId: String?,
         emitter: Emitter,
         builder: ((Tracker) -> (Void))) {
        self.emitter = emitter
        self.appId = appId ?? ""
        self.trackerNamespace = trackerNamespace
        
        super.init()
        builder(self)
        
        #if os(iOS)
        platformContextSchema = kSPMobileContextSchema
        #else
        platformContextSchema = kSPDesktopContextSchema
        #endif
        
        setup()
        checkInstall()
    }

    private func setup() {
        if sessionContext {
            session = Session(
                foregroundTimeout: foregroundTimeout,
                backgroundTimeout: backgroundTimeout,
                trackerNamespace: trackerNamespace,
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
    
    /// Add or replace state machine in the state manager
    func addOrReplace(stateMachine: StateMachineProtocol) {
        stateManager.addOrReplaceStateMachine(stateMachine)
    }
    
    /// Remove stata machine from the state manager
    func remove(stateMachineIdentifier: String) {
        _ = stateManager.removeStateMachine(stateMachineIdentifier)
    }

    // MARK: - Extra Functions

    /// Pauses all event tracking, storage and session checking.
    func pauseEventTracking() {
        dataCollection = false
        emitter.pauseTimer()
        session?.stopChecker()
    }

    func resumeEventTracking() {
        dataCollection = true
        emitter.resumeTimer()
        session?.startChecker()
    }

    // MARK: - Notifications management
    
    @objc func receiveScreenViewNotification(_ notification: Notification) {
        guard let name = notification.userInfo?["name"] as? String else { return }
        
        var type: String?
        if let typeId = (notification.userInfo?["type"] as? NSNumber)?.intValue,
           let screenType = ScreenType(rawValue: typeId) {
            type = ScreenView.stringWithScreenType(screenType)
        }
        
        let topViewControllerClassName = notification.userInfo?["topViewControllerClassName"] as? String
        let viewControllerClassName = notification.userInfo?["viewControllerClassName"] as? String
            
        InternalQueue.async {
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
        let userInfo = notification.userInfo
        guard let tag = userInfo?["tag"] as? String,
              let message = userInfo?["message"] as? String else { return }
        let error = userInfo?["error"] as? Error
        let exception = userInfo?["exception"] as? NSException

        InternalQueue.async {
            if self.trackerDiagnostic {
                let event = TrackerError(source: tag, message: message, error: error, exception: exception)
                let _ = self.track(event)
            }
        }
    }

    @objc func receiveCrashReporting(_ notification: Notification) {
        let userInfo = notification.userInfo
        guard let message = userInfo?["message"] as? String else { return }
        let stacktrace = userInfo?["stacktrace"] as? String

        InternalQueue.async {
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
    /// - Returns: The event ID or nil in case tracking is paused
    func track(_ event: Event, eventId: UUID = UUID()) -> UUID {
        InternalQueue.onQueuePrecondition()
        
        if dataCollection {
            event.beginProcessing(withTracker: self)
            self.processEvent(event, eventId)
            event.endProcessing(withTracker: self)
        }
        return eventId
    }

    // MARK: - Event Decoration

    func processEvent(_ event: Event, _ eventId: UUID) {
        let stateSnapshot = stateManager.trackerState(forProcessedEvent: event)
        let trackerEvent = TrackerEvent(event: event, eventId: eventId, state: stateSnapshot)
        if let payload = self.payload(with: trackerEvent) {
            emitter.addPayload(toBuffer: payload)
            stateManager.afterTrack(event: trackerEvent)
        } else {
            logDebug(message: "Event not tracked due to filtering")
        }
    }

    func payload(with event: TrackerEvent) -> Payload? {
        let payload = Payload()
        payload.allowDiagnostic = !event.isService

        // Payload properties
        setApplicationInstallEventTimestamp(event)
        addBasicProperties(to: payload, event: event)
        addStateMachinePayloadValues(event: event)
        
        // Context entities
        addBasicContexts(event: event)
        addStateMachineEntities(event: event)
        
        event.wrapProperties(to: payload, base64Encoded: base64Encoded)
        event.wrapContexts(to: payload, base64Encoded: base64Encoded)
        
        // Decide whether to track the event or not
        if !stateManager.filter(event: event) {
            return nil
        }

        // Workaround for campaign attribution
        if !event.isPrimitive {
            // TODO: To remove when Atomic table refactoring is finished
            workaround(forCampaignAttributionEnrichment: payload, event: event)
        }
        return payload
    }
    
    private func setApplicationInstallEventTimestamp(_ event: TrackerEvent) {
        // Application_install event needs the timestamp to the real installation event.
        if (event.schema == kSPApplicationInstallSchema) {
            if let trueTimestamp = event.trueTimestamp {
                event.timestamp = Int64(trueTimestamp.timeIntervalSince1970 * 1000)
                event.trueTimestamp = nil
            }
        }
    }

    func addBasicProperties(to payload: Payload, event: TrackerEvent) {
        // Event ID
        payload.addValueToPayload(event.eventId.uuidString, forKey: kSPEid)
        // Timestamps
        payload.addValueToPayload(String(format: "%lld", event.timestamp), forKey: kSPTimestamp)
        if let trueTimestamp = event.trueTimestamp {
            let ttInMilliSeconds = Int64(trueTimestamp.timeIntervalSince1970 * 1000)
            payload.addValueToPayload(String(format: "%lld", ttInMilliSeconds), forKey: kSPTrueTimestamp)
        }
        // Tracker info (version, namespace, app ID)
        payload.addDictionaryToPayload(trackerPayloadData())
        // Subject
        if let subjectDict = subject?.standardDict(userAnonymisation: userAnonymisation) {
            payload.addDictionaryToPayload(subjectDict)
        }
        // Platform
        payload.addValueToPayload(devicePlatformToString(devicePlatform), forKey: kSPPlatform)
        // Event name
        if event.isPrimitive {
            payload.addValueToPayload(event.eventName, forKey: kSPEvent)
        } else {
            payload.addValueToPayload(kSPEventUnstructured, forKey: kSPEvent)
        }
    }

    /*
     This is needed because the campaign-attribution-enrichment (in the pipeline) is able to parse
     the `url` and `referrer` only if they are part of a PageView event.
     The PageView event is an atomic event but the DeepLinkReceived and ScreenView are SelfDescribing events.
     For this reason we copy these two fields in the atomic fields in order to let the enrichment
     to process correctly the fields even if the event is not a PageView and it's a SelfDescribing event.
     This is a hack that should be removed once the atomic event table is dismissed and all the events
     will be SelfDescribing.
     */
    func workaround(forCampaignAttributionEnrichment payload: Payload, event: TrackerEvent) {
        var url: String?
        var referrer: String?

        if event.schema == DeepLinkReceived.schema {
            url = event.payload[DeepLinkReceived.paramUrl] as? String
            referrer = event.payload[DeepLinkReceived.paramReferrer] as? String
        } else if event.schema == kSPScreenViewSchema {
            for entity in event.entities {
                if entity.schema == DeepLinkEntity.schema {
                    let data = entity.data
                    url = data[DeepLinkEntity.paramUrl] as? String
                    referrer = data[DeepLinkEntity.paramReferrer] as? String
                    break
                }
            }
        }

        if let url = url {
            payload.addValueToPayload(Utilities.truncateUrlScheme(url), forKey: kSPPageUrl)
        }
        if let referrer = referrer {
            payload.addValueToPayload(Utilities.truncateUrlScheme(referrer), forKey: kSPPageRefr)
        }
    }

    func addBasicContexts(event: TrackerEvent) {
        if subject != nil {
            if let platformDict = subject?.platformDict(
                userAnonymisation: userAnonymisation,
                advertisingIdentifierRetriever: advertisingIdentifierRetriever)?.dictionary {
                event.addContextEntity(SelfDescribingJson(schema: platformContextSchema, andDictionary: platformDict))
            }
            if let geoLocationDict = subject?.geoLocationDict {
                event.addContextEntity(SelfDescribingJson(schema: kSPGeoContextSchema, andDictionary: geoLocationDict))
            }
        }

        if applicationContext {
            if let contextJson = Utilities.applicationContext {
                event.addContextEntity(contextJson)
            }
        }

        if event.isService {
            return
        }

        // Add session
        if let session = session {
            if let sessionDict = session.getDictWithEventId(event.eventId.uuidString,
                                                            eventTimestamp: event.timestamp,
                                                            userAnonymisation: userAnonymisation) {
                event.addContextEntity(SelfDescribingJson(schema: kSPSessionContextSchema, andDictionary: sessionDict))
            } else {
                logDiagnostic(message: String(format: "Unable to get session context for eventId: %@", event.eventId.uuidString))
            }
        }

        // Add GDPR context
        if let gdprContext = gdprContext?.context {
            event.addContextEntity(gdprContext)
        }
    }

    private func addStateMachinePayloadValues(event: TrackerEvent) {
        _ = stateManager.addPayloadValues(to: event)
    }

    func addStateMachineEntities(event: TrackerEvent) {
        let stateManagerEntities = stateManager.entities(forProcessedEvent: event)
        for entity in stateManagerEntities {
            event.addContextEntity(entity)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
