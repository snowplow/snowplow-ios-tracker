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
import XCTest
@testable import SnowplowTracker

/// Overrides the app state that `AppStateProvider` reads.
///
/// `AppStateProvider` caches its value process-wide, so a simulated state leaks into whichever test runs
/// next – including tests that never mention the app state and only create a tracker – unless it is reset.
/// Prefer ``XCTestCase/simulateAppState(_:)``, which resets automatically even if the test fails part way
/// through; the static methods here are for the few call sites that have no test case to hang that on.
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

extension XCTestCase {

    /// Simulates the given app state for the rest of this test, resetting it when the test ends.
    ///
    /// `addTeardownBlock` runs even when the test fails or throws part way through, so the simulated state
    /// can't outlive the test that asked for it.
    func simulateAppState(_ state: AppState) {
        addTeardownBlock { AppStateSimulator.reset() }
        AppStateSimulator.simulate(state)
    }
}
