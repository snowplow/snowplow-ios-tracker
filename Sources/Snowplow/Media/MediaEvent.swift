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

/** Represents a media player event and it's related entities (media player, ad, ad break entities) */
@objc(SPMediaEvent)
public class MediaEvent: NSObject {
    
    /// Type of the event to track.
    @objc
    public var eventType: MediaEventType
    
    /// Updates to the properties for the media player context entity attached to media events.
    @objc
    public var media: MediaUpdate?
    
    /// Updates to the properties for the ad context entity attached to media events during ad playback.
    @objc
    public var ad: MediaAdUpdate?
    
    /// Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    public var adBreak: MediaAdBreakUpdate?
    
    /// Context entities to track with the event
    @objc
    public var entities: [SelfDescribingJson]?
    
    /// - Parameter eventType: Type of the event to track.
    /// - Parameter media: Updates to the properties for the media player context entity attached to media events.
    /// - Parameter ad: Updates to the properties for the ad context entity attached to media events during ad playback.
    /// - Parameter adBreak: Updates to the properties for the ad break context entity attached to media events during ad break playback.
    /// - Parameter entities: Context entities to track with the event.
    @objc
    public init(_ eventType: MediaEventType,
                media: MediaUpdate? = nil,
                ad: MediaAdUpdate? = nil,
                adBreak: MediaAdBreakUpdate? = nil,
                entities: [SelfDescribingJson]? = nil) {
        self.eventType = eventType
        self.media = media
        self.ad = ad
        self.adBreak = adBreak
        self.entities = entities
    }
    
    /// Updates to the properties for the media player context entity attached to media events.
    @objc
    public func media(_ media: MediaUpdate?) -> Self {
        self.media = media
        return self
    }
    
    /// Updates to the properties for the ad context entity attached to media events during ad playback.
    @objc
    public func ad(_ ad: MediaAdUpdate?) -> Self {
        self.ad = ad
        return self
    }
    
    /// Updates to the properties for the ad break context entity attached to media events during ad break playback.
    @objc
    public func adBreak(_ adBreak: MediaAdBreakUpdate?) -> Self {
        self.adBreak = adBreak
        return self
    }
    
    /// Context entities to track with the event
    @objc
    public func entities(_ entities: [SelfDescribingJson]?) -> Self {
        self.entities = entities
        return self
    }
}
