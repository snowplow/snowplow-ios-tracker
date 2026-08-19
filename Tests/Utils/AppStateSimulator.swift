//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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
@testable import SnowplowTracker

/// Overrides the app state that `AppStateProvider` reads.
///
/// `AppStateProvider` caches its value process-wide, so tests that simulate a state must reset it again
/// afterwards, otherwise the next test sees the state of the previous one.
class AppStateSimulator {

    /// Makes the tracker read the given app state from now on, as if a tracker had just been created.
    static func simulate(_ state: AppState) {
        AppStateProvider.appStateGenerator = { state }
        AppStateProvider.ensureInitialized()
    }

    /// Restores the visible app state that the tracker assumes when it can't read the real one.
    static func reset() {
        simulate(.active)
        AppStateProvider.appStateGenerator = AppStateProvider.defaultAppStateGenerator
    }
}
