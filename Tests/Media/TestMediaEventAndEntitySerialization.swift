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

import XCTest
@testable import SnowplowTracker

class TestMediaEventAndEntitySerialization: XCTestCase {
    
    func testSchemaForMediaEventTypes() {
        XCTAssertEqual(mediaSchema(name: "media_player_event_play"), MediaEventType.play.schema)
        XCTAssertEqual(mediaSchema(name: "media_player_event_playback_rate_change"), MediaEventType.playbackRateChange.schema)
        XCTAssertEqual(mediaSchema(name: "media_player_event_ready"), MediaEventType.ready.schema)
        XCTAssertEqual(mediaSchema(name: "media_player_event_ad_resume"), MediaEventType.adResume.schema)
        
        XCTAssertEqual(mediaSchema(name: "media_player_event_ad_quartile"), MediaEventType.adFirstQuartile.schema)
        XCTAssertEqual(mediaSchema(name: "media_player_event_ad_quartile"), MediaEventType.adMidpoint.schema)
        XCTAssertEqual(mediaSchema(name: "media_player_event_ad_quartile"), MediaEventType.adThirdQuartile.schema)
        XCTAssertEqual(mediaSchema(name: "media_player_event_ad_complete"), MediaEventType.adComplete.schema)
    }
    
    func testBuildsEntityWithDefaultValuesForEmptyMediaPlayer() {
        let entity = MediaUpdate().entity
        
        XCTAssertEqual(mediaSchema(name: "media_player"), entity.schema)
        XCTAssertEqual(0.0, entity.data["currentTime"] as? Double)
        XCTAssertEqual(true, entity.data["paused"] as? Bool)
        XCTAssertEqual(100, entity.data["volume"] as? Int)
    }
    
    func testBuildsEntityForMediaPlayer() {
        let entity = MediaUpdate(
            currentTime: 33.3,
            duration: 100,
            ended: true,
            isLive: true,
            loop: true,
            muted: true,
            paused: false,
            playbackRate: 2.5
        ).entity
        
        XCTAssertEqual(mediaSchema(name: "media_player"), entity.schema)
        XCTAssertEqual(33.3, entity.data["currentTime"] as? Double)
        XCTAssertEqual(false, entity.data["paused"] as? Bool)
        XCTAssertEqual(true, entity.data["isLive"] as? Bool)
        XCTAssertEqual(true, entity.data["loop"] as? Bool)
        XCTAssertEqual(true, entity.data["muted"] as? Bool)
        XCTAssertEqual(100.0, entity.data["duration"] as? Double)
        XCTAssertEqual(33, entity.data["percentProgress"] as? Int)
        XCTAssertEqual(100, entity.data["volume"] as? Int)
        XCTAssertEqual(2.5, entity.data["playbackRate"] as? Double)
    }
    
    func testBuildsMediaSessionEntity() {
        let date = Date()
        let timeTraveler = TimeTraveler()
        let session = MediaPlayerSession(id: "xxx", startedAt: date, pingInterval: 13)
        let stats = MediaSessionTrackingStats(session: session, dateGenerator: timeTraveler.generateDate)
        
        stats.update(eventType: .play, mediaPlayer: MediaUpdate().currentTime(0).paused(false))
        timeTraveler.travel(by: 10)
        stats.update(eventType: .pause, mediaPlayer: MediaUpdate().currentTime(10).paused(true))
        
        let entity = session.entity(stats: stats)
        XCTAssertEqual(mediaSchema(name: "media_player_session"), entity.schema)
        XCTAssertEqual("xxx", entity.data["mediaSessionId"] as? String)
        XCTAssertEqual(13, entity.data["pingInterval"] as? Int)
        XCTAssertEqual(Utilities.dateToISOString(date), entity.data["startedAt"] as? String)
        XCTAssertEqual(10.0, entity.data["timePlayed"] as? Double)
        XCTAssertFalse(entity.data.keys.contains("timePaused"))
    }
    
    func testBuildsAdEntity() {
        let ad = MediaAdUpdate(
            adId: "yyy",
            name: "Name",
            creativeId: "zzz",
            duration: 11.0,
            skippable: true
        )
        ad.podPosition = 2
        ad.percentProgress = 50
        let entity = ad.entity
        
        XCTAssertEqual(mediaSchema(name: "media_player_ad"), entity.schema)
        XCTAssertEqual("Name", entity.data["name"] as? String)
        XCTAssertEqual("yyy", entity.data["adId"] as? String)
        XCTAssertEqual("zzz", entity.data["creativeId"] as? String)
        XCTAssertEqual(11.0, entity.data["duration"] as? Double)
        XCTAssertEqual(50, entity.data["percentProgress"] as? Int)
        XCTAssertEqual(2, entity.data["podPosition"] as? Int)
        XCTAssertEqual(true, entity.data["skippable"] as? Bool)
    }
    
    func testBuildsAdBreakEntity() {
        let adBreak = MediaAdBreakUpdate(breakId: "xxx",
                                         name: "Break 1",
                                         breakType: .nonLinear)
        adBreak.startTime = 100.1
        let entity = adBreak.entity
        
        XCTAssertEqual(mediaSchema(name: "media_player_ad_break"), entity.schema)
        XCTAssertEqual("Break 1", entity.data["name"] as? String)
        XCTAssertEqual("xxx", entity.data["breakId"] as? String)
        XCTAssertEqual("nonlinear", entity.data["breakType"] as? String)
        XCTAssertEqual(100.1, entity.data["startTime"] as? Double)
    }
    
    private func mediaSchema(name: String, version: String = "1-0-0") -> String {
        return "iglu:com.snowplowanalytics.snowplow/" + name + "/jsonschema/" + version
    }
}
