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

class MediaControllerImpl: Controller, MediaController {
    
    private var mediaTrackings: [String: MediaTrackingImpl] = [:]
#if !os(watchOS)
    private var playerSubscriptions: [String: AVPlayerSubscription] = [:]
#endif
    
    func startMediaTracking(id: String) -> MediaTracking {
        return startMediaTracking(id: id, player: nil)
    }
    
    func startMediaTracking(id: String, player: MediaPlayerEntity? = nil) -> MediaTracking {
        let configuration = MediaTrackingConfiguration(id: id, player: player)
        return startMediaTracking(configuration: configuration)
    }
    
    func startMediaTracking(configuration: MediaTrackingConfiguration) -> MediaTracking {
        let pingInterval = (
            configuration.pings ? MediaPingInterval(
                pingInterval: configuration.pingInterval,
                maxPausedPings: configuration.maxPausedPings
            ) : nil
        )
        
        let session = (
            configuration.session
            ? MediaSessionTracking(id: configuration.id,
                                   startedAt: nil,
                                   pingInterval: configuration.pingInterval)
            : nil
        )

        let mediaTracking = MediaTrackingImpl(id: configuration.id,
                                              tracker: serviceProvider.trackerController,
                                              player: configuration.player,
                                              session: session,
                                              pingInterval: pingInterval,
                                              boundaries: configuration.boundaries,
                                              captureEvents: configuration.captureEvents,
                                              entities: configuration.entities)
        
        mediaTrackings[configuration.id] = mediaTracking
        
        return mediaTracking
    }
    
#if !os(watchOS)
    func startMediaTracking(player: AVPlayer,
                            configuration: MediaTrackingConfiguration) -> MediaTracking {
        let tracking = startMediaTracking(configuration: configuration)
        
        let subscription = AVPlayerSubscription(player: player, mediaTracking: tracking)
        playerSubscriptions[configuration.id] = subscription
        
        return tracking
    }
#endif
    
    func mediaTracking(id: String) -> MediaTracking? {
        return mediaTrackings[id]
    }
    
    func endMediaTracking(id: String) {
#if !os(watchOS)
        if let subscription = playerSubscriptions[id] {
            subscription.unsubscribe()
            playerSubscriptions.removeValue(forKey: id)
        }
#endif
        
        if let tracking = mediaTrackings[id] {
            tracking.end()
            mediaTrackings.removeValue(forKey: id)
        }
    }
}
