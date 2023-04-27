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
        let session = MediaPlayerSession(id: "1")
        stats = MediaSessionTrackingStats(session: session,
                                              dateGenerator: timeTraveler!.generateDate)
    }
    
    func testCalculatesPlayedDuration() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(60))
        mediaPlayer.currentTime = 60
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(0, stats.timePlayedMuted)
        XCTAssertEqual(0, stats.timePaused)
        XCTAssertEqual(1, stats.avgPlaybackRate)
    }
    
    func testConsidersPauses() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(10))
        mediaPlayer.currentTime = 10
        stats.update(eventType: nil, mediaPlayer: mediaPlayer)
        mediaPlayer.paused = true
        stats.update(eventType: .pause, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(10))
        mediaPlayer.paused = false
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(50))
        mediaPlayer.currentTime = 60
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(0, stats.timePlayedMuted)
        XCTAssertEqual(10, stats.timePaused)
        XCTAssertEqual(1, stats.avgPlaybackRate)
    }
    
    func testCalculatesPlayOnMute() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 30
        mediaPlayer.muted = true
        stats.update(eventType: .volumeChange, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 60
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(30, stats.timePlayedMuted)
        XCTAssertEqual(0, stats.timePaused)
        XCTAssertEqual(1, stats.avgPlaybackRate)
    }
    
    func testCalculatesAveragePlaybackRate() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 30
        mediaPlayer.playbackRate = 2
        stats.update(eventType: .playbackRateChange, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 90
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(91, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(0, stats.timePlayedMuted)
        XCTAssertEqual(0, stats.timePaused)
        XCTAssertEqual(1.5, stats.avgPlaybackRate)
    }
    
    func testCalculatesStatsForLinearAds() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 30
        stats.update(eventType: .adStart, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(5))
        stats.update(eventType: .adClick, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(10))
        stats.update(eventType: .adComplete, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 60
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
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
        let mediaPlayer = MediaUpdate(paused: false)
        let adBreak = MediaAdBreakUpdate(breakId: "1", breakType: .nonLinear)
        
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 30
        stats.update(eventType: .adBreakStart, mediaPlayer: mediaPlayer, adBreak: adBreak)
        stats.update(eventType: .adStart, mediaPlayer: mediaPlayer, adBreak: adBreak)
        
        timeTraveler.travel(by: TimeInterval(15))
        mediaPlayer.currentTime = 45
        stats.update(eventType: .adComplete, mediaPlayer: mediaPlayer, adBreak: adBreak)
        stats.update(eventType: .adBreakEnd, mediaPlayer: mediaPlayer, adBreak: adBreak)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 75
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(15, stats.timeSpentAds)
        XCTAssertEqual(1, stats.ads)
        XCTAssertEqual(1, stats.adBreaks)
        XCTAssertEqual(76, stats.contentWatched)
        XCTAssertEqual(75, stats.timePlayed)
    }
    
    func testCountsRewatchedContentOnceInContentWatched() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 30
        stats.update(eventType: .seekStart, mediaPlayer: mediaPlayer)
        mediaPlayer.currentTime = 15
        stats.update(eventType: .seekEnd, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(45))
        mediaPlayer.currentTime = 60
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(75, stats.timePlayed)
    }
    
    func testConsidersChangesInPingEvents() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .play, mediaPlayer: mediaPlayer)
        
        for i in (1..<60) {
            timeTraveler.travel(by: TimeInterval(1))
            mediaPlayer.currentTime = mediaPlayer.currentTime ?? 0 + 1
            mediaPlayer.muted = i % 2 == 1
            stats.update(eventType: nil, mediaPlayer: mediaPlayer)
        }
        
        timeTraveler.travel(by: TimeInterval(1))
        mediaPlayer.currentTime = 60
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(61, stats.contentWatched)
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(30, stats.timePlayedMuted)
    }
    
    func testCalculatesBufferingTime() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .bufferStart, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        stats.update(eventType: .bufferEnd, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 30
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(30, stats.timeBuffering)
    }
    
    func testEndsBufferingWhenPlaybackTimeMoves() {
        guard let timeTraveler = timeTraveler, let stats = stats else { return XCTFail() }
        let mediaPlayer = MediaUpdate(paused: false)
        
        stats.update(eventType: .bufferStart, mediaPlayer: mediaPlayer)
        
        timeTraveler.travel(by: TimeInterval(30))
        stats.update(eventType: .bufferEnd, mediaPlayer: mediaPlayer)

        timeTraveler.travel(by: TimeInterval(30))
        mediaPlayer.currentTime = 30
        stats.update(eventType: .end, mediaPlayer: mediaPlayer)
        
        XCTAssertEqual(60, stats.timePlayed)
        XCTAssertEqual(30, stats.timeBuffering)
    }
}
