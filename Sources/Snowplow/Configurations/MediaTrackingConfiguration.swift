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

/**
 Configuration for a `MediaTracking` instance.
 */
@objc(SPMediaTrackingConfiguration)
public class MediaTrackingConfiguration: NSObject {
    
    /// Unique identifier for the media tracking instance. The same ID is used for media player session if enabled.
    @objc
    public var id: String
    
    /// A custom optional identifier tracked as the `label` property in media events.
    @objc
    public var label: String? = nil
    
    /// Percentage boundaries of the video to track progress events at
    @objc
    public var boundaries: [Int]?
    
    /// List of context entities to track with events
    @objc
    public var entities: [SelfDescribingJson]?
    
    /// Properties of the media player context entity attached to media events.
    @objc
    public var media: MediaUpdate?
    
    /// Whether to track media ping events. Defaults to true.
    @objc
    public var pings = true
    
    /// Interval in seconds in which the media ping events are tracked. Defaults to 30 seconds unless `pings` are disabled.
    public var pingInterval: Int?
    
    /// Maximum number of consecutive ping events to send when playback is paused. Defaults to 1 unless`pings` are disabled.
    public var maxPausedPings: Int?
    
    /// Whether to track the media player session context entity along with media events.
    /// The session entity contain the `id` identifier as well as statistics about the media playback.
    public var session: Bool
    
    /// List of event types to allow tracking.
    /// If not specified (`nil`), all tracked events will be allowed and tracked.
    /// Otherwise, tracked event types not present in the list will be discarded.
    public var captureEvents: [MediaEventType]?
    
    /// - Parameter id: Unique identifier for the media tracking instance. The same ID is used for media player session if enabled.
    /// - Parameter label: A custom optional identifier tracked as the `label` property in media events.
    /// - Parameter pings: Whether to track media ping events. Defaults to true.
    /// - Parameter media: Properties of the media player context entity attached to media events.
    /// - Parameter session: Whether to track the media player session context entity along with media events.
    /// - Parameter entities: List of context entities to track with events
    @objc
    public init(id: String,
                label: String? = nil,
                pings: Bool = true,
                media: MediaUpdate? = nil,
                session: Bool = true,
                entities: [SelfDescribingJson]? = nil) {
        self.id = id
        self.label = label
        self.media = media
        self.pings = pings
        self.entities = entities
        self.session = session
    }
    
    /// A custom optional identifier tracked as the `label` property in media events.
    @objc
    public func label(_ label: String?) -> Self {
        self.label = label
        return self
    }
    
    /// Percentage boundaries of the video to track progress events at
    @objc
    public func boundaries(_ boundaries: [Int]?) -> Self {
        self.boundaries = boundaries
        return self
    }
    
    /// List of context entities to track with events
    @objc
    public func entities(_ entities: [SelfDescribingJson]?) -> Self {
        self.entities = entities
        return self
    }
    
    /// Properties of the media player context entity attached to media events.
    @objc
    public func media(_ media: MediaUpdate?) -> Self {
        self.media = media
        return self
    }
    
    /// Whether to track media ping events. Defaults to true.
    @objc
    public func pings(_ pings: Bool) -> Self {
        self.pings = pings
        return self
    }
    
    /// Interval in seconds in which the media ping events are tracked. Defaults to 30 seconds unless `pings` are disabled.
    @objc
    public func pingInterval(_ pingInterval: Int) -> Self {
        self.pingInterval = pingInterval
        return self
    }
    
    /// Whether to track the media player session context entity along with media events.
    /// The session entity contain the `id` identifier as well as statistics about the media playback.
    @objc
    public func session(_ session: Bool) -> Self {
        self.session = session
        return self
    }
    
    /// List of event types to allow tracking.
    /// If not specified (`nil`), all tracked events will be allowed and tracked.
    /// Otherwise, tracked event types not present in the list will be discarded.
    public func captureEvents(_ captureEvents: [MediaEventType]?) -> Self {
        self.captureEvents = captureEvents
        return self
    }
}
