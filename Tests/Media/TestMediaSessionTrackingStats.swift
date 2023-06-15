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

class TestMediaSessionTrackingStats: XCTestCase {
    
    var timeTraveler: TimeTraveler?
    var stats: MediaSessionTrackingStats?
    
    override func setUp() {
        timeTraveler = TimeTraveler()
        let session = MediaSessionEntity(id: "1")
        stats = MediaSessionTrackingStats(session: session,
                                          dateGenerator: timeTraveler!.generateDate)
    }
    
    func testCalculatesPlayedDuration() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaPlayEvent(), player: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(60))
        mediaPlayer.currentTime = 60
        stats.update(event: MediaEndEvent(), player: mediaPlayer)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(0, stats.timePlayedMuted)
        XCTAssertEqual(0, stats.timePaused)
        XCTAssertEqual(1, stats.avgPlaybackRate)
    }
    
    func testConsidersPauses() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaPlayEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(10))
        player.currentTime = 10
        stats.update(event: nil, player: player)
        player.paused = true
        stats.update(event: MediaPauseEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(10))
        player.paused = false
        stats.update(event: MediaPlayEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(50))
        player.currentTime = 60
        stats.update(event: MediaEndEvent(), player: player)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(0, stats.timePlayedMuted)
        XCTAssertEqual(10, stats.timePaused)
        XCTAssertEqual(1, stats.avgPlaybackRate)
    }
    
    func testCalculatesPlayOnMute() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaPlayEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 30
        player.muted = true
        stats.update(event: MediaVolumeChangeEvent(newVolume: 50), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 60
        stats.update(event: MediaEndEvent(), player: player)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(30, stats.timePlayedMuted)
        XCTAssertEqual(0, stats.timePaused)
        XCTAssertEqual(1, stats.avgPlaybackRate)
    }
    
    func testCalculatesAveragePlaybackRate() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaPlayEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 30
        player.playbackRate = 2
        stats.update(event: MediaPlaybackRateChangeEvent(newRate: 2), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 90
        stats.update(event: MediaEndEvent(), player: player)
        
        XCTAssertEqual(91, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(0, stats.timePlayedMuted)
        XCTAssertEqual(0, stats.timePaused)
        XCTAssertEqual(1.5, stats.avgPlaybackRate)
    }
    
    func testCalculatesStatsForLinearAds() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaPlayEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 30
        stats.update(event: MediaAdStartEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(5))
        stats.update(event: MediaAdClickEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(10))
        stats.update(event: MediaAdCompleteEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 60
        stats.update(event: MediaEndEvent(), player: player)
        
        XCTAssertEqual(15, stats.timeSpentAds)
        XCTAssertEqual(1, stats.ads)
        XCTAssertEqual(1, stats.adsClicked)
        XCTAssertEqual(0, stats.adBreaks)
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(0, stats.timePlayedMuted)
        XCTAssertEqual(0, stats.timePaused)
        XCTAssertEqual(1, stats.avgPlaybackRate)
    }
    
    func testCalculatesStatsForNonLinearAds() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        let adBreak = MediaAdBreakEntity(breakId: "1", breakType: .nonLinear)
        
        stats.update(event: MediaPlayEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 30
        stats.update(event: MediaAdBreakStartEvent(), player: player, adBreak: adBreak)
        stats.update(event: MediaAdStartEvent(), player: player, adBreak: adBreak)
        
        timeTraveler.travel(by: TimeInterval(15))
        player.currentTime = 45
        stats.update(event: MediaAdCompleteEvent(), player: player, adBreak: adBreak)
        stats.update(event: MediaAdBreakEndEvent(), player: player, adBreak: adBreak)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 75
        stats.update(event: MediaEndEvent(), player: player)
        
        XCTAssertEqual(15, stats.timeSpentAds)
        XCTAssertEqual(1, stats.ads)
        XCTAssertEqual(1, stats.adBreaks)
        XCTAssertEqual(76, stats.contentWatched)
        XCTAssertEqual(75, stats.timePlayed)
    }
    
    func testCountsRewatchedContentOnceInContentWatched() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaPlayEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 30
        stats.update(event: MediaSeekStartEvent(), player: player)
        player.currentTime = 15
        stats.update(event: MediaSeekEndEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(45))
        player.currentTime = 60
        stats.update(event: MediaEndEvent(), player: player)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(75, stats.timePlayed)
    }
    
    func testConsidersChangesInPingEvents() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaPlayEvent(), player: player)
        
        for i in (1..<60) {
            timeTraveler.travel(by: TimeInterval(1))
            player.currentTime = player.currentTime ?? 0 + 1
            player.muted = i % 2 == 1
            stats.update(event: nil, player: player)
        }
        
        timeTraveler.travel(by: TimeInterval(1))
        player.currentTime = 60
        stats.update(event: MediaEndEvent(), player: player)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(30, stats.timePlayedMuted)
    }
    
    func testCalculatesBufferingTime() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaBufferStartEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        stats.update(event: MediaBufferEndEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        player.currentTime = 30
        stats.update(event: nil, player: player)
        
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(30, stats.timeBuffering)
    }
    
    func testEndsBufferingWhenPlaybackTimeMoves() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let player = MediaPlayerEntity(paused: false)
        
        stats.update(event: MediaBufferStartEvent(), player: player)
        
        timeTraveler.travel(by: TimeInterval(30))
        stats.update(event: nil, player: player)
        
        timeTraveler.travel(by: TimeInterval(1))
        player.currentTime = 1
        stats.update(event: nil, player: player)
        
        timeTraveler.travel(by: TimeInterval(29))
        player.currentTime = 30.0
        stats.update(event: MediaEndEvent(), player: player)
        
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(31, stats.timeBuffering)
    }
}
