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

class MediaSessionEntity {
    var id: String
    var startedAt: Date
    var pingInterval: Int?
    
    init(id: String, startedAt: Date? = nil, pingInterval: Int? = nil) {
        self.id = id
        self.startedAt = startedAt ?? Date()
        self.pingInterval = pingInterval
    }
    
    func entity(stats: MediaSessionTrackingStats) -> SelfDescribingJson {
        var data: [String : Any] = [
            "mediaSessionId": id,
        ]
        
        if stats.timePaused > 0 { data["timePaused"] = roundStat(stats.timePaused) }
        if stats.timePlayed > 0 { data["timePlayed"] = roundStat(stats.timePlayed) }
        if stats.timePlayedMuted > 0 { data["timePlayedMuted"] = roundStat(stats.timePlayedMuted) }
        if stats.timeSpentAds > 0 { data["timeSpentAds"] = roundStat(stats.timeSpentAds) }
        if stats.timeBuffering > 0 { data["timeBuffering"] = roundStat(stats.timeBuffering) }
        if stats.ads > 0 { data["ads"] = stats.ads }
        if stats.adBreaks > 0 { data["adBreaks"] = stats.adBreaks }
        if stats.adsSkipped > 0 { data["adsSkipped"] = stats.adsSkipped }
        if stats.adsClicked > 0 { data["adsClicked"] = stats.adsClicked }
        if stats.avgPlaybackRate != 1 { data["avgPlaybackRate"] = roundStat(stats.avgPlaybackRate) }
        if stats.contentWatched > 0 { data["contentWatched"] = stats.contentWatched }
        
        if let startedAt = Utilities.dateToISOString(startedAt) { data["startedAt"] = startedAt }
        if let pingInterval = pingInterval { data["pingInterval"] = pingInterval }
        
        return SelfDescribingJson(schema: MediaSchemata.sessionSchema, andData: data)
    }
    
    private func roundStat(_ value: Double) -> Double {
        return round(value * 1000) / 1000
    }
    
}
