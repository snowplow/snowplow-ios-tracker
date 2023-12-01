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

class ServiceProvider: NSObject, ServiceProviderProtocol {
    let namespace: String
    
    var isTrackerInitialized: Bool { return _tracker != nil }

    // Internal services
    private var _subject: Subject?
    var subject: Subject {
        if let subject = _subject { return subject }
        let subject = makeSubject()
        _subject = subject
        return subject
    }

    private var _emitter: Emitter?
    var emitter: Emitter {
        if let emitter = _emitter { return emitter }
        let emitter = makeEmitter()
        _emitter = emitter
        return emitter
    }

    private var _tracker: Tracker?
    var tracker: Tracker {
        if let tracker = _tracker { return tracker }
        let tracker = makeTracker()
        _tracker = tracker
        return tracker
    }

    // Controllers

    private var _trackerController: TrackerControllerImpl?
    var trackerController: TrackerControllerImpl {
        if let controller = _trackerController { return controller }
        let trackerController = makeTrackerController()
        _trackerController = trackerController
        return trackerController
    }

    private var _sessionController: SessionControllerImpl?
    var sessionController: SessionControllerImpl {
        if let controller = _sessionController { return controller }
        let sessionController = makeSessionController()
        _sessionController = sessionController
        return sessionController
    }

    private var _emitterController: EmitterControllerImpl?
    var emitterController: EmitterControllerImpl {
        if let controller = _emitterController { return controller }
        let emitterController = makeEmitterController()
        _emitterController = emitterController
        return emitterController
    }

    private var _gdprController: GDPRControllerImpl?
    var gdprController: GDPRControllerImpl {
        if let controller = _gdprController { return controller }
        let gdprController = makeGDPRController()
        _gdprController = gdprController
        return gdprController
    }

    var globalContextsController: GlobalContextsControllerImpl {
        return GlobalContextsControllerImpl(serviceProvider: self)
    }

    private var _subjectController: SubjectControllerImpl?
    var subjectController: SubjectControllerImpl {
        if let controller = _subjectController { return controller }
        let subjectController = makeSubjectController()
        _subjectController = subjectController
        return subjectController
    }

    private var _networkController: NetworkControllerImpl?
    var networkController: NetworkControllerImpl {
        if let controller = _networkController { return controller }
        let networkController = makeNetworkController()
        _networkController = networkController
        return networkController
    }
    
    var pluginsController: PluginsControllerImpl {
        return PluginsControllerImpl(serviceProvider: self)
    }
    
    private var _mediaController: MediaController?
    var mediaController: MediaController {
        if let controller = _mediaController { return controller }
        let mediaController = MediaControllerImpl(serviceProvider: self)
        _mediaController = mediaController
        return mediaController
    }
    
    private var _ecommerceController: EcommerceController?
    var ecommerceController: EcommerceController {
        if let controller = _ecommerceController { return controller }
        let ecommerceController = EcommerceControllerImpl(serviceProvider: self)
        _ecommerceController = ecommerceController
        return ecommerceController
    }
    
    private(set) var networkConfiguration = NetworkConfiguration()
    private(set) var trackerConfiguration = TrackerConfiguration()
    private(set) var emitterConfiguration = EmitterConfiguration()
    private(set) var subjectConfiguration = SubjectConfiguration()
    private(set) var sessionConfiguration = SessionConfiguration()
    private(set) var gdprConfiguration = GDPRConfiguration()
    private(set) var pluginConfigurations: [PluginIdentifiable] = []
    
    // MARK: - Init

    init(namespace: String, network networkConfiguration: NetworkConfiguration, configurations: [ConfigurationProtocol]) {
        self.namespace = namespace
        super.init()
        
        self.networkConfiguration.sourceConfig = networkConfiguration
        processConfigurations(configurations)
        let _ = tracker // Build tracker to initialize NotificationCenter receivers
    }

    func reset(configurations: [ConfigurationProtocol]) {
        stopServices()
        resetSourceConfigurations()
        processConfigurations(configurations)
        resetServices()
        let _ = tracker
    }

    func shutdown() {
        tracker.pauseEventTracking()
        stopServices()
        resetServices()
        resetControllers()
        initializeConfigurations()
    }

