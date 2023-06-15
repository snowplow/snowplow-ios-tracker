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

class MediaSessionTracking {
    
    private var session: MediaSessionEntity
    private var stats: MediaSessionTrackingStats
    
    var entity: SelfDescribingJson {
        return session.entity(stats: stats)
    }
    
    init(id: String,
         startedAt: Date? = nil,
         pingInterval: Int? = nil,
         dateGenerator: @escaping () -> Date = Date.init) {
        session = MediaSessionEntity(id: id,
                               startedAt: startedAt,
                               pingInterval: pingInterval)
        stats = MediaSessionTrackingStats(session: session,
                                          dateGenerator: dateGenerator)
    }
    
    func update(event: Event?, player: MediaPlayerEntity, adBreak: MediaAdBreakEntity?) {
        stats.update(event: event, player: player, adBreak: adBreak)
    }
}
