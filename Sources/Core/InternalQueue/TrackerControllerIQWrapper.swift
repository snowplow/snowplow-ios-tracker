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

class TrackerControllerIQWrapper: TrackerController {
    
    private let controller: TrackerControllerImpl
    
    init(controller: TrackerControllerImpl) {
        self.controller = controller
    }
    
    // MARK: - Controllers

    var network: NetworkController? {
        return InternalQueue.sync {
            if let network = controller.network {
                return NetworkControllerIQWrapper(controller: network)
            } else {
                return nil
            }
        }
    }

    var emitter: EmitterController? {
        return InternalQueue.sync {
            if let emitter = controller.emitter {
                return EmitterControllerIQWrapper(controller: emitter)
            } else {
                return nil
            }
        }
    }

    var gdpr: GDPRController? {
        return InternalQueue.sync {
            if let gdpr = controller.gdpr {
                return GDPRControllerIQWrapper(controller: gdpr)
            } else {
                return nil
            }
        }
    }

    var globalContexts: GlobalContextsController? {
        return InternalQueue.sync {
            if let globalContexts = controller.globalContexts {
                return GlobalContextsControllerIQWrapper(controller: globalContexts)
            } else {
                return nil
            }
        }
    }

    var subject: SubjectController? {
        return InternalQueue.sync {
            if let subject = controller.subject {
                return SubjectControllerIQWrapper(controller: subject)
            } else {
                return nil
            }
        }
    }

    var session: SessionController? {
        return InternalQueue.sync {
            if let session = controller.session {
                return SessionControllerIQWrapper(controller: session)
            } else {
                return nil
            }
        }
    }

    var plugins: PluginsController {
        return InternalQueue.sync { PluginsControllerIQWrapper(controller: controller.plugins) }
    }
    
    var media: MediaController {
        return InternalQueue.sync { MediaControllerIQWrapper(controller: controller.media) }
    }
    
    var ecommerce: EcommerceController {
        return InternalQueue.sync { EcommerceControllerIQWrapper(controller: controller.ecommerce) }
    }

    // MARK: - Control methods

    func pause() {
        InternalQueue.sync { controller.pause() }
    }

    func resume() {
        InternalQueue.sync { controller.resume() }
    }

    func track(_ event: Event) -> UUID {
        let eventId = UUID()
        InternalQueue.async { self.controller.track(event, eventId: eventId) }
        return eventId
    }

    // MARK: - Properties' setters and getters

    var appId: String {
        get { return InternalQueue.sync { controller.appId } }
        set { InternalQueue.sync { controller.appId = newValue } }
    }

    var namespace: String {
        return InternalQueue.sync { controller.namespace }
    }

    var devicePlatform: DevicePlatform {
        get { return InternalQueue.sync { controller.devicePlatform } }
        set { InternalQueue.sync { controller.devicePlatform = newValue } }
    }

    var base64Encoding: Bool {
        get { return InternalQueue.sync { controller.base64Encoding } }
        set { InternalQueue.sync { controller.base64Encoding = newValue } }
    }

    var logLevel: LogLevel {
        get { return InternalQueue.sync { controller.logLevel } }
        set { InternalQueue.sync { controller.logLevel = newValue } }
    }

    var loggerDelegate: LoggerDelegate? {
        get { return InternalQueue.sync { controller.loggerDelegate } }
        set { InternalQueue.sync { controller.loggerDelegate = newValue } }
    }

    var applicationContext: Bool {
        get { return InternalQueue.sync { controller.applicationContext } }
        set { InternalQueue.sync { controller.applicationContext = newValue } }
    }

    var platformContext: Bool {
        get { return InternalQueue.sync { controller.platformContext } }
        set { InternalQueue.sync { controller.platformContext = newValue } }
    }
    
    var platformContextProperties: [PlatformContextProperty]? {
        get { return InternalQueue.sync { controller.platformContextProperties } }
        set { InternalQueue.sync { controller.platformContextProperties = newValue } }
    }

    var geoLocationContext: Bool {
        get { return InternalQueue.sync { controller.geoLocationContext } }
        set { InternalQueue.sync { controller.geoLocationContext = newValue } }
    }

    var diagnosticAutotracking: Bool {
        get { return InternalQueue.sync { controller.diagnosticAutotracking } }
        set { InternalQueue.sync { controller.diagnosticAutotracking = newValue } }
    }

    var exceptionAutotracking: Bool {
        get { return InternalQueue.sync { controller.exceptionAutotracking } }
        set { InternalQueue.sync { controller.exceptionAutotracking = newValue } }
    }

    var installAutotracking: Bool {
        get { return InternalQueue.sync { controller.installAutotracking } }
        set { InternalQueue.sync { controller.installAutotracking = newValue } }
    }

    var lifecycleAutotracking: Bool {
        get { return InternalQueue.sync { controller.lifecycleAutotracking } }
        set { InternalQueue.sync { controller.lifecycleAutotracking = newValue } }
    }

    var deepLinkContext: Bool {
        get { return InternalQueue.sync { controller.deepLinkContext } }
        set { InternalQueue.sync { controller.deepLinkContext = newValue } }
    }

    var screenContext: Bool {
        get { return InternalQueue.sync { controller.screenContext } }
        set { InternalQueue.sync { controller.screenContext = newValue } }
    }

    var screenViewAutotracking: Bool {
        get { return InternalQueue.sync { controller.screenViewAutotracking } }
        set { InternalQueue.sync { controller.screenViewAutotracking = newValue } }
    }

    var trackerVersionSuffix: String? {
        get { return InternalQueue.sync { controller.trackerVersionSuffix } }
        set { InternalQueue.sync { controller.trackerVersionSuffix = newValue } }
    }

    var sessionContext: Bool {
        get { return InternalQueue.sync { controller.sessionContext } }
        set { InternalQueue.sync { controller.sessionContext = newValue } }
    }

    var userAnonymisation: Bool {
        get { return InternalQueue.sync { controller.userAnonymisation } }
        set { InternalQueue.sync { controller.userAnonymisation = newValue } }
    }

    var advertisingIdentifierRetriever: (() -> UUID?)? {
        get { return InternalQueue.sync { controller.advertisingIdentifierRetriever } }
        set { InternalQueue.sync { controller.advertisingIdentifierRetriever = newValue } }
    }

    var isTracking: Bool {
        return InternalQueue.sync { controller.isTracking }
    }

    var version: String {
        return InternalQueue.sync { controller.version }
    }

}
