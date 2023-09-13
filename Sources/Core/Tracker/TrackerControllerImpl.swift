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

    func track(_ event: Event) -> UUID? {
        return tracker.track(event)
    }
    
    func decorateLink(_ url: URL) -> URL? {
        self.decorateLink(url, extendedParameters: CrossDeviceParameterConfiguration())
    }
    
    func decorateLink(_ url: URL, extendedParameters: CrossDeviceParameterConfiguration) -> URL? {
        var userId: String
        switch self.session?.userId {
        case .none:
            logError(message: "\(url) could not be decorated as session.userId is nil")
            return nil
        case .some(let id):
            userId = id
        }
        
        let sessionId = extendedParameters.sessionId ? self.session?.sessionId ?? "" : ""
        if (extendedParameters.sessionId && sessionId.isEmpty) {
            logDebug(message: "\(decorateLinkErrorTemplate("sessionId")) Ensure an event has been tracked to generate a session before calling this method.")
        }
        
        let sourceId = extendedParameters.sourceId ? self.appId : ""
        
        let sourcePlatform = extendedParameters.sourcePlatform ? devicePlatformToString(self.devicePlatform) : ""
        
        let subjectUserId = extendedParameters.subjectUserId ? self.subject?.userId ?? "" : ""
        if (extendedParameters.subjectUserId && subjectUserId.isEmpty) {
            logDebug(message: "\(decorateLinkErrorTemplate("subjectUserId")) Ensure SubjectConfiguration.userId has been set on your tracker.")
        }
        
        let reason = extendedParameters.reason ?? ""
        
        let spParameters = [
            userId,
            String(Int(Date().timeIntervalSince1970 * 1000)),
            sessionId,
            subjectUserId.toBase64(),
            sourceId.toBase64(),
            sourcePlatform,
            reason.toBase64()
        ].joined(separator: ".").trimmingCharacters(in: ["."])
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let spQueryParam = URLQueryItem(name: "_sp", value: spParameters)
        
        // Modification requires exclusive access, we must make a copy
        let queryItems = components?.queryItems
        components?.queryItems = (queryItems?.filter { $0.name != "_sp" } ?? []) + [spQueryParam]
        
        return components?.url
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
    
    private func decorateLinkErrorTemplate(_ extendedParameterName: String) -> String {
        "\(extendedParameterName) has been requested in CrossDeviceParameterConfiguration, but it is not set."
    }
}
