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
 Media tracking instance with methods to track media events.
 */
@objc(SPMediaTracking)
public protocol MediaTracking {
    
    /// Unique identifier for the media tracking instance. The same ID is used for media player session if enabled.
    @objc
    var id: String { get }
    
    /// Updates stored attributes of the media player such as the current playback.
    /// Use this function to continually update the player attributes so that they can be sent in the background ping events.
    ///
    /// - Parameter player: Updates to the properties for the media player context entity attached to media events.
    @objc
    func update(player: MediaPlayer?)
    
    /// Updates stored attributes of the media player such as the current playback.
    /// Use this function to continually update the player attributes so that they can be sent in the background ping events.
    ///
    /// - Parameter player: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func update(player: MediaPlayer?, ad: MediaAd?, adBreak: MediaAdBreak?)
    
    ///  Tracks a media player event along with the media entities (e.g., player, session, ad).
    ///
    /// - Parameter event: Event to track.
    @objc
    func track(_ event: Event)
    
    ///  Tracks a media player event along with the media entities (e.g., player, session, ad).
    ///
    /// - Parameter event: Event to track.
    /// - Parameter player: Updates to the properties for the media player context entity attached to media events.
    @objc
    func track(_ event: Event, player: MediaPlayer?)
    
    ///  Tracks a media player event along with the media entities (e.g., player, session, ad).
    ///
    /// - Parameter event: Event to track.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    @objc
    func track(_ event: Event, ad: MediaAd?)
    
    ///  Tracks a media player event along with the media entities (e.g., player, session, ad).
    ///
    /// - Parameter event: Event to track.
    /// - Parameter player: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    @objc
    func track(_ event: Event, player: MediaPlayer?, ad: MediaAd?)
    
    ///  Tracks a media player event along with the media entities (e.g., player, session, ad).
    ///
    /// - Parameter event: Event to track.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func track(_ event: Event, adBreak: MediaAdBreak?)
    
    ///  Tracks a media player event along with the media entities (e.g., player, session, ad).
    ///
    /// - Parameter event: Event to track.
    /// - Parameter player: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func track(_ event: Event, player: MediaPlayer?, adBreak: MediaAdBreak?)
    
    ///  Tracks a media player event along with the media entities (e.g., player, session, ad).
    ///
    /// - Parameter event: Event to track.
    /// - Parameter player: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func track(_ event: Event, player: MediaPlayer?, ad: MediaAd?, adBreak: MediaAdBreak?)
}
