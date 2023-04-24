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

/// State of retrieved remote configuration that states where the configuration was retrieved from.
@objc(SPMediaAdBreakType)
public enum MediaAdBreakType: Int {
    /// take full control of the video for a period of time
    case linear
    /// run concurrently to the video
    case nonLinear
    /// Accompany the video but placed outside the player
    case companion
}

/**
 Properties for the ad break context entity attached to media events during ad break playback.
 Entity schema: `iglu:com.snowplowanalytics.snowplow/media_player_ad_break/jsonschema/1-0-0`
 */
@objc(SPMediaAdBreakUpdate)
public class MediaAdBreakUpdate: NSObject {
    /// Ad break name (e.g., pre-roll, mid-roll, and post-roll)
    public var name: String?
    /// An identifier for the ad break
    public var breakId: String?
    /// Playback time in seconds at the start of the ad break.
    public var startTime: Double?
    /// Type of ads within the break
    public var breakType: MediaAdBreakType?
    
    internal var entity: SelfDescribingJson {
        return SelfDescribingJson(schema: "", andData: [:])
    }
    
    @objc
    public override init() {
    }
    
    /// - Parameter name: Ad break name (e.g., pre-roll, mid-roll, and post-roll)
    /// - Parameter breakId: An identifier for the ad break
    /// - Parameter breakType: Type of ads within the break
    public init(name: String? = nil,
                breakId: String? = nil,
                breakType: MediaAdBreakType? = nil) {
        self.name = name
        self.breakId = breakId
        self.breakType = breakType
    }
    
    /// Ad break name (e.g., pre-roll, mid-roll, and post-roll)
    @objc
    public func name(_ name: String?) -> Self {
        self.name = name
        return self
    }
    
    /// An identifier for the ad break
    @objc
    public func breakId(_ breakId: String?) {
        self.breakId = breakId
    }
    
    /// Type of ads within the break
    public func breakType(_ breakType: MediaAdBreakType) {
        self.breakType = breakType
    }
    
    func update(from adBreak: MediaAdBreakUpdate, mediaPlayer: MediaUpdate) {
        if let name = adBreak.name { self.name = name }
        if let breakId = adBreak.breakId { self.breakId = breakId }
        if let breakType = adBreak.breakType { self.breakType = breakType }
        
        if startTime == nil { startTime = mediaPlayer.currentTime ?? 0 }
    }
}
