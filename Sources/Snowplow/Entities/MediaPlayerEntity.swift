//// Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
////
//// This program is licensed to you under the Apache License Version 2.0,
//// and you may not use this file except in compliance with the Apache License
//// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//// http://www.apache.org/licenses/LICENSE-2.0.
////
//// Unless required by applicable law or agreed to in writing,
//// software distributed under the Apache License Version 2.0 is distributed on
//// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//// express or implied. See the Apache License Version 2.0 for the specific
//// language governing permissions and limitations there under.
//
//import Foundation
//#if !os(watchOS)
//import AVKit
//#endif
//
//@objc(SPMediaPlayerEntity)
//public class MediaPlayerEntity: SelfDescribingJson {
//
//    /// The current playback time
//    @objc
//    public var currentTime: Double
//
//    /// A double-precision floating-point value indicating the duration of the media in seconds
//    public var duration: Double?
//
//    /// If playback of the media has ended
//    @objc
//    public var ended: Bool
//
//    /// If the media is live
//    @objc
//    public var isLive: Bool
//
//    /// If the video should restart after ending
//    @objc
//    public var loop: Bool
//
//    /// If the media element is muted
//    @objc
//    public var muted: Bool
//
//    /// If the media element is paused
//    @objc
//    public var paused: Bool
//
//    /// The percent of the way through the media" (0 to 100)
//    public var percentProgress: Int?
//
//    /// Playback rate (1 is normal)
//    @objc
//    public var playbackRate: Int
//
//    /// Volume percent (0 to 100)
//    @objc
//    public var volume: Int
//
//    @objc
//    public init(
//        currentTime: Double, // The current playback time
//        ended: Bool, // If playback of the media has ended
//        isLive: Bool = false, // If the media is live
//        loop: Bool = false, // If the video should restart after ending
//        muted: Bool = false, // If the media element is muted
//        paused: Bool, // If the media element is paused
//        playbackRate: Int = 1, // Playback rate (1 is normal)
//        volume: Int // Volume percent (0 to 100)
//    ) {
//        self.currentTime = currentTime
//        self.ended = ended
//        self.isLive = isLive
//        self.loop = loop
//        self.muted = muted
//        self.paused = paused
//        self.playbackRate = playbackRate
//        self.volume = volume
//
//        super.init(
//            schema: "iglu:com.snowplowanalytics.snowplow/media_player/jsonschema/1-0-0",
//            andData: [:]
//        )
//    }
//
//    @objc
//    public convenience init(
//        currentTime: Double, // The current playback time",
//        duration: Double, // A double-precision floating-point value indicating the duration of the media in seconds
//        ended: Bool, // If playback of the media has ended
//        isLive: Bool = false, // If the media is live
//        loop: Bool = false, // If the video should restart after ending
//        muted: Bool = false, // If the media element is muted
//        paused: Bool, // If the media element is paused
//        playbackRate: Int = 1, // Playback rate (1 is normal)
//        volume: Int // Volume percent (0 to 100)
//    ) {
//        self.init(
//            currentTime: currentTime,
//            ended: ended,
//            isLive: isLive,
//            loop: loop,
//            muted: muted,
//            paused: paused,
//            playbackRate: playbackRate,
//            volume: volume
//        )
//        self.duration = duration
//        self.percentProgress = Int(currentTime / duration * 100)
//    }
//
//#if !os(watchOS)
//    @objc
//    public convenience init?(
//        player: AVPlayer, /// AVPlayer instance
//        loop: Bool = false // If the video should restart after ending
//    ) {
//        if let currentItem = player.currentItem {
//            let currentTime = player.currentTime()
//            self.init(
//                currentTime: player.currentTime().seconds,
//                ended: currentItem.duration.isIndefinite ? false : player.currentTime() == currentItem.duration,
//                isLive: player.status == .readyToPlay && currentItem.duration.isIndefinite,
//                loop: loop,
//                muted: player.isMuted,
//                paused: player.rate == 0,
//                playbackRate: Int(player.rate),
//                volume: Int(player.volume * 100)
//            )
//            self.duration = currentItem.duration.isIndefinite ? nil : currentItem.duration.seconds
//            if let duration = self.duration {
//                self.percentProgress = Int(currentTime.seconds / duration * 100)
//            }
//        } else {
//            return nil
//        }
//    }
//#endif
//
//    @objc
//    override public var data: [String : Any] {
//        get {
//            var data: [String: Any] = [:]
//            data["currentTime"] = currentTime
//            data["duration"] = duration
//            data["ended"] = ended
//            data["isLive"] = isLive
//            data["loop"] = loop
//            data["muted"] = muted
//            data["paused"] = paused
//            data["percentProgress"] = percentProgress
//            data["playbackRate"] = playbackRate
//            data["volume"] = volume
//            return data
//        }
//        set {}
//    }
//
//}
