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

extension MediaAdBreakType {
    var value: String {
        switch self {
        case .linear:
            return "linear"
        case .nonLinear:
            return "nonlinear"
        case .companion:
            return "companion"
        }
    }
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
    public var breakId: String
    /// Playback time in seconds at the start of the ad break.
    public var startTime: Double?
    /// Type of ads within the break
    public var breakType: MediaAdBreakType?
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "breakId": breakId,
            "startTime": startTime ?? 0.0
        ]
        if let name = name { data["name"] = name }
        if let breakType = breakType { data["breakType"] = breakType.value }
        
        return SelfDescribingJson(
            schema: "iglu:com.snowplowanalytics.snowplow/media_player_ad_break/jsonschema/1-0-0",
            andData: data)

    }
    
    /// - Parameter breakId: An identifier for the ad break
    @objc
    public init(breakId: String) {
        self.breakId = breakId
    }
    
    /// - Parameter breakId: An identifier for the ad break
    /// - Parameter name: Ad break name (e.g., pre-roll, mid-roll, and post-roll)
    /// - Parameter breakType: Type of ads within the break
    public init(breakId: String,
                name: String? = nil,
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
    public func breakId(_ breakId: String) -> Self {
        self.breakId = breakId
        return self
    }
    
    /// Type of ads within the break
    public func breakType(_ breakType: MediaAdBreakType) -> Self {
        self.breakType = breakType
        return self
    }
    
    func update(adBreak: MediaAdBreakUpdate) {
        self.breakId = adBreak.breakId
        if let name = adBreak.name { self.name = name }
        if let breakType = adBreak.breakType { self.breakType = breakType }
    }
    
    func update(mediaPlayer: MediaUpdate) {
        if startTime == nil { startTime = mediaPlayer.currentTime ?? 0 }
    }
}
