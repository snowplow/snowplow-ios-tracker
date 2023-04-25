// Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.

import Foundation
import AVKit

@objc(SPMediaPlayerEvent)
public class MediaPlayerEvent: SelfDescribingAbstract {

    /// The event fired by the media player
    @objc
    public var type: MediaEventType

    /// A custom identifier
    @objc
    public var label: String?

    @objc
    public init(
        type: MediaEventType, /// The event fired by the media player
        label: String? = nil /// A custom identifier
    ) {
        self.type = type
        self.label = label
    }

//#if !os(watchOS)
//
//    @objc
//    public convenience init?(
//        type: MediaEventType, /// The event fired by the media player
//        label: String? = nil, /// A custom identifier
//        player: AVPlayer /// AVPlayer instance
//    ) {
//        if let mediaPlayerEntity = MediaPlayerEntity(player: player) {
//            self.init(type: type, label: label, mediaPlayerEntity: mediaPlayerEntity)
//        } else {
//            return nil
//        }
//    }
//
//#endif

    override var schema: String {
        let schema = "iglu:com.snowplowanalytics.snowplow/media_player_event_%@/jsonschema/1-0-0"
        switch type {
        case .ready:
            return String(format: schema, "ready")
        case .play:
            return String(format: schema, "play")
        case .pause:
            return String(format: schema, "pause")
        case .end:
            return String(format: schema, "end")
        case .seekStart:
            return String(format: schema, "seek_start")
        case .seekEnd:
            return String(format: schema, "seek_end")
        case .playbackRateChange:
            return String(format: schema, "playback_rate_change")
        case .volumeChange:
            return String(format: schema, "volume_change")
        case .fullscreenChange:
            return String(format: schema, "fullscreen_change")
        case .pictureInPictureChange:
            return String(format: schema, "picture_in_picture_change")
        case .ping:
            return String(format: schema, "ping")
        case .percentProgress:
            return String(format: schema, "percent_progress")
        case .adBreakStart:
            return String(format: schema, "ad_break_start")
        case .adBreakEnd:
            return String(format: schema, "ad_break_end")
        case .adStart:
            return String(format: schema, "ad_start")
        case .adFirstQuartile:
            return String(format: schema, "ad_quartile")
        case .adMidpoint:
            return String(format: schema, "ad_quartile")
        case .adThirdQuartile:
            return String(format: schema, "ad_quartile")
        case .adComplete:
            return String(format: schema, "ad_complete")
        case .adSkip:
            return String(format: schema, "ad_skip")
        case .adClick:
            return String(format: schema, "ad_click")
        case .adPause:
            return String(format: schema, "ad_pause")
        case .adResume:
            return String(format: schema, "ad_resume")
        case .bufferStart:
            return String(format: schema, "buffer_start")
        case .bufferEnd:
            return String(format: schema, "buffer_end")
        case .qualityChange:
            return String(format: schema, "quality_change")
        case .userUpdateQuality:
            return String(format: schema, "user_update_quality")
        case .error:
            return String(format: schema, "error")
        }
    }

    override var payload: [String : Any] {
        var payload: [String : Any] = [:]
        if let label = self.label { payload["label"] = label }
        return payload
    }

    // MARK: - Builders

    /// Referrer URL, source of this deep-link.
    @objc
    public func type(_ type: MediaEventType) -> Self {
        self.type = type
        return self
    }

    /// A custom identifier
    @objc
    public func label(_ label: String?) -> Self {
        self.label = label
        return self
    }
}
