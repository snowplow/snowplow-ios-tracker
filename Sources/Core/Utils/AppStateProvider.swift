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
            // derives the same entity.
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

        switch state {
        case .active: return .active
        case .inactive: return .inactive
        case .background: return .background
        @unknown default: return .unknown
        }
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
