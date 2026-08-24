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
        // Subscribe before reading, so that a transition happening during the read can't be missed. The read
        // and the cache update below happen together, so a notification arriving in between can only be
        // applied after the seed, never overwritten by it.
        // Instantiating the observer subscribes it; `static let` guarantees that happens only once.
        _ = observer

        if readsAppStateOnMainThread && !Thread.isMainThread {
            DispatchQueue.main.sync { update(with: appStateGenerator()) }
        } else {
            update(with: appStateGenerator())
        }
    }

    // MARK: - Private

    private static let observer: AppStateProvider = {
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
    /// `UIApplication.applicationState` is main-thread only, so reading it off the main thread has to hop.
    private static let readsAppStateOnMainThread = true

    private static func currentAppState() -> AppState {
        // `UIApplication.shared` is unavailable to app extensions, so the shared instance and its state are
        // read through the Objective-C runtime, and skipped entirely when running inside an extension.
        if Bundle.main.bundleURL.pathExtension == "appex" { return .unknown }

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
        // The same notifications that make `Session` track the Foreground and Background events, so that the
        // seeded value and the tracked lifecycle events can't contradict each other.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        // `willResignActive` has already been sent by the time an app is inactive, so a tracker created in
        // that window would otherwise never learn that the app went on to the background.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didResignActive),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
#endif
    }

    @objc private func didResignActive() {
        AppStateProvider.setIsVisible(false)
    }

    @objc private func didBecomeActive() {
        AppStateProvider.setIsVisible(true)
    }
}
