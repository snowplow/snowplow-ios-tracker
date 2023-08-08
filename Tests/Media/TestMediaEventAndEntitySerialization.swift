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
        XCTAssertEqual(mediaSchema(name: "play_event"), MediaPlayEvent().schema)
        XCTAssertEqual(mediaSchema(name: "playback_rate_change_event"), MediaPlaybackRateChangeEvent(newRate: 1).schema)
        XCTAssertEqual(mediaSchema(name: "ready_event"), MediaReadyEvent().schema)
        XCTAssertEqual(mediaSchema(name: "ad_resume_event"), MediaAdResumeEvent().schema)
        
        XCTAssertEqual(mediaSchema(name: "ad_quartile_event"), MediaAdFirstQuartileEvent().schema)
        XCTAssertEqual(mediaSchema(name: "ad_quartile_event"), MediaAdMidpointEvent().schema)
        XCTAssertEqual(mediaSchema(name: "ad_quartile_event"), MediaAdThirdQuartileEvent().schema)
        XCTAssertEqual(mediaSchema(name: "ad_complete_event"), MediaAdCompleteEvent().schema)
    }
    
    func testBuildsEntityWithDefaultValuesForEmptyMediaPlayer() {
        let entity = MediaPlayerEntity().entity
        
        XCTAssertEqual(mediaPlayerSchema, entity.schema)
        XCTAssertEqual(0.0, entity.data["currentTime"] as? Double)
        XCTAssertEqual(true, entity.data["paused"] as? Bool)
        XCTAssertEqual(false, entity.data["ended"] as? Bool)
    }
    
    func testBuildsEntityForMediaPlayer() {
        let entity = MediaPlayerEntity(
            currentTime: 33.3,
            duration: 100,
            ended: true,
            fullscreen: true,
            livestream: true,
            label: "The Video",
            loop: true,
            mediaType: .video,
            muted: true,
            paused: false,
            pictureInPicture: false,
            playerType: "AVPlayer",
            playbackRate: 2.5,
            quality: "1080p",
            volume: 80
        ).entity
        
        XCTAssertEqual(mediaPlayerSchema, entity.schema)
        XCTAssertEqual(33.3, entity.data["currentTime"] as? Double)
        XCTAssertEqual(false, entity.data["paused"] as? Bool)
        XCTAssertEqual(true, entity.data["fullscreen"] as? Bool)
        XCTAssertEqual(true, entity.data["livestream"] as? Bool)
        XCTAssertEqual("The Video", entity.data["label"] as? String)
        XCTAssertEqual(true, entity.data["loop"] as? Bool)
        XCTAssertEqual("video", entity.data["mediaType"] as? String)
        XCTAssertEqual(true, entity.data["muted"] as? Bool)
        XCTAssertEqual(100.0, entity.data["duration"] as? Double)
        XCTAssertEqual(80, entity.data["volume"] as? Int)
        XCTAssertEqual(2.5, entity.data["playbackRate"] as? Double)
        XCTAssertEqual(false, entity.data["pictureInPicture"] as? Bool)
        XCTAssertEqual("AVPlayer", entity.data["playerType"] as? String)
        XCTAssertEqual("1080p", entity.data["quality"] as? String)
    }
    
    func testBuildsMediaSessionEntity() {
        let date = Date()
        let timeTraveler = TimeTraveler()
        let session = MediaSessionEntity(id: "xxx", startedAt: date, pingInterval: 13)
        let stats = MediaSessionTrackingStats(session: session, dateGenerator: timeTraveler.generateDate)
        
        stats.update(event: MediaPlayEvent(), player: MediaPlayerEntity().currentTime(0).paused(false))
        timeTraveler.travel(by: 10)
        stats.update(event: MediaPauseEvent(), player: MediaPlayerEntity().currentTime(10).paused(true))
        
        let entity = session.entity(stats: stats)
        XCTAssertEqual(mediaSchema(name: "session"), entity.schema)
        XCTAssertEqual("xxx", entity.data["mediaSessionId"] as? String)
        XCTAssertEqual(13, entity.data["pingInterval"] as? Int)
        XCTAssertEqual(Utilities.dateToISOString(date), entity.data["startedAt"] as? String)
        XCTAssertEqual(10.0, entity.data["timePlayed"] as? Double)
        XCTAssertFalse(entity.data.keys.contains("timePaused"))
    }
    
    func testBuildsAdEntity() {
        let ad = MediaAdEntity(
            adId: "yyy",
            name: "Name",
            creativeId: "zzz",
            duration: 11.0,
            skippable: true
        )
        ad.podPosition = 2
        let entity = ad.entity
        
        XCTAssertEqual(mediaSchema(name: "ad"), entity.schema)
        XCTAssertEqual("Name", entity.data["name"] as? String)
        XCTAssertEqual("yyy", entity.data["adId"] as? String)
        XCTAssertEqual("zzz", entity.data["creativeId"] as? String)
        XCTAssertEqual(11.0, entity.data["duration"] as? Double)
        XCTAssertEqual(2, entity.data["podPosition"] as? Int)
        XCTAssertEqual(true, entity.data["skippable"] as? Bool)
    }
    
    func testBuildsAdBreakEntity() {
        let adBreak = MediaAdBreakEntity(breakId: "xxx",
                                         name: "Break 1",
                                         breakType: .nonLinear,
                                         podSize: 3)
        adBreak.startTime = 100.1
        let entity = adBreak.entity
        
        XCTAssertEqual(mediaSchema(name: "ad_break"), entity.schema)
        XCTAssertEqual("Break 1", entity.data["name"] as? String)
        XCTAssertEqual("xxx", entity.data["breakId"] as? String)
        XCTAssertEqual("nonlinear", entity.data["breakType"] as? String)
        XCTAssertEqual(3, entity.data["podSize"] as? Int)
        XCTAssertEqual(100.1, entity.data["startTime"] as? Double)
    }
    
    private func mediaSchema(name: String, version: String = "1-0-0") -> String {
        return "iglu:com.snowplowanalytics.snowplow.media/" + name + "/jsonschema/" + version
    }
    
    private var mediaPlayerSchema: String {
        return "iglu:com.snowplowanalytics.snowplow/media_player/jsonschema/2-0-0"
    }
}
