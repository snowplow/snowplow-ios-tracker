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

class SessionConfigurationUpdate: SessionConfiguration {
    var sourceConfig: SessionConfiguration?
    var isPaused = false
    var foregroundTimeoutInSecondsUpdated = false
    var backgroundTimeoutInSecondsUpdated = false
    var onSessionStateUpdateUpdated = false

    override var foregroundTimeoutInSeconds: Int {
        get {
            return ((sourceConfig == nil || foregroundTimeoutInSecondsUpdated) ? super.foregroundTimeoutInSeconds : sourceConfig?.foregroundTimeoutInSeconds) ?? 1800
        }
        set {
            super.foregroundTimeoutInSeconds = newValue
            foregroundTimeoutInSecondsUpdated = true
        }
    }

    override var backgroundTimeoutInSeconds: Int {
        get {
            return ((sourceConfig == nil || backgroundTimeoutInSecondsUpdated) ? super.backgroundTimeoutInSeconds : sourceConfig?.backgroundTimeoutInSeconds) ?? 1800
        }
        set {
            super.backgroundTimeoutInSeconds = newValue
            backgroundTimeoutInSecondsUpdated = true
        }
    }

    override var onSessionStateUpdate: ((_ sessionState: SessionState) -> Void)? {
        get {
            return ((sourceConfig == nil || onSessionStateUpdateUpdated) ? super.onSessionStateUpdate : sourceConfig?.onSessionStateUpdate)
        }
        set {
            super.onSessionStateUpdate = newValue
            onSessionStateUpdateUpdated = true
        }
    }
}
