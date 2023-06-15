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
    
    /// Percentage boundaries of the video to track progress events at
    @objc
    public var boundaries: [Int]?
    
    /// List of context entities to track with media events
    @objc
    public var entities: [SelfDescribingJson]?
    
    /// Properties of the media player context entity attached to media events.
    @objc
    public var player: MediaPlayerEntity?
    
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
    public var captureEvents: [Event.Type]?
    
    /// - Parameter id: Unique identifier for the media tracking instance. The same ID is used for media player session if enabled.
    /// - Parameter pings: Whether to track media ping events. Defaults to true.
    /// - Parameter player: Properties of the media player context entity attached to media events.
    /// - Parameter session: Whether to track the media player session context entity along with media events.
    /// - Parameter entities: List of context entities to track with media events
    @objc
    public init(id: String,
                pings: Bool = true,
                player: MediaPlayerEntity? = nil,
                session: Bool = true,
                entities: [SelfDescribingJson]? = nil) {
        self.id = id
        self.player = player
        self.pings = pings
        self.entities = entities
        self.session = session
    }
    
    /// Percentage boundaries of the video to track progress events at
    @objc
    public func boundaries(_ boundaries: [Int]?) -> Self {
        self.boundaries = boundaries
        return self
    }
    
    /// List of context entities to track with media events
    @objc
    public func entities(_ entities: [SelfDescribingJson]?) -> Self {
        self.entities = entities
        return self
    }
    
    /// Properties of the media player context entity attached to media events.
    @objc
    public func player(_ player: MediaPlayerEntity?) -> Self {
        self.player = player
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
    public func captureEvents(_ captureEvents: [Event.Type]?) -> Self {
        self.captureEvents = captureEvents
        return self
    }
}
