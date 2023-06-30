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
#if !os(watchOS)
import AVKit
#endif

/**
 Controller for managing media tracking instances and tracking media events.
 */
@objc(SPMediaController)
public protocol MediaController {
    
    /// Starts media tracking for a single media content tracked in a media player.
    ///
    /// - Parameter id: Unique identifier for the media tracking instance. The same ID will be used for media player session if enabled.
    @objc
    func startMediaTracking(id: String) -> MediaTracking
    
    /// Starts media tracking for a single media content tracked in a media player.
    ///
    /// - Parameter id: Unique identifier for the media tracking instance. The same ID will be used for media player session if enabled.
    /// - Parameter media: Attributes for the media player context entity
    @objc
    func startMediaTracking(id: String, player: MediaPlayerEntity?) -> MediaTracking
    
    /// Starts media tracking for a single media content tracked in a media player.
    ///
    /// - Parameter configuration: Configuration of the media tracking instance.
    @objc
    func startMediaTracking(configuration: MediaTrackingConfiguration) -> MediaTracking
    
#if !os(watchOS)
    /// Starts tracking media events from a given AVPlayer instance.
    ///
    /// - Parameter player: AVPlayer instance of the player to track events from.
    /// - Parameter configuration: Configuration of the media tracking instance.
    @objc
    func startMediaTracking(player: AVPlayer, configuration: MediaTrackingConfiguration) -> MediaTracking
#endif
    
    /// Returns a media tracking instance for the given ID.
    ///
    /// - Parameter id: Unique identifier for the media tracking instance.
    @objc
    func mediaTracking(id: String) -> MediaTracking?
    
    /// Ends autotracked events and cleans the media tracking instance.
    ///
    /// - Parameter id: Unique identifier for the media tracking instance.
    @objc
    func endMediaTracking(id: String)
}
