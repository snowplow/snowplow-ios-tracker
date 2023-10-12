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

class TrackerData {
    var advertisingIdentifierRetriever: (() -> UUID?)?
    var applicationContext: Bool = TrackerDefaults.applicationContext
    var appId: String
    var autotrackScreenViews: Bool = TrackerDefaults.autotrackScreenViews
    var base64Encoded: Bool = TrackerDefaults.base64Encoded
    var backgroundTimeout: Int = TrackerDefaults.backgroundTimeout
    /// Current screen view state.
    var currentScreenState: ScreenState?
    var devicePlatform: DevicePlatform = TrackerDefaults.devicePlatform
    var deepLinkContext: Bool = false
    var exceptionEvents = TrackerDefaults.exceptionEvents
    var foregroundTimeout: Int = TrackerDefaults.foregroundTimeout
    var gdprContext: GDPRContext?
    var inBackground: Bool {
        return session?.inBackground ?? false
    }
    var installEvent = TrackerDefaults.installEvent
    var lifecycleEvents: Bool = false
    var logLevel: LogLevel {
        get { return Logger.logLevel }
        set { Logger.logLevel = newValue }
    }
    var loggerDelegate: LoggerDelegate? {
        get { return Logger.delegate }
        set { Logger.delegate = newValue }
    }
    /// Previous screen view state.
    var previousScreenState: ScreenState?
    /// The object used for sessionization, i.e. it characterizes user activity.
    var session: Session?
    var sessionContext: Bool = false
    var screenContext: Bool = false
    var stateManager = StateManager()
    var subject: Subject?
    var trackerDiagnostic = TrackerDefaults.trackerDiagnostic
    var trackerNamespace: String
    var trackerVersionSuffix: String = TrackerDefaults.trackerVersionSuffix
    var userAnonymisation: Bool = TrackerDefaults.userAnonymisation

    init(appId: String, trackerNamespace: String) {
        self.appId = appId
        self.trackerNamespace = trackerNamespace
    }
    
}
