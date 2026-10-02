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
#if os(iOS) || os(tvOS)
import UIKit
#endif

/// The visibility state of the app at the moment it was read.
enum AppState {
    /// The app is in the foreground and receiving events.
    case active
    /// The app is in the foreground but not receiving events, e.g. it is behind a system alert.
    case inactive
    /// The app is running in the background.
    case background
    /// The state can't be determined: platforms without lifecycle notifications, and app extensions.
    case unknown
}

/// Caches whether the app is currently visible to the user.
///
/// The tracker used to derive visibility exclusively from the `Foreground`/`Background` events it tracks
/// itself. Neither of those is tracked in a process that is launched straight into the background – a silent
/// push, a background fetch, a background URL session, a push-to-start Live Activity – so every event of such
/// a process was reported as visible. This provider seeds the visibility from the real app state instead.
///
/// The app state can only be read from the main thread, and the main thread synchronously waits on the
/// ``InternalQueue`` where events are tracked, so the read can't happen while tracking an event. Instead,
/// ``ensureInitialized()`` is called from the public tracker entry point on the caller's thread, before the
/// queue is entered, and lifecycle notifications keep the cached value up to date from then on.
class AppStateProvider: NSObject {

    /// Reads the current state of the app. Only ever called from the main thread.
    /// Overridable in tests, in the same way as `ScreenSummaryState.dateGenerator`.
    static var appStateGenerator = AppStateProvider.defaultAppStateGenerator

    static let defaultAppStateGenerator: () -> AppState = { AppStateProvider.currentAppState() }

    private static let lock = NSLock()
    private static var cachedIsVisible = true

    /// Whether the app was visible – in the foreground – the last time its state was known.
    ///
    /// Defaults to `true` where the state isn't readable, which is the behaviour the tracker had before the
    /// state was read at all.
    static var isVisible: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cachedIsVisible
    }

    /// Reads the app state and starts observing lifecycle notifications to keep the cached value up to date.
    ///
    /// Must be called from outside the ``InternalQueue``: it may hop to the main thread, and the main thread
    /// blocks on that queue in `InternalQueue.sync`.
    static func ensureInitialized() {
        // Subscribe before reading, so that a transition happening during the read isn't missed.
        // Instantiating the observer subscribes it; `static let` guarantees that happens only once.
        _ = observer

        // The read and the cache update happen in the same block, and UIKit delivers the lifecycle
        // notifications on the main thread, so on iOS and tvOS that block and the observer callbacks are
        // serialised against each other: the seed can't land on top of a newer notification. The lock below
        // only makes each individual write atomic; it does not by itself order the seed against a callback.

        if readsAppStateOnMainThread && !Thread.isMainThread {
            DispatchQueue.main.sync { update(with: appStateGenerator()) }
        } else {
            update(with: appStateGenerator())
        }
    }

    // MARK: - Private

    /// Not private so that tests can drive the lifecycle transitions on it directly. Subscribes for the
    /// lifetime of the process: app visibility outlives any individual tracker.
    static let observer: AppStateProvider = {
        let observer = AppStateProvider()
        observer.subscribeToLifecycleNotifications()
        return observer
    }()

    private static func update(with state: AppState) {
        switch state {
        case .active, .inactive:
            // An app is inactive, not active, while it is still launching into the foreground, so treating an
            // inactive app as not visible here would mark every normal launch as a background one. Only the
            // background state identifies a background launch; this matches how the React Native tracker
            // derives the same entity. A scene-based app that is launching into the foreground is reported as
            // inactive too, see `appState(for:hasAttachedScene:backgroundTimeRemaining:hasForegroundTaskRole:)`.
            setIsVisible(true)
        case .background:
            setIsVisible(false)
        case .unknown:
            // Fall back to the behaviour of the trackers that never read the state.
            setIsVisible(true)
        }
    }

    private static func setIsVisible(_ isVisible: Bool) {
        lock.lock()
        defer { lock.unlock() }
        cachedIsVisible = isVisible
    }