    // MARK: - Private methods

    func processConfigurations(_ configurations: [ConfigurationProtocol]) {
        for configuration in configurations {
            if let configuration = configuration as? NetworkConfiguration {
                networkConfiguration.sourceConfig = configuration
            } else if let configuration = configuration as? TrackerConfiguration {
                trackerConfiguration.sourceConfig = configuration
            } else if let configuration = configuration as? SubjectConfiguration {
                subjectConfiguration.sourceConfig = configuration
            } else if let configuration = configuration as? SessionConfiguration {
                sessionConfiguration.sourceConfig = configuration
            } else if let configuration = configuration as? EmitterConfiguration {
                emitterConfiguration.sourceConfig = configuration
            } else if let configuration = configuration as? GDPRConfiguration {
                gdprConfiguration.sourceConfig = configuration
            } else if let configuration = configuration as? GlobalContextsConfiguration {
                for plugin in configuration.toPluginConfigurations() {
                    pluginConfigurations.append(plugin)
                }
            } else if let configuration = configuration as? PluginIdentifiable {
                pluginConfigurations.append(configuration)
            }
        }
    }

    func stopServices() {
        emitter.pauseTimer()
    }

    func resetServices() {
        _emitter = nil
        _subject = nil
        _tracker = nil
    }

    func resetControllers() {
        _trackerController = nil
        _sessionController = nil
        _emitterController = nil
        _gdprController = nil
        _subjectController = nil
        _networkController = nil
    }

    func resetSourceConfigurations() {
        // Don't reset networkConfiguration as it's needed in case it's not passed in the new configurations.
        // Set a default trackerConfiguration to reset to default if not passed.
        trackerConfiguration.sourceConfig = nil
        emitterConfiguration.sourceConfig = nil
        subjectConfiguration.sourceConfig = nil
        sessionConfiguration.sourceConfig = nil
        gdprConfiguration.sourceConfig = nil
    }

    func initializeConfigurations() {
        networkConfiguration = NetworkConfiguration()
        trackerConfiguration = TrackerConfiguration()
        emitterConfiguration = EmitterConfiguration()
        subjectConfiguration = SubjectConfiguration()
        sessionConfiguration = SessionConfiguration()
        gdprConfiguration = GDPRConfiguration()
    }

    // MARK: - Getters

    // MARK: - Factories

