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
 Media player event sent when the playback rate has changed.
 */
@objc(SPMediaPlaybackRateChangeEvent)
public class MediaPlaybackRateChangeEvent: SelfDescribingAbstract, MediaPlayerUpdatingEvent {
    
    /// Playback rate before the change (1 is normal)
    /// If not set, the previous rate is taken from the last setting in media player.
    public var previousRate: Double?
    
    /// Playback rate after the change (1 is normal)
    @objc
    public var newRate: Double
    
    override var schema: String {
        return MediaSchemata.eventSchema("playback_rate_change")
    }
    
    override var payload: [String : Any] {
        var data: [String : Any] = ["newRate": newRate]
        if let previousRate = previousRate { data["previousRate"] = previousRate }
        return data
    }
    
    /// - Parameter previousRate: Playback rate before the change (1 is normal). If not set, it is taken from the last setting in media player.
    /// - Parameter newRate: Playback rate after the change (1 is normal)
    init(previousRate: Double? = nil, newRate: Double) {
        self.previousRate = previousRate
        self.newRate = newRate
    }
    
    /// - Parameter newRate: Playback rate after the change (1 is normal)
    @objc
    init(newRate: Double) {
        self.newRate = newRate
    }
    
    /// Playback rate before the change (1 is normal)
    /// If not set, the previous rate is taken from the last setting in media player.
    @objc
    public func previousRate(_ previousRate: Double) -> Self {
        self.previousRate = previousRate
        return self
    }
    
    /// Playback rate after the change (1 is normal)
    @objc
    public func newRate(_ newRate: Double) -> Self {
        self.newRate = newRate
        return self
    }
    
    func update(player: MediaPlayerEntity) {
        if previousRate == nil {
            if let previousRate = player.playbackRate {
                self.previousRate = previousRate
            }
        }
        player.playbackRate = newRate
    }
}