#if os(iOS) || os(tvOS)
    /// Whether the app is an extension, which has no shared `UIApplication` to read a state from.
    private static let isAppExtension = Bundle.main.bundleURL.pathExtension == "appex"

    /// `UIApplication.applicationState` is main-thread only, so reading it off the main thread has to hop.
    /// Extensions never read it at all, so they skip the hop rather than paying for a value that is always
    /// `.unknown`.
    private static let readsAppStateOnMainThread = !isAppExtension

    private static func currentAppState() -> AppState {
        // `UIApplication.shared` is unavailable to app extensions, so the shared instance and its state are
        // read through the Objective-C runtime, and skipped entirely when running inside an extension.
        if isAppExtension { return .unknown }

        let sharedApplication = NSSelectorFromString("sharedApplication")
        guard UIApplication.responds(to: sharedApplication),
              let application = UIApplication.perform(sharedApplication)?.takeUnretainedValue() as? NSObject,
              let rawState = (application.value(forKey: "applicationState") as? NSNumber)?.intValue,
              let state = UIApplication.State(rawValue: rawState) else {
            return .unknown
        }

        var hasAttachedScene = true
        if #available(iOS 13.0, tvOS 13.0, *) {
            let scenes = application.value(forKey: "connectedScenes") as? Set<UIScene> ?? []
            hasAttachedScene = scenes.contains { $0.activationState != .unattached }
        }
        let backgroundTimeRemaining = (application.value(forKey: "backgroundTimeRemaining") as? NSNumber)?
            .doubleValue ?? 0

        return appState(for: state,
                        hasAttachedScene: hasAttachedScene,
                        backgroundTimeRemaining: backgroundTimeRemaining,
                        hasForegroundTaskRole: hasForegroundTaskRole())
    }

    /// The system gives a process that runs in the background a limited time budget – about 30 seconds –
    /// and reports a practically unlimited one while the app is in the foreground. Anything above this is
    /// therefore not a background budget.
    static let unlimitedBackgroundTimeThreshold: TimeInterval = 24 * 60 * 60

    /// Maps the state UIKit reports to the app's visibility state.
    ///
    /// A scene-based app – every SwiftUI app, and every UIKit app created from the Xcode template since
    /// iOS 13 – is still in the background state when the user launches it, until its first scene is
    /// attached: in `application(_:didFinishLaunchingWithOptions:)` and in `scene(_:willConnectTo:options:)`.
    /// A background launch – a silent push, a background fetch, a location event – reads exactly the same
    /// there. What tells them apart is how the system classifies the process: the role it assigns to the
    /// task, and the background time budget it sets for one it started for background work. This is the iOS
    /// counterpart of the process importance the Android tracker reads in the same situation. An app without
    /// scenes has its scene attached before it finishes launching, and reports the inactive state for a launch
    /// into the foreground, so it never reaches that check.
    ///
    /// Both signals are required, because neither is conclusive on its own: the budget is also unlimited
    /// while an app runs in the background for location updates or audio, and both still read as foreground
    /// for a moment after a running app is moved to the background. They are only consulted before any scene
    /// is attached, which rules out the latter.
    static func appState(for state: UIApplication.State,
                         hasAttachedScene: Bool,
                         backgroundTimeRemaining: TimeInterval,
                         hasForegroundTaskRole: Bool) -> AppState {
        switch state {
        case .active: return .active
        case .inactive: return .inactive
        case .background:
            if !hasAttachedScene
                && hasForegroundTaskRole
                && backgroundTimeRemaining > unlimitedBackgroundTimeThreshold {
                // Launching into the foreground: UIKit moves the app to the inactive state as soon as its
                // scene is attached.
                return .inactive
            }
            return .background
        @unknown default: return .unknown
        }
    }

    /// Whether the system runs this process as the foreground application. A process launched for
    /// background work, or running in the background for location updates or audio, has a different role.
    /// Returns `false` if the role can't be read, which keeps the background state UIKit reported.
    private static func hasForegroundTaskRole() -> Bool {
#if os(tvOS)
        // The task role can't be read on tvOS. It's only needed to rule out a relaunch for background
        // location updates, the one background launch with an unlimited budget, and tvOS has no background
        // location. Background audio keeps a running app alive but doesn't launch one, and a running app
        // already has an attached scene.
        return true
#else
        var policy = task_category_policy_data_t(role: TASK_UNSPECIFIED)
        var count = mach_msg_type_number_t(
            MemoryLayout<task_category_policy_data_t>.size / MemoryLayout<integer_t>.size)
        var getDefault: boolean_t = 0
        let result = withUnsafeMutablePointer(to: &policy) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_policy_get(mach_task_self_, task_policy_flavor_t(TASK_CATEGORY_POLICY), $0, &count, &getDefault)
            }
        }
        return result == KERN_SUCCESS && policy.role == TASK_FOREGROUND_APPLICATION
#endif
    }
#else
    /// The state is never actually read on these platforms, so there is nothing to hop to the main thread
    /// for. Hopping anyway would deadlock a `createTracker` called off the main thread while the main thread
    /// waits on that same call.
    private static let readsAppStateOnMainThread = false

    private static func currentAppState() -> AppState {
        // AppKit and WatchKit don't have the lifecycle observers below, so a state read here would go stale
        // as soon as the app changed state. See the `Session` notification observers.
        return .unknown
    }
#endif

    private func subscribeToLifecycleNotifications() {
#if os(iOS) || os(tvOS)
        // Only `didEnterBackground` means the app actually left the screen. `willResignActive` is
        // deliberately NOT observed here: it also fires for interruptions that leave the app fully visible –
        // Control Center, an incoming call, a system alert, the app switcher preview – and treating those as
        // not visible would report `isVisible: false` for an app the user is looking at. That would also
        // contradict `update(with:)`, which maps the `.inactive` state those interruptions produce to
        // visible. `Session` keeps observing `willResignActive` for its own Background event, which is a
        // separate concern from whether the app is on screen.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        // `willEnterForeground` is the earliest point the app is back on screen; it arrives while the app is
        // still inactive, before `didBecomeActive`.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        // A process launched into the background and then opened goes straight to `didBecomeActive` without
        // a `willEnterForeground`, so this is the one that clears the seeded value in that case.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
#endif
    }

    // Not private so that tests can drive the transitions directly. Posting the real notifications in a test
    // would also reach every `Session` still alive in the test process, which would track stray Foreground
    // and Background events into other test cases' event sinks.
    @objc func didEnterBackground() {
        AppStateProvider.setIsVisible(false)
    }

    @objc func willEnterForeground() {
        AppStateProvider.setIsVisible(true)
    }

    @objc func didBecomeActive() {
        AppStateProvider.setIsVisible(true)
    }
}
