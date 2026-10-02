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

import XCTest
#if os(iOS) || os(tvOS)
import UIKit
#endif
@testable import SnowplowTracker

class TestAppStateProvider: XCTestCase {
    override func setUp() {
        super.setUp()
        AppStateSimulator.reset()
    }

    override func tearDown() {
        AppStateSimulator.reset()
        Snowplow.removeAllTrackers()
        super.tearDown()
    }

    func testIsVisibleWhenTheAppIsActive() {
        simulateAppState(.active)

        XCTAssertTrue(AppStateProvider.isVisible)
    }

    func testIsNotVisibleWhenTheAppIsInTheBackground() {
        simulateAppState(.background)

        XCTAssertFalse(AppStateProvider.isVisible)
    }

    /// An app that is launching into the foreground is inactive until it becomes active, so only the
    /// background state tells a background launch apart from a normal one.
    func testIsVisibleWhenTheAppIsInactive() {
        simulateAppState(.inactive)

        XCTAssertTrue(AppStateProvider.isVisible)
    }

    func testIsVisibleWhenTheAppStateCantBeRead() {
        simulateAppState(.background)
        simulateAppState(.unknown)

        XCTAssertTrue(AppStateProvider.isVisible)
    }

#if os(iOS) || os(tvOS)
    /// The transitions are driven directly rather than by posting the real notifications: every `Session`
    /// alive in the test process observes those too, and would track stray Foreground and Background events
    /// into other test cases' event sinks. Which notification is wired to which handler is therefore not
    /// covered here — `subscribeToLifecycleNotifications` is verified by inspection.

    /// `willResignActive` fires for interruptions that leave the app on screen – Control Center, an incoming
    /// call, a system alert – so it must not mark the app as not visible. Reporting `isVisible: false` there
    /// would be a false negative on the very field this provider exists to get right. The provider does not
    /// observe it at all, so the app simply stays visible.
    func testStaysVisibleWhileInterruptedByControlCenterOrACall() {
        simulateAppState(.active)

        // The state the app is in during such an interruption.
        simulateAppState(.inactive)

        XCTAssertTrue(AppStateProvider.isVisible)
    }

    func testIsNotVisibleAfterTheAppEntersTheBackground() {
        simulateAppState(.active)

        AppStateProvider.observer.didEnterBackground()

        XCTAssertFalse(AppStateProvider.isVisible)
    }

    /// `willEnterForeground` arrives while the app is still inactive, before `didBecomeActive`, and is the
    /// earliest point at which the app is back on screen.
    func testIsVisibleAgainWhenTheAppReturnsToTheForeground() {
        simulateAppState(.active)
        AppStateProvider.observer.didEnterBackground()
        XCTAssertFalse(AppStateProvider.isVisible)

        AppStateProvider.observer.willEnterForeground()

        XCTAssertTrue(AppStateProvider.isVisible)
    }

    // MARK: - Mapping the UIKit state

    // The values below are the ones read on a simulator from a scene-based SwiftUI app and an app without
    // scenes, at the points where a tracker is typically created.

    /// A scene-based app is still in the background state in `didFinishLaunchingWithOptions` and in
    /// `scene(_:willConnectTo:options:)` when the user launches it. Reading that as a background launch made
    /// every cold launch track a Foreground event and report `isVisible: false` on its first events.
    func testSceneBasedAppLaunchedByTheUserIsVisible() {
        let state = AppStateProvider.appState(for: .background,
                                              hasAttachedScene: false,
                                              backgroundTimeRemaining: .greatestFiniteMagnitude,
                                              hasForegroundTaskRole: true)

        XCTAssertEqual(state, .inactive)
    }

    func testSceneBasedAppLaunchedInTheBackgroundIsNotVisible() {
        let state = AppStateProvider.appState(for: .background,
                                              hasAttachedScene: false,
                                              backgroundTimeRemaining: 30,
                                              hasForegroundTaskRole: false)

        XCTAssertEqual(state, .background)
    }

    /// A process the system starts in the background for location updates or audio has an unlimited
    /// background time budget too, but isn't the foreground application.
    func testSceneBasedAppLaunchedInTheBackgroundWithAnUnlimitedBudgetIsNotVisible() {
        let state = AppStateProvider.appState(for: .background,
                                              hasAttachedScene: false,
                                              backgroundTimeRemaining: .greatestFiniteMagnitude,
                                              hasForegroundTaskRole: false)

        XCTAssertEqual(state, .background)
    }

    /// The role alone isn't trusted either: both signals have to agree.
    func testSceneBasedAppWithALimitedBudgetIsNotVisibleEvenWithAForegroundRole() {
        let state = AppStateProvider.appState(for: .background,
                                              hasAttachedScene: false,
                                              backgroundTimeRemaining: 30,
                                              hasForegroundTaskRole: true)

        XCTAssertEqual(state, .background)
    }

