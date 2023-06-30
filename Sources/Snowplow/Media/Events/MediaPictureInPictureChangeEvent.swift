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

/** Media player event fired immediately after the browser switches into or out of picture-in-picture mode. */
@objc(SPMediaPictureInPictureChangeEvent)
public class MediaPictureInPictureChangeEvent: SelfDescribingAbstract, MediaPlayerUpdatingEvent {
    
    /// Whether the video element is showing picture-in-picture after the change.
    @objc
    public var pictureInPicture: Bool
    
    override var schema: String {
        return MediaSchemata.eventSchema("picture_in_picture_change")
    }
    
    override var payload: [String : Any] {
        return ["pictureInPicture": pictureInPicture]
    }
    
    /// - Parameter pictureInPicture: Whether the video element is showing picture-in-picture after the change.
    @objc
    public init(pictureInPicture: Bool) {
        self.pictureInPicture = pictureInPicture
    }
    
    /// Whether the video element is showing picture-in-picture after the change.
    @objc
    public func pictureInPicture(_ pictureInPicture: Bool) -> Self {
        self.pictureInPicture = pictureInPicture
        return self
    }
    
    func update(player: MediaPlayerEntity) {
        player.pictureInPicture = pictureInPicture
    }
}
