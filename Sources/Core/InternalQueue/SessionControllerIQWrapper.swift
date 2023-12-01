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

class SessionControllerIQWrapper: SessionController {
    
    private let controller: SessionController
    
    init(controller: SessionController) {
        self.controller = controller
    }
    
    func pause() {
        InternalQueue.sync { controller.pause() }
    }

    func resume() {
        InternalQueue.sync { controller.resume() }
    }

    func startNewSession() {
        InternalQueue.sync { controller.startNewSession() }
    }

    // MARK: - Properties

    var foregroundTimeout: Measurement<UnitDuration> {
        get { InternalQueue.sync { controller.foregroundTimeout } }
        set { InternalQueue.sync { controller.foregroundTimeout = newValue } }
    }

    var foregroundTimeoutInSeconds: Int {
        get { InternalQueue.sync { controller.foregroundTimeoutInSeconds } }
        set { InternalQueue.sync { controller.foregroundTimeoutInSeconds = newValue } }
    }

    var backgroundTimeout: Measurement<UnitDuration> {
        get { InternalQueue.sync { controller.backgroundTimeout } }
        set { InternalQueue.sync { controller.backgroundTimeout = newValue } }
    }

    var backgroundTimeoutInSeconds: Int {
        get { InternalQueue.sync { controller.backgroundTimeoutInSeconds } }
        set { InternalQueue.sync { controller.backgroundTimeoutInSeconds = newValue } }
    }

    var onSessionStateUpdate: ((_ sessionState: SessionState) -> Void)? {
        get { InternalQueue.sync { controller.onSessionStateUpdate } }
        set { InternalQueue.sync { controller.onSessionStateUpdate = newValue } }
    }

    var sessionIndex: Int {
        InternalQueue.sync { controller.sessionIndex }
    }

    var sessionId: String? {
        InternalQueue.sync { controller.sessionId }
    }

    var userId: String? {
        InternalQueue.sync { controller.userId }
    }

    var isInBackground: Bool {
        InternalQueue.sync { controller.isInBackground }
    }

    var backgroundIndex: Int {
        InternalQueue.sync { controller.backgroundIndex }
    }

    var foregroundIndex: Int {
        InternalQueue.sync { controller.foregroundIndex }
    }

}
