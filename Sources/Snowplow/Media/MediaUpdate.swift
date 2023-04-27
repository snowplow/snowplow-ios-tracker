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
 Properties for the media player context entity attached to media events.
 Entity schema: `iglu:com.snowplowanalytics.snowplow/media_player/jsonschema/1-0-0`
 */
@objc(SPMediaUpdate)
public class MediaUpdate: NSObject {
    /// The current playback time
    public var currentTime: Double?
    /// A double-precision floating-point value indicating the duration of the media in seconds
    public var duration: Double?
    /// If playback of the media has ended
    public var ended: Bool?
    /// If the media is live
    public var isLive: Bool?
    /// If the video should restart after ending
    public var loop: Bool?
    /// If the media element is muted
    public var muted: Bool?
    /// If the media element is paused
    public var paused: Bool?
    /// The percent of the way through the media" (0 to 100)
    /// It is automatically set by the tracker based on the `currentTime` and `duration` properties.
    public var percentProgress: Int? {
        if let duration = self.duration {
            return Int((currentTime ?? 0.0) / duration * 100)
        }
        return nil
    }
    /// Playback rate (1 is normal)
    public var playbackRate: Double?
    /// Volume percent (0 to 100)
    public var volume: Int?
    
    internal var entity: SelfDescribingJson {
        let data: [String : Any] = [
            "currentTime": currentTime ?? 0.0,
            "ended": ended ?? false,
            "paused": paused ?? true,
            "duration": duration as Any,
            "isLive": isLive ?? false,
            "loop": loop ?? false,
            "muted": muted ?? false,
            "percentProgress": percentProgress as Any,
            "playbackRate": playbackRate ?? 1.0,
            "volume": volume ?? 100
        ]
        
        return SelfDescribingJson(
            schema: "iglu:com.snowplowanalytics.snowplow/media_player/jsonschema/1-0-0",
            andData: data)
    }
    
    @objc
    public override init() {
    }
   
    /// - Parameter currentTime: The current playback time
    /// - Parameter duration: A double-precision floating-point value indicating the duration of the media in seconds
    /// - Parameter ended: If playback of the media has ended
    /// - Parameter isLive: If the media is live
    /// - Parameter loop: If the video should restart after ending
    /// - Parameter muted: If the media element is muted
    /// - Parameter paused: If the media element is paused
    /// - Parameter playbackRate: Playback rate (1 is normal)
    /// - Parameter volume: Volume percent (0 to 100)
    public init(currentTime: Double? = nil,
                duration: Double? = nil,
                ended: Bool? = nil,
                isLive: Bool? = nil,
                loop: Bool? = nil,
                muted: Bool? = nil,
                paused: Bool? = nil,
                playbackRate: Double? = nil,
                volume: Int? = nil) {
        self.currentTime = currentTime
        self.duration = duration
        self.ended = ended
        self.isLive = isLive
        self.loop = loop
        self.muted = muted
        self.paused = paused
        self.playbackRate = playbackRate
        self.volume = volume
    }
    
#if !os(watchOS)
    /// - Parameter player: AVPlayer instance to load current playback properties from.
    @objc
    public convenience init(player: AVPlayer) {
        let currentTime = player.currentTime()
        self.init(
            currentTime: currentTime.seconds,
            muted: player.isMuted,
            paused: player.rate == 0,
            playbackRate: Double(player.rate),
            volume: Int(player.volume * 100)
        )
        if let currentItem = player.currentItem {
            duration = currentItem.duration.isIndefinite ? nil : currentItem.duration.seconds
            ended = (
                currentItem.duration.isIndefinite ?
                false : currentTime == currentItem.duration
            )
            isLive = player.status == .readyToPlay && currentItem.duration.isIndefinite
        }
    }
#endif
    
    /// The current playback time
    @objc
    public func currentTime(_ currentTime: Double) -> Self {
        self.currentTime = currentTime
        return self
    }
    
    /// A double-precision floating-point value indicating the duration of the media in seconds
    @objc
    public func duration(_ duration: Double) -> Self {
        self.duration = duration
        return self
    }
    
    /// If playback of the media has ended
    @objc
    public func ended(_ ended: Bool) -> Self {
        self.ended = ended
        return self
    }
    
    /// If the media is live
    @objc
    public func isLive(_ isLive: Bool) -> Self {
        self.isLive = isLive
        return self
    }
    
    /// If the video should restart after ending
    @objc
    public func loop(_ loop: Bool) -> Self {
        self.loop = loop
        return self
    }
    
    /// If the media element is muted
    @objc
    public func muted(_ muted: Bool) -> Self {
        self.muted = muted
        return self
    }
    
    /// If the media element is paused
    @objc
    public func paused(_ paused: Bool) -> Self {
        self.paused = paused
        return self
    }
    
    /// Playback rate (1 is normal)
    @objc
    public func playbackRate(_ playbackRate: Double) -> Self {
        self.playbackRate = playbackRate
        return self
    }
    
    /// Volume percent (0 to 100)
    @objc
    public func volume(_ volume: Int) -> Self {
        self.volume = volume
        return self
    }
    
    func update(from mediaPlayer: MediaUpdate) {
        if let duration = mediaPlayer.duration { self.duration = duration }
        if let currentTime = mediaPlayer.currentTime { self.currentTime = currentTime }
        if let ended = mediaPlayer.ended { self.ended = ended }
        if let isLive = mediaPlayer.isLive { self.isLive = isLive }
        if let loop = mediaPlayer.loop { self.loop = loop }
        if let muted = mediaPlayer.muted { self.muted = muted }
        if let paused = mediaPlayer.paused { self.paused = paused }
        if let playbackRate = mediaPlayer.playbackRate { self.playbackRate = playbackRate }
        if let volume = mediaPlayer.volume { self.volume = volume }
    }
    
    func update(with eventType: MediaEventType) {
        switch (eventType) {
        case .play:
            self.paused = false
        case .pause:
            self.paused = true
        case .end:
            self.paused = true
            self.ended = true
        default:
            break
        }
    }
}
