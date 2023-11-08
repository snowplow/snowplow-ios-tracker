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

class MediaControllerIQWrapper: MediaController {
    
    private let controller: MediaController
    
    init(controller: MediaController) {
        self.controller = controller
    }
    
    func startMediaTracking(id: String) -> MediaTracking {
        return InternalQueue.sync {
            MediaTrackingIQWrapper(tracking: controller.startMediaTracking(id: id))
        }
    }
    
    func startMediaTracking(id: String, player: MediaPlayerEntity? = nil) -> MediaTracking {
        return InternalQueue.sync {
            MediaTrackingIQWrapper(tracking: controller.startMediaTracking(id: id, player: player))
        }
    }
    
    func startMediaTracking(configuration: MediaTrackingConfiguration) -> MediaTracking {
        return InternalQueue.sync {
            MediaTrackingIQWrapper(tracking: controller.startMediaTracking(configuration: configuration))
        }
    }
    
#if !os(watchOS)
    func startMediaTracking(player: AVPlayer,
                            configuration: MediaTrackingConfiguration) -> MediaTracking {
        return InternalQueue.sync { controller.startMediaTracking(player: player, configuration: configuration) }
    }
#endif
    
    func mediaTracking(id: String) -> MediaTracking? {
        return InternalQueue.sync { controller.mediaTracking(id: id) }
    }
    
    func endMediaTracking(id: String) {
        InternalQueue.sync { controller.endMediaTracking(id: id) }
    }
}