    //#pragma clang diagnostic push
    //#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    func makeSubject() -> Subject {
        return Subject(
            platformContext: trackerConfiguration.platformContext,
            platformContextProperties: trackerConfiguration.platformContextProperties,
            geoLocationContext: trackerConfiguration.geoLocationContext,
            subjectConfiguration: subjectConfiguration)
    }

    func makeEmitter() -> Emitter {
        let builder = { (emitter: Emitter) in
            emitter.emitThreadPoolSize = self.emitterConfiguration.threadPoolSize
            emitter.byteLimitGet = self.emitterConfiguration.byteLimitGet
            emitter.byteLimitPost = self.emitterConfiguration.byteLimitPost
            emitter.emitRange = self.emitterConfiguration.emitRange
            emitter.bufferOption = self.emitterConfiguration.bufferOption
            emitter.callback = self.emitterConfiguration.requestCallback
            emitter.customRetryForStatusCodes = self.emitterConfiguration.customRetryForStatusCodes
            emitter.retryFailedRequests = self.emitterConfiguration.retryFailedRequests
        }

        let emitter: Emitter
        if let networkConnection = networkConfiguration.networkConnection {
            emitter = Emitter(
                networkConnection: networkConnection,
                namespace: self.namespace,
                eventStore: self.emitterConfiguration.eventStore,
                builder: builder
            )
        } else {
            emitter = Emitter(
                namespace: self.namespace,
                urlEndpoint: networkConfiguration.endpoint ?? "",
                method: self.networkConfiguration.method,
                protocol: self.networkConfiguration.protocol,
                customPostPath: self.networkConfiguration.customPostPath,
                requestHeaders: self.networkConfiguration.requestHeaders,
                serverAnonymisation: self.emitterConfiguration.serverAnonymisation,
                eventStore: self.emitterConfiguration.eventStore,
                builder: builder
            )
        }
        
        if emitterConfiguration.isPaused {
            emitter.pauseEmit()
        }
        return emitter
    }

    func makeTracker() -> Tracker {
        let emitter = self.emitter
        let subject = self.subject
        
        let tracker = Tracker(
            trackerNamespace: namespace,
            appId: trackerConfiguration.appId,
            emitter: emitter
        ) { tracker in
            if let suffix = trackerConfiguration.trackerVersionSuffix {
                tracker.trackerVersionSuffix = suffix
            }
            tracker.sessionContext = trackerConfiguration.sessionContext
            tracker.foregroundTimeout = sessionConfiguration.foregroundTimeoutInSeconds
            tracker.backgroundTimeout = sessionConfiguration.backgroundTimeoutInSeconds
            tracker.exceptionEvents = trackerConfiguration.exceptionAutotracking
            tracker.subject = subject
            tracker.base64Encoded = trackerConfiguration.base64Encoding
            tracker.logLevel = trackerConfiguration.logLevel
            tracker.loggerDelegate = trackerConfiguration.loggerDelegate
            tracker.devicePlatform = trackerConfiguration.devicePlatform
            tracker.applicationContext = trackerConfiguration.applicationContext
            tracker.deepLinkContext = trackerConfiguration.deepLinkContext
            tracker.screenContext = trackerConfiguration.screenContext
            tracker.autotrackScreenViews = trackerConfiguration.screenViewAutotracking
            tracker.lifecycleEvents = trackerConfiguration.lifecycleAutotracking
            tracker.installEvent = trackerConfiguration.installAutotracking
            tracker.trackerDiagnostic = trackerConfiguration.diagnosticAutotracking
            tracker.userAnonymisation = trackerConfiguration.userAnonymisation
            tracker.advertisingIdentifierRetriever = trackerConfiguration.advertisingIdentifierRetriever
            if gdprConfiguration.sourceConfig != nil {
                tracker.gdprContext = GDPRContext(
                    basis: gdprConfiguration.basisForProcessing,
                    documentId: gdprConfiguration.documentId,
                    documentVersion: gdprConfiguration.documentVersion,
                    documentDescription: gdprConfiguration.documentDescription)
            }

            for plugin in pluginConfigurations {
                tracker.addOrReplace(stateMachine: plugin.toStateMachine())
            }
        }
        
        if trackerConfiguration.isPaused {
            tracker.pauseEventTracking()
        }
        if let session = tracker.session {
            if sessionConfiguration.isPaused {
                session.stopChecker()
            }
            if let callback = sessionConfiguration.onSessionStateUpdate {
                session.onSessionStateUpdate = callback
            }
        }
        return tracker
    }

    func makeTrackerController() -> TrackerControllerImpl {
        return TrackerControllerImpl(serviceProvider: self)
    }

    func makeSessionController() -> SessionControllerImpl {
        return SessionControllerImpl(serviceProvider: self)
    }

    func makeEmitterController() -> EmitterControllerImpl {
        return EmitterControllerImpl(serviceProvider: self)
    }

    func makeGDPRController() -> GDPRControllerImpl {
        let controller = GDPRControllerImpl(serviceProvider: self)
        if let gdpr = tracker.gdprContext {
            controller.reset(basis: gdpr.basis, documentId: gdpr.documentId, documentVersion: gdpr.documentVersion, documentDescription: gdpr.documentDescription)
        }
        return controller
    }

    func makeSubjectController() -> SubjectControllerImpl {
        return SubjectControllerImpl(serviceProvider: self)
    }

    func makeNetworkController() -> NetworkControllerImpl {
        return NetworkControllerImpl(serviceProvider: self)
    }
    
    func addPlugin(plugin: PluginIdentifiable) {
        removePlugin(identifier: plugin.identifier)
        pluginConfigurations.append(plugin)
        tracker.addOrReplace(stateMachine: plugin.toStateMachine())
    }

    func removePlugin(identifier: String) {
        pluginConfigurations = pluginConfigurations.filter { $0.identifier != identifier }
        tracker.remove(stateMachineIdentifier: identifier)
    }
}
