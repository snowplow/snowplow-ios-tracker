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

/// Type of media content.
@objc(SPMediaType)
public enum MediaType: Int {
    /// Video content
    case video
    /// Audio content
    case audio
}

extension MediaType {
    var value: String {
        switch self {
        case .audio:
            return "audio"
        case .video:
            return "video"
        }
    }
}

/**
 Properties for the media player context entity attached to media events.
 Entity schema: `iglu:com.snowplowanalytics.snowplow/media_player/jsonschema/2-0-0`
 */
@objc(SPMediaPlayer)
public class MediaPlayerEntity: NSObject {
    /// The current playback time position within the media in seconds
    public var currentTime: Double?
    /// A double-precision floating-point value indicating the duration of the media in seconds
    public var duration: Double?
    /// If playback of the media has ended
    public var ended: Bool?
    /// Whether the video element is fullscreen
    public var fullscreen: Bool?
    /// Whether the media is a live stream
    public var livestream: Bool?
    /// Human readable name given to tracked media content.
    public var label: String?
    /// If the video should restart after ending
    public var loop: Bool?
    /// Type of media content.
    public var mediaType: MediaType?
    /// If the media element is muted
    public var muted: Bool?
    /// If the media element is paused
    public var paused: Bool?
    /// Whether the video element is showing picture-in-picture
    public var pictureInPicture: Bool?
    /// Type of the media player (e.g., com.youtube-youtube, com.vimeo-vimeo, org.whatwg-media_element)
    public var playerType: String?
    /// Playback rate (1 is normal)
    public var playbackRate: Double?
    /// Quality level of the playback (e.g., 1080p).
    public var quality: String?
    /// Volume percent (0 to 100)
    public var volume: Int?
    
    /// The percent of the way through the media" (0 to 100)
    var percentProgress: Int? {
        if let duration = self.duration {
            return Int((currentTime ?? 0.0) / duration * 100)
        }
        return nil
    }
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "currentTime": currentTime ?? 0.0,
            "ended": ended ?? false,
            "paused": paused ?? true,
        ]
        if let fullscreen = fullscreen { data["fullscreen"] = fullscreen }
        if let livestream = livestream { data["livestream"] = livestream }
        if let label = label { data["label"] = label }
        if let duration = duration { data["duration"] = duration }
        if let mediaType = mediaType { data["mediaType"] = mediaType.value }
        if let loop = loop { data["loop"] = loop }
        if let muted = muted { data["muted"] = muted }
        if let pictureInPicture = pictureInPicture { data["pictureInPicture"] = pictureInPicture }
        if let playerType = playerType { data["playerType"] = playerType }
        if let playbackRate = playbackRate { data["playbackRate"] = playbackRate }
        if let quality = quality { data["quality"] = quality }
        if let volume = volume { data["volume"] = volume }
        
        return SelfDescribingJson(schema: MediaSchemata.playerSchema, andData: data)
    }
    
    @objc
    public override init() {
    }
   
    /// - Parameter currentTime: The current playback time position within the media in seconds
    /// - Parameter duration: A double-precision floating-point value indicating the duration of the media in seconds
    /// - Parameter ended: If playback of the media has ended
    /// - Parameter fullscreen: Whether the video element is fullscreen
    /// - Parameter livestream: Whether the media is a live stream
    /// - Parameter label: Human readable name given to tracked media content
    /// - Parameter loop: If the video should restart after ending
    /// - Parameter mediaType: Type of media content
    /// - Parameter muted: If the media element is muted
    /// - Parameter paused: If the media element is paused
    /// - Parameter pictureInPicture: Whether the video element is showing picture-in-picture
    /// - Parameter playerType: Type of the media player (e.g., com.youtube-youtube, com.vimeo-vimeo, org.whatwg-media_element)
    /// - Parameter playbackRate: Playback rate (1 is normal)
    /// - Parameter quality: Quality level of the playback (e.g., 1080p)
    /// - Parameter volume: Volume percent (0 to 100)
    public init(currentTime: Double? = nil,
                duration: Double? = nil,
                ended: Bool? = nil,
                fullscreen: Bool? = nil,
                livestream: Bool? = nil,
                label: String? = nil,
                loop: Bool? = nil,
                mediaType: MediaType? = nil,
                muted: Bool? = nil,
                paused: Bool? = nil,
                pictureInPicture: Bool? = nil,
                playerType: String? = nil,
                playbackRate: Double? = nil,
                quality: String? = nil,
                volume: Int? = nil) {
        self.currentTime = currentTime
        self.duration = duration
        self.ended = ended
        self.fullscreen = fullscreen
        self.livestream = livestream
        self.label = label
        self.loop = loop
        self.mediaType = mediaType
        self.muted = muted
        self.pictureInPicture = pictureInPicture
        self.playerType = playerType
        self.paused = paused
        self.playbackRate = playbackRate
        self.quality = quality
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
            livestream = player.status == .readyToPlay && currentItem.duration.isIndefinite
        }
    }