    /// Right after a running app is moved to the background, its background time budget and task role still
    /// read as foreground, but its scene is already attached.
    func testAppMovedToTheBackgroundIsNotVisibleWhileItsBudgetIsStillUnlimited() {
        let state = AppStateProvider.appState(for: .background,
                                              hasAttachedScene: true,
                                              backgroundTimeRemaining: .greatestFiniteMagnitude,
                                              hasForegroundTaskRole: true)

        XCTAssertEqual(state, .background)
    }

    /// An app without scenes has its scene attached before it finishes launching.
    func testAppWithoutScenesLaunchedInTheBackgroundIsNotVisible() {
        let state = AppStateProvider.appState(for: .background,
                                              hasAttachedScene: true,
                                              backgroundTimeRemaining: 30,
                                              hasForegroundTaskRole: false)

        XCTAssertEqual(state, .background)
    }

    func testForegroundStatesAreMappedUnchanged() {
        XCTAssertEqual(AppStateProvider.appState(for: .active,
                                                 hasAttachedScene: true,
                                                 backgroundTimeRemaining: .greatestFiniteMagnitude,
                                                 hasForegroundTaskRole: true),
                       .active)
        XCTAssertEqual(AppStateProvider.appState(for: .inactive,
                                                 hasAttachedScene: true,
                                                 backgroundTimeRemaining: .greatestFiniteMagnitude,
                                                 hasForegroundTaskRole: true),
                       .inactive)
    }

    /// A process launched into the background and then opened by the user goes straight to `didBecomeActive`
    /// without a `willEnterForeground`.
    func testIsVisibleWhenABackgroundLaunchedAppIsOpened() {
        simulateAppState(.background)
        XCTAssertFalse(AppStateProvider.isVisible)

        AppStateProvider.observer.didBecomeActive()

        XCTAssertTrue(AppStateProvider.isVisible)
    }
#endif

    func testReadsTheAppStateFromOutsideTheMainThread() {
        AppStateProvider.appStateGenerator = { .background }

        let initialized = expectation(description: "App state read outside the main thread")
        DispatchQueue.global(qos: .default).async {
            AppStateProvider.ensureInitialized()
            initialized.fulfill()
        }
        wait(for: [initialized], timeout: 10)

        XCTAssertFalse(AppStateProvider.isVisible)
    }

    func testCreatesTrackerFromOutsideTheMainThread() {
        AppStateProvider.appStateGenerator = { .background }

        let created = expectation(description: "Tracker created outside the main thread")
        DispatchQueue.global(qos: .default).async {
            let networkConfig = NetworkConfiguration(
                networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
            let tracker = Snowplow.createTracker(namespace: "testAppStateOffMainThread",
                                                 network: networkConfig)
            XCTAssertTrue(tracker.session?.isInBackground ?? false)
            created.fulfill()
        }
        wait(for: [created], timeout: 10)
    }

    func testSessionControllerReportsBackgroundOnABackgroundLaunch() {
        // The tracker entry point seeds the state itself, so no explicit initialization here.
        AppStateProvider.appStateGenerator = { .background }

        let networkConfig = NetworkConfiguration(
            networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let tracker = Snowplow.createTracker(namespace: "testAppStateBackgroundLaunch",
                                             network: networkConfig)

        XCTAssertTrue(tracker.session?.isInBackground ?? false)
    }

    /// The behaviour reported by the customer: a screen view tracked by a process that was launched into the
    /// background – with screen view autotracking off – must not claim the app was visible.
    func testScreenViewOnABackgroundLaunchIsNotVisible() {
        AppStateProvider.appStateGenerator = { .background }

        let expectScreenView = expectation(description: "Screen view event")
        let eventSink = EventSink { event in
            if event.schema == kSPScreenViewSchema {
                let entity = event.entities.first { $0.schema == kSPLifecycleEntitySchema }
                XCTAssertEqual(entity?.data["isVisible"] as? Bool, false)
                expectScreenView.fulfill()
            }
        }

        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.screenViewAutotracking = false
        let networkConfig = NetworkConfiguration(
            networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let tracker = Snowplow.createTracker(namespace: "testAppStateBackgroundScreenView",
                                             network: networkConfig,
                                             configurations: [eventSink, trackerConfig])

        _ = tracker.track(ScreenView(name: "teams_home"))

        wait(for: [expectScreenView], timeout: 10)
    }

    func testSessionControllerReportsForegroundOnANormalLaunch() {
        AppStateProvider.appStateGenerator = { .active }

        let networkConfig = NetworkConfiguration(
            networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let tracker = Snowplow.createTracker(namespace: "testAppStateForegroundLaunch",
                                             network: networkConfig)

        XCTAssertFalse(tracker.session?.isInBackground ?? true)
    }
}
