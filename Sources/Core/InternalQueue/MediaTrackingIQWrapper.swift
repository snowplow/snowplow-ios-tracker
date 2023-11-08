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

class MediaTrackingIQWrapper: MediaTracking {
    
    private let tracking: MediaTracking
    
    init(tracking: MediaTracking) {
        self.tracking = tracking
    }
    
    var id: String {
        return InternalQueue.sync { tracking.id }
    }
    
    // MARK: Update methods overloads
    
    func update(player: MediaPlayerEntity?) {
        return InternalQueue.sync { tracking.update(player: player) }
    }
    
    func update(player: MediaPlayerEntity?, ad: MediaAdEntity?, adBreak: MediaAdBreakEntity?) {
        return InternalQueue.sync { tracking.update(player: player, ad: ad, adBreak: adBreak) }
    }
    
    // MARK: Track methods overloads
    
    func track(_ event: Event) {
        InternalQueue.sync { tracking.track(event) }
    }
    
    func track(_ event: Event, player: MediaPlayerEntity?) {
        InternalQueue.sync { tracking.track(event, player: player) }
    }
    
    func track(_ event: Event, ad: MediaAdEntity?) {
        InternalQueue.sync { tracking.track(event, ad: ad) }
    }
    
    func track(_ event: Event, player: MediaPlayerEntity?, ad: MediaAdEntity?) {
        InternalQueue.sync { tracking.track(event, player: player, ad: ad) }
    }
    
    func track(_ event: Event, adBreak: MediaAdBreakEntity?) {
        InternalQueue.sync { tracking.track(event, adBreak: adBreak) }
    }
    
    func track(_ event: Event, player: MediaPlayerEntity?, adBreak: MediaAdBreakEntity?) {
        InternalQueue.sync { tracking.track(event, player: player, adBreak: adBreak) }
    }
    
    func track(_ event: Event, player: MediaPlayerEntity?, ad: MediaAdEntity?, adBreak: MediaAdBreakEntity?) {
        InternalQueue.sync { tracking.track(event, player: player, ad: ad, adBreak: adBreak) }
    }
    
}
