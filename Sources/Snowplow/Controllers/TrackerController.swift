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

@objc(SPTrackerController)
public protocol TrackerController: TrackerConfigurationProtocol {
    /// Version of the tracker.
    @objc
    var version: String { get }
    /// Whether the tracker is running and able to collect/send events.
    /// See `pause()` and `resume()`.
    @objc
    var isTracking: Bool { get }
    /// Namespace of the tracker.
    /// It is used to identify the tracker among multiple trackers running in the same app.
    @objc
    var namespace: String { get }
    /// SubjectController.
    /// @apiNote Don't retain the reference. It may change on tracker reconfiguration.
    @objc
    var subject: SubjectController? { get }
    /// SessionController.
    /// @apiNote Don't retain the reference. It may change on tracker reconfiguration.
    @objc
    var session: SessionController? { get }
    /// NetworkController.
    /// @apiNote Don't retain the reference. It may change on tracker reconfiguration.
    @objc
    var network: NetworkController? { get }
    /// EmitterController.
    /// @apiNote Don't retain the reference. It may change on tracker reconfiguration.
    @objc
    var emitter: EmitterController? { get }
    /// GdprController.
    /// @apiNote Don't retain the reference. It may change on tracker reconfiguration.
    @objc
    var gdpr: GDPRController? { get }
    /// GlobalContextsController.
    /// @apiNote Don't retain the reference. It may change on tracker reconfiguration.
    @objc
    var globalContexts: GlobalContextsController? { get }
    /// PluginsController
    @objc
    var plugins: PluginsController { get }
    /// Media controller for managing media tracking instances and tracking media events.
    @objc
    var media: MediaController { get }
    /// Ecommerce controller for managing ecommerce entity addition.
    @objc
    var ecommerce: EcommerceController { get }
    /// Track the event.
    /// The tracker will take care to process and send the event assigning `event_id` and `device_timestamp`.
    /// - Parameter event: The event to track.
    /// - Returns: The event ID or nil in case tracking is paused
    @objc
    func track(_ event: Event) -> UUID?
    /// Pause the tracker.
    /// The tracker will stop any new activity tracking but it will continue to send remaining events
    /// already tracked but not sent yet.
    /// Calling a track method will not have any effect and event tracked will be lost.
    @objc
    func pause()
    /// Resume the tracker.
    /// The tracker will start tracking again.
    @objc
    func resume()
    /// Adds user and session information to a URL.
    ///
    /// For example, calling decorateLink on `appSchema://path/to/page` will return:
    ///
    ///      `appSchema://path/to/page?_sp=domainUserId.timestamp.sessionId..sourceId`
    ///
    /// Filled by this method:
    /// - `domainUserId`: Value of ``SessionController.userId``
    /// - `timestamp`: ms precision epoch timestamp
    /// - `sessionId`: Value of ``SessionController.sessionId``
    /// - `sourceId`: Value of ``Tracker.appId``
    ///
    /// - Parameter uri The URI to add the query string to
    ///
    /// - Returns Optional URL
    /// - nil if ``SnowplowTracker/SessionController/userId`` is null from `sessionContext(false)` being passed in ``TrackerConfiguration``
    /// - otherwise, decorated URL
    @objc
    func decorateLink(_ url: URL) -> URL?
    /// Adds user and session information to a URL.
    ///
    /// For example, calling decorateLink on `appSchema://path/to/page` with all extended parameters enabled will return:
    ///
    ///      `appSchema://path/to/page?_sp=domainUserId.timestamp.sessionId.subjectUserId.sourceId.platform.reason`
    ///
    /// - Parameter url The URL to add the query string to
    /// - Parameter extendedParameters Any optional parameters to include in the query string.
    ///
    /// - Returns Optional URL
    /// - nil if:
    ///
    ///     - ``SnowplowTracker/SessionController/userId`` is null from `sessionContext(false)` being passed in ``TrackerConfiguration``
    ///     - An enabled CrossDeviceParameter isn't set in the tracker
    /// - otherwise, decorated URL
    @objc
    func decorateLink(_ url: URL, extendedParameters: CrossDeviceParameterConfiguration) -> URL?
}
