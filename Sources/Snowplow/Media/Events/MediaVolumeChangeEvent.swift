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

/** Media player event sent when the volume has changed. */
@objc(SPMediaVolumeChangeEvent)
public class MediaVolumeChangeEvent: SelfDescribingAbstract, MediaPlayerUpdatingEvent {
    
    /// Volume percentage before the change.
    /// If not set, the previous volume is taken from the last setting in media player.
    public var previousVolume: Int?
    
    /// Volume percentage after the change.
    @objc
    public var newVolume: Int
    
    override var schema: String {
        return MediaSchemata.eventSchema("volume_change")
    }
    
    override var payload: [String : Any] {
        var data: [String : Any] = ["newVolume": newVolume]
        if let previousVolume = previousVolume { data["previousVolume"] = previousVolume }
        return data
    }
    
    /// - Parameter previousVolume: Volume percentage after the change.
    /// - Parameter newVolume: Volume percentage before the change.
    public init(previousVolume: Int? = nil, newVolume: Int) {
        self.previousVolume = previousVolume
        self.newVolume = newVolume
    }
    
    /// - Parameter newVolume: Volume percentage before the change.
    @objc
    public init(newVolume: Int) {
        self.newVolume = newVolume
    }
    
    /// Volume percentage before the change.
    /// If not set, the previous volume is taken from the last setting in media player.
    @objc
    public func previousVolume(_ previousVolume: Int) -> Self {
        self.previousVolume = previousVolume
        return self
    }
    
    /// Volume percentage after the change.
    @objc
    public func newVolume(_ newVolume: Int) -> Self {
        self.newVolume = newVolume
        return self
    }
    
    func update(player: MediaPlayerEntity) {
        if previousVolume == nil {
            if let volume = player.volume {
                previousVolume = volume
            }
        }
        player.volume = newVolume
    }
}