#endif
    
    /// The current playback time position within the media in seconds
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
    
    /// Whether the video element is fullscreen
    @objc
    public func fullscreen(_ fullscreen: Bool) -> Self {
        self.fullscreen = fullscreen
        return self
    }
    
    /// Whether the media is a live stream
    @objc
    public func livestream(_ livestream: Bool) -> Self {
        self.livestream = livestream
        return self
    }
    
    /// Human readable name given to tracked media content.
    @objc
    public func label(_ label: String?) -> Self {
        self.label = label
        return self
    }
    
    /// If the video should restart after ending
    @objc
    public func loop(_ loop: Bool) -> Self {
        self.loop = loop
        return self
    }
    
    /// Type of media content.
    @objc
    public func mediaType(_ mediaType: MediaType) -> Self {
        self.mediaType = mediaType
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
    
    /// Whether the video element is showing picture-in-picture
    @objc
    public func pictureInPicture(_ pictureInPicture: Bool) -> Self {
        self.pictureInPicture = pictureInPicture
        return self
    }
    
    /// Type of the media player (e.g., com.youtube-youtube, com.vimeo-vimeo, org.whatwg-media_element)
    @objc
    public func playerType(_ playerType: String?) -> Self {
        self.playerType = playerType
        return self
    }
    
    /// Playback rate (1 is normal)
    @objc
    public func playbackRate(_ playbackRate: Double) -> Self {
        self.playbackRate = playbackRate
        return self
    }
    
    /// Quality level of the playback (e.g., 1080p).
    @objc
    public func quality(_ quality: String?) -> Self {
        self.quality = quality
        return self
    }

    
    /// Volume percent (0 to 100)
    @objc
    public func volume(_ volume: Int) -> Self {
        self.volume = volume
        return self
    }
    
    func update(from player: MediaPlayerEntity) {
        if let duration = player.duration { self.duration = duration }
        if let currentTime = player.currentTime { self.currentTime = currentTime }
        if let ended = player.ended { self.ended = ended }
        if let livestream = player.livestream { self.livestream = livestream }
        if let loop = player.loop { self.loop = loop }
        if let muted = player.muted { self.muted = muted }
        if let paused = player.paused { self.paused = paused }
        if let playbackRate = player.playbackRate { self.playbackRate = playbackRate }
        if let volume = player.volume { self.volume = volume }
        if let fullscreen = player.fullscreen { self.fullscreen = fullscreen }
        if let label = player.label { self.label = label }
        if let mediaType = player.mediaType { self.mediaType = mediaType }
        if let pictureInPicture = player.pictureInPicture { self.pictureInPicture = pictureInPicture }
        if let playerType = player.playerType { self.playerType = playerType }
        if let quality = player.quality { self.quality = quality }
    }
}
