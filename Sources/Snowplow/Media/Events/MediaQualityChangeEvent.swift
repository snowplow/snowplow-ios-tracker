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
 Media player event tracked when the video playback quality changes.
 */
@objc(SPMediaQualityChangeEvent)
public class MediaQualityChangeEvent: SelfDescribingAbstract, MediaPlayerUpdatingEvent {
    
    /// Quality level before the change (e.g., 1080p).
    /// If not set, the previous quality is taken from the last setting in media player.
    @objc
    public var previousQuality: String?
    
    /// Quality level after the change (e.g., 1080p).
    @objc
    public var newQuality: String?
    
    /// The current bitrate in bits per second.
    public var bitrate: Int?
    
    /// The current number of frames per second.
    public var framesPerSecond: Int?
    
    /// Whether the change was automatic or triggered by the user.
    public var automatic: Bool?
    
    override var schema: String {
        return MediaSchemata.eventSchema("quality_change")
    }
    
    override var payload: [String : Any] {
        var data: [String : Any] = [:]
        if let previousQuality = previousQuality { data["previousQuality"] = previousQuality }
        if let newQuality = newQuality { data["newQuality"] = newQuality }
        if let bitrate = bitrate { data["bitrate"] = bitrate }
        if let framesPerSecond = framesPerSecond { data["framesPerSecond"] = framesPerSecond }
        if let automatic = automatic { data["automatic"] = automatic }
        return data
    }
    
    /// - Parameter previousQuality: Quality level before the change (e.g., 1080p).
    /// - Parameter newQuality: Quality level after the change (e.g., 1080p).
    /// - Parameter bitrate: The current bitrate in bits per second.
    /// - Parameter framesPerSecond: The current number of frames per second.
    /// - Parameter automatic: Whether the change was automatic or triggered by the user.
    public init(previousQuality: String? = nil,
                newQuality: String? = nil,
                bitrate: Int? = nil,
                framesPerSecond: Int? = nil,
                automatic: Bool? = nil) {
        self.previousQuality = previousQuality
        self.newQuality = newQuality
        self.bitrate = bitrate
        self.framesPerSecond = framesPerSecond
        self.automatic = automatic
    }
    
    @objc
    public override init() {
    }
    
    /// Quality level before the change (e.g., 1080p).
    /// If not set, the previous quality is taken from the last setting in media player.
    @objc
    public func previousQuality(_ previousQuality: String?) -> Self {
        self.previousQuality = previousQuality
        return self
    }
    
    /// Quality level after the change (e.g., 1080p).
    @objc
    public func newQuality(_ newQuality: String?) -> Self {
        self.newQuality = newQuality
        return self
    }
    
    /// The current bitrate in bits per second.
    @objc
    public func bitrate(_ bitrate: Int) -> Self {
        self.bitrate = bitrate
        return self
    }
    
    /// The current number of frames per second.
    @objc
    public func framesPerSecond(_ fps: Int) -> Self {
        self.framesPerSecond = fps
        return self
    }
    
    /// Whether the change was automatic or triggered by the user.
    @objc
    public func automatic(_ automatic: Bool) -> Self {
        self.automatic = automatic
        return self
    }
    
    func update(player: MediaPlayerEntity) {
        if previousQuality == nil {
            if let quality = player.quality {
                previousQuality = quality
            }
        }
        player.quality = newQuality
    }
}
