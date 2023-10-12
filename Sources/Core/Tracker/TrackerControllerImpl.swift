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

class TrackerControllerImpl: Controller, TrackerController {
    
    // MARK: - Controllers

    var network: NetworkController? {
        return serviceProvider.networkController
    }

    var emitter: EmitterController? {
        return serviceProvider.emitterController
    }

    var gdpr: GDPRController? {
        return serviceProvider.gdprController
    }

    var globalContexts: GlobalContextsController? {
        return serviceProvider.globalContextsController
    }

    var subject: SubjectController? {
        return serviceProvider.subjectController
    }

    var sessionController: SessionControllerImpl {
        return serviceProvider.sessionController
    }

    var session: SessionController? {
        let sessionController = serviceProvider.sessionController
        return sessionController.isEnabled ? sessionController : nil
    }

    var plugins: PluginsController {
        return serviceProvider.pluginsController
    }
    
    var media: MediaController {
        return serviceProvider.mediaController
    }
    
    var ecommerce: EcommerceController {
        return serviceProvider.ecommerceController
    }

    // MARK: - Control methods

    func pause() {
        dirtyConfig.isPaused = true
        tracker.pauseEventTracking()
    }

    func resume() {
        dirtyConfig.isPaused = false
        tracker.resumeEventTracking()
    }

    func track(_ event: Event) -> UUID {
        return tracker.track(event)
    }

    // MARK: - Properties' setters and getters

    var appId: String {
        get {
            return tracker.appId
        }
        set {
            dirtyConfig.appId = newValue
            tracker.appId = newValue
        }
    }

    var namespace: String {
        return (tracker).trackerNamespace
    }

    var devicePlatform: DevicePlatform {
        get {
            return tracker.devicePlatform
        }
        set {
            dirtyConfig.devicePlatform = newValue
            tracker.devicePlatform = newValue
        }
    }

    var base64Encoding: Bool {
        get {
            return tracker.base64Encoded
        }
        set {
            dirtyConfig.base64Encoding = newValue
            tracker.base64Encoded = newValue
        }
    }

    var logLevel: LogLevel {
        get {
            return tracker.logLevel
        }
        set {
            dirtyConfig.logLevel = newValue
            tracker.logLevel = newValue
        }
    }

    var loggerDelegate: LoggerDelegate? {
        get {
            return Logger.delegate
        }
        set {
            Logger.delegate = newValue
        }
    }

    var applicationContext: Bool {
        get {
            return tracker.applicationContext
        }
        set {
            dirtyConfig.applicationContext = newValue
            tracker.applicationContext = newValue
        }
    }

    var platformContext: Bool {
        get {
            return tracker.subject?.platformContext ?? false
        }
        set {
            dirtyConfig.platformContext = newValue
            tracker.subject?.platformContext = newValue
        }
    }
    
    var platformContextProperties: [PlatformContextProperty]? {
        get {
            return tracker.subject?.platformContextProperties
        }
        set {
            tracker.subject?.platformContextProperties = newValue
        }
    }

    var geoLocationContext: Bool {
        get {
            return tracker.subject?.geoLocationContext ?? false
        }
        set {
            dirtyConfig.geoLocationContext = newValue
            tracker.subject?.geoLocationContext = newValue
        }
    }

    var diagnosticAutotracking: Bool {
        get {
            return tracker.trackerDiagnostic
        }
        set {
            dirtyConfig.diagnosticAutotracking = newValue
            tracker.trackerDiagnostic = newValue
        }
    }

    var exceptionAutotracking: Bool {
        get {
            return tracker.exceptionEvents
        }
        set {
            dirtyConfig.exceptionAutotracking = newValue
            tracker.exceptionEvents = newValue
        }
    }

    var installAutotracking: Bool {
        get {
            return tracker.installEvent
        }
        set {
            dirtyConfig.installAutotracking = newValue
            tracker.installEvent = newValue
        }
    }

    var lifecycleAutotracking: Bool {
        get {
            return tracker.lifecycleEvents
        }
        set {
            dirtyConfig.lifecycleAutotracking = newValue
            tracker.lifecycleEvents = newValue
        }
    }

    var deepLinkContext: Bool {
        get {
            return tracker.deepLinkContext
        }
        set {
            dirtyConfig.deepLinkContext = newValue
            tracker.deepLinkContext = newValue
        }
    }

    var screenContext: Bool {
        get {
            return tracker.screenContext
        }
        set {
            dirtyConfig.screenContext = newValue
            tracker.screenContext = newValue
        }
    }

    var screenViewAutotracking: Bool {
        get {
            return tracker.autotrackScreenViews
        }
        set {
            dirtyConfig.screenViewAutotracking = newValue
            tracker.autotrackScreenViews = newValue
        }
    }

    var trackerVersionSuffix: String? {
        get {
            return tracker.trackerVersionSuffix
        }
        set {
            dirtyConfig.trackerVersionSuffix = newValue
            if let value = newValue {
                tracker.trackerVersionSuffix = value
            }
        }
    }

    var sessionContext: Bool {
        get {
            return tracker.sessionContext
        }
        set {
            dirtyConfig.sessionContext = newValue
            tracker.sessionContext = newValue
        }
    }

    var userAnonymisation: Bool {
        get {
            return tracker.userAnonymisation
        }
        set {
            dirtyConfig.userAnonymisation = newValue
            tracker.userAnonymisation = newValue
        }
    }

    var advertisingIdentifierRetriever: (() -> UUID?)? {
        get {
            return tracker.advertisingIdentifierRetriever
        }
        set {
            dirtyConfig.advertisingIdentifierRetriever = newValue
            tracker.advertisingIdentifierRetriever = newValue
        }
    }

    var isTracking: Bool {
        return tracker.isTracking
    }

    var version: String {
        return kSPVersion
    }

    // MARK: - Private methods

    private var tracker: Tracker {
        if !serviceProvider.isTrackerInitialized {
            // TODO: return nil
            logError(message: "Recreating tracker instance after it was removed. This will not be supported in future versions.")
        }
        return serviceProvider.tracker
    }

    private var dirtyConfig: TrackerConfiguration {
        return serviceProvider.trackerConfiguration
    }
}
