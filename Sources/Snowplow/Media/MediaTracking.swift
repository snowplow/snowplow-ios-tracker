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
    
    /// A custom optional identifier tracked as the `label` property in media events.
    @objc
    var label: String? { get set }
    
    /// Updates stored attributes of the media player such as the current playback.
    /// Use this function to continually update the player attributes so that they can be sent in the background ping events.
    ///
    /// - Parameter media: Updates to the properties for the media player context entity attached to media events.
    @objc
    func update(media: MediaUpdate?)
    
    /// Updates stored attributes of the media player such as the current playback.
    /// Use this function to continually update the player attributes so that they can be sent in the background ping events.
    ///
    /// - Parameter media: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func update(media: MediaUpdate?,
                ad: MediaAdUpdate?,
                adBreak: MediaAdBreakUpdate?)
    
    ///  Tracks a media player event.
    ///
    /// - Parameter eventType: Type of the event to track.
    /// - Parameter media: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func track(_ eventType: MediaEventType)
    
    ///  Tracks a media player event.
    ///
    /// - Parameter media: Updates to the properties for the media player context entity attached to media events.
    @objc
    func track(_ eventType: MediaEventType,
               media: MediaUpdate?)
    
    ///  Tracks a media player event.
    ///
    /// - Parameter eventType: Type of the event to track.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    @objc
    func track(_ eventType: MediaEventType,
               ad: MediaAdUpdate?)
    
    ///  Tracks a media player event.
    ///
    /// - Parameter eventType: Type of the event to track.
    /// - Parameter media: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    @objc
    func track(_ eventType: MediaEventType,
               media: MediaUpdate?,
               ad: MediaAdUpdate?)
    
    ///  Tracks a media player event.
    ///
    /// - Parameter eventType: Type of the event to track.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func track(_ eventType: MediaEventType,
               adBreak: MediaAdBreakUpdate?)
    
    ///  Tracks a media player event.
    ///
    /// - Parameter eventType: Type of the event to track.
    /// - Parameter media: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func track(_ eventType: MediaEventType,
               media: MediaUpdate?,
               adBreak: MediaAdBreakUpdate?)
    
    ///  Tracks a media player event.
    ///
    /// - Parameter eventType: Type of the event to track.
    /// - Parameter media: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    func track(_ eventType: MediaEventType,
               media: MediaUpdate?,
               ad: MediaAdUpdate?,
               adBreak: MediaAdBreakUpdate?)
    
    ///  Tracks a media player event.
    ///
    /// - Parameter event: Media event properties
    @objc
    func track(event: MediaEvent)
}
