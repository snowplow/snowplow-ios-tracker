//
//  SPTrackerConfigurationUpdate.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Foundation

class TrackerConfigurationUpdate: TrackerConfiguration {
    private var appIdUpdated = false
    private var devicePlatformUpdated = false
    private var base64EncodingUpdated = false
    private var logLevelUpdated = false
    private var loggerDelegateUpdated = false
    private var applicationContextUpdated = false
    private var platformContextUpdated = false
    private var geoLocationContextUpdated = false
    private var deepLinkContextUpdated = false
    private var sessionContextUpdated = false
    private var screenContextUpdated = false
    private var screenViewAutotrackingUpdated = false
    private var lifecycleAutotrackingUpdated = false
    private var installAutotrackingUpdated = false
    private var exceptionAutotrackingUpdated = false
    private var diagnosticAutotrackingUpdated = false
    private var userAnonymisationUpdated = false
    private var trackerVersionSuffixUpdated = false
    private var advertisingIdentifierRetrieverUpdated = false
    
    var sourceConfig: TrackerConfiguration?
    var isPaused = false

    override var appId: String {
        get {
            return ((sourceConfig == nil) || appIdUpdated) ? super.appId : sourceConfig?.appId ?? ""
        }
        set { super.appId = newValue }
    }

    override var devicePlatform: DevicePlatform {
        get {
            return ((sourceConfig == nil) || devicePlatformUpdated) ? super.devicePlatform : sourceConfig?.devicePlatform ?? TrackerDefaults.devicePlatform
        }
        set {
            super.devicePlatform = newValue
            devicePlatformUpdated = true
        }
    }

    override var base64Encoding: Bool {
        get {
            return ((sourceConfig == nil) || base64EncodingUpdated) ? super.base64Encoding : sourceConfig?.base64Encoding ?? TrackerDefaults.base64Encoded
        }
        set {
            super.base64Encoding = newValue
            base64EncodingUpdated = true
        }
    }

    override var logLevel: LogLevel {
        get {
            return ((sourceConfig == nil) || logLevelUpdated) ? super.logLevel : sourceConfig?.logLevel ?? LogLevel.off
        }
        set {
            super.logLevel = newValue
            logLevelUpdated = true
        }
    }

    override var loggerDelegate: LoggerDelegate? {
        get {
            return ((sourceConfig == nil) || loggerDelegateUpdated) ? super.loggerDelegate : sourceConfig?.loggerDelegate
        }
        set {
            super.loggerDelegate = newValue
            loggerDelegateUpdated = true
        }
    }

    override var applicationContext: Bool {
        get {
            return ((sourceConfig == nil) || applicationContextUpdated) ? super.applicationContext : sourceConfig?.applicationContext ?? TrackerDefaults.applicationContext
        }
        set {
            super.applicationContext = newValue
            applicationContextUpdated = true
        }
    }

    override var platformContext: Bool {
        get {
            return ((sourceConfig == nil) || platformContextUpdated) ? super.platformContext : sourceConfig?.platformContext ?? TrackerDefaults.platformContext
        }
        set {
            super.platformContext = newValue
            platformContextUpdated = true
        }
    }

    override var geoLocationContext: Bool {
        get {
            return ((sourceConfig == nil) || geoLocationContextUpdated) ? super.geoLocationContext : sourceConfig?.geoLocationContext ?? TrackerDefaults.geoLocationContext
        }
        set {
            super.geoLocationContext = newValue
            geoLocationContextUpdated = true
        }
    }

    override var deepLinkContext: Bool {
        get {
            return ((sourceConfig == nil) || deepLinkContextUpdated) ? super.deepLinkContext : sourceConfig?.deepLinkContext ?? TrackerDefaults.deepLinkContext
        }
        set {
            super.deepLinkContext = newValue
            deepLinkContextUpdated = true
        }
    }

    override var sessionContext: Bool {
        get {
            return ((sourceConfig == nil) || sessionContextUpdated) ? super.sessionContext : sourceConfig?.sessionContext ?? TrackerDefaults.sessionContext
        }
        set {
            super.sessionContext = newValue
            sessionContextUpdated = true
        }
    }

    override var screenContext: Bool {
        get {
            return ((sourceConfig == nil) || screenContextUpdated) ? super.screenContext : sourceConfig?.screenContext ?? TrackerDefaults.screenContext
        }
        set {
            super.screenContext = newValue
            screenContextUpdated = true
        }
    }

    override var screenViewAutotracking: Bool {
        get {
            return ((sourceConfig == nil) || screenViewAutotrackingUpdated) ? super.screenViewAutotracking : sourceConfig?.screenViewAutotracking ?? TrackerDefaults.autotrackScreenViews
        }
        set {
            super.screenViewAutotracking = newValue
            screenViewAutotrackingUpdated = true
        }
    }

    override var lifecycleAutotracking: Bool {
        get {
            return ((sourceConfig == nil) || lifecycleAutotrackingUpdated) ? super.lifecycleAutotracking : sourceConfig?.lifecycleAutotracking ?? TrackerDefaults.lifecycleEvents
        }
        set {
            super.lifecycleAutotracking = newValue
            lifecycleAutotrackingUpdated = true
        }
    }

    override var installAutotracking: Bool {
        get {
            return ((sourceConfig == nil) || installAutotrackingUpdated) ? super.installAutotracking : sourceConfig?.installAutotracking ?? TrackerDefaults.installEvent
        }
        set {
            super.installAutotracking = newValue
            installAutotrackingUpdated = true
        }
    }

    override var exceptionAutotracking: Bool {
        get {
            return ((sourceConfig == nil) || exceptionAutotrackingUpdated) ? super.exceptionAutotracking : sourceConfig?.exceptionAutotracking ?? TrackerDefaults.exceptionEvents
        }
        set {
            super.exceptionAutotracking = newValue
            exceptionAutotrackingUpdated = true
        }
    }

    override var diagnosticAutotracking: Bool {
        get {
            return ((sourceConfig == nil) || diagnosticAutotrackingUpdated) ? super.diagnosticAutotracking : sourceConfig?.diagnosticAutotracking ?? TrackerDefaults.trackerDiagnostic
        }
        set {
            super.diagnosticAutotracking = newValue
            diagnosticAutotrackingUpdated = true
        }
    }

    override var userAnonymisation: Bool {
        get {
            return ((sourceConfig == nil) || userAnonymisationUpdated) ? super.userAnonymisation : sourceConfig?.userAnonymisation ?? TrackerDefaults.userAnonymisation
        }
        set {
            super.userAnonymisation = newValue
            userAnonymisationUpdated = true
        }
    }

    override var trackerVersionSuffix: String? {
        get {
            return ((sourceConfig == nil) || trackerVersionSuffixUpdated) ? super.trackerVersionSuffix : sourceConfig?.trackerVersionSuffix
        }
        set {
            super.trackerVersionSuffix = newValue
            trackerVersionSuffixUpdated = true
        }
    }

    override var advertisingIdentifierRetriever: (() -> UUID?)? {
        get {
            return ((sourceConfig == nil) || advertisingIdentifierRetrieverUpdated) ? super.advertisingIdentifierRetriever : sourceConfig?.advertisingIdentifierRetriever
        }
        set {
            super.advertisingIdentifierRetriever = newValue
            advertisingIdentifierRetrieverUpdated = true
        }
    }
}
