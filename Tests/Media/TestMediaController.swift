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

class TestMediaController: XCTestCase {
    
    var trackedEvents: [InspectableEvent] = []
    var tracker: TrackerController?
    var mediaController: MediaController? { tracker?.media }
    var firstEvent: InspectableEvent? { trackedEvents.first }
    var secondEvent: InspectableEvent? { trackedEvents[1] }
    var firstPlayer: [String : Any]? { firstEvent?.mediaPlayerData }
    var secondPlayer: [String : Any]? { secondEvent?.mediaPlayerData }
    var firstSession: [String : Any]? { firstEvent?.mediaPlayerSessionData }
    
    override func setUp() {
        tracker = createTracker()
    }
    
    override func tearDown() {
        Snowplow.removeAllTrackers()
        trackedEvents.removeAll()
    }
    
    // MARK: Media player event tests
    
    func testSetsPausedToFalseWhenPlayEventIsTracked() {
        let media = mediaController?.startMediaTracking(id: "media1", player: MediaPlayerEntity(paused: true))
        media?.track(MediaPlayEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.schema?.contains("play") ?? false)
        XCTAssertNotNil(firstPlayer)
        XCTAssertFalse(firstPlayer?["paused"] as? Bool ?? true)
        
        mediaController?.endMediaTracking(id: "media1")
    }
    
    func testSetsPausedToTrueWhenPauseIsTracked() {
        let media = mediaController?.startMediaTracking(id: "media1", player: MediaPlayerEntity(paused: false))
        media?.track(MediaPauseEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.schema?.contains("pause") ?? false)
        XCTAssertNotNil(firstPlayer)
        XCTAssertTrue(firstPlayer?["paused"] as? Bool ?? false)
    }
    
    func testSetsPausedAndEndedToTrueWhenEndIsTracked() {
        let media = mediaController?.startMediaTracking(id: "media1", player: MediaPlayerEntity(ended: false, paused: false))
        media?.track(MediaEndEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.schema?.contains("end") ?? false)
        XCTAssertNotNil(firstPlayer)
        XCTAssertTrue(firstPlayer?["paused"] as? Bool ?? false)
        XCTAssertTrue(firstPlayer?["ended"] as? Bool ?? false)
    }
    
    func testDoesntTrackSeekStartMultipleTimes() {
        let media = mediaController?.startMediaTracking(id: "media1")
        
        media?.track(MediaSeekStartEvent(), player: MediaPlayerEntity(currentTime: 1))
        media?.track(MediaSeekStartEvent(), player: MediaPlayerEntity(currentTime: 2))
        media?.track(MediaSeekEndEvent(), player: MediaPlayerEntity(currentTime: 2))
        media?.track(MediaSeekStartEvent(), player: MediaPlayerEntity(currentTime: 3))
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(3, trackedEvents.count)
        XCTAssertEqual(2, trackedEvents.filter { $0.schema?.contains("seek_start") ?? false }.count)
    }
    
    func testDoesntTrackEventsExcludedFromCaptureEvents() {
        let configuration = MediaTrackingConfiguration(id: "media1")
            .captureEvents([MediaPlayEvent.self])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(MediaPlayEvent())
        media?.track(MediaPauseEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.schema?.contains("play") ?? false)
    }
    
    func testAddsEntitiesFromConfigToEvents() {
        let configuration = MediaTrackingConfiguration(id: "media1")
            .entities([
                SelfDescribingJson(schema: "test", andData: [:])
            ])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(MediaPlayEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.entities.contains { $0.schema == "test" } ?? false)
    }
    
    func testAddsEntitiesTrackedWithEvent() {
        let media = mediaController?.startMediaTracking(id: "media1")
        
        media?.track(
            MediaReadyEvent()
                .entities([
                    SelfDescribingJson(schema: "test1", andData: [:])
                ])
        )
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.entities.contains { $0.schema == "test1" } ?? false)
        XCTAssert(firstEvent?.entities.contains { $0.schema.contains("/media_player/") } ?? false)
    }
    
    func testTrackingPlaybackRateChangeEventUpdatesThePlaybackRate() {
        let media = mediaController?.startMediaTracking(
            id: "media1",
            player: MediaPlayerEntity(playbackRate: 0.5)
        )
        
        media?.track(MediaPlaybackRateChangeEvent(newRate: 1.5))
        media?.track(MediaPauseEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(2, trackedEvents.count)
        XCTAssertEqual(0.5, firstEvent?.payload["previousRate"] as? Double)
        XCTAssertEqual(1.5, firstEvent?.payload["newRate"] as? Double)
        XCTAssertEqual(1.5, firstPlayer?["playbackRate"] as? Double)
        XCTAssertEqual(1.5, secondPlayer?["playbackRate"] as? Double)
    }
    
    func testTrackingVolumeChangeEventUpdatesTheVolume() {
        let media = mediaController?.startMediaTracking(
            id: "media1",
            player: MediaPlayerEntity(volume: 80)
        )
        
        media?.track(MediaVolumeChangeEvent(newVolume: 90))
        media?.track(MediaPauseEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(2, trackedEvents.count)
        XCTAssertEqual(80, firstEvent?.payload["previousVolume"] as? Int)
        XCTAssertEqual(90, firstEvent?.payload["newVolume"] as? Int)
        XCTAssertEqual(90, firstPlayer?["volume"] as? Int)
        XCTAssertEqual(90, secondPlayer?["volume"] as? Int)
    }
    
    func testTrackingFullscreenChangeEventUpdatesFullscreenInMediaPlayer() {
        let media = mediaController?.startMediaTracking(
            id: "media1",
            player: MediaPlayerEntity(fullscreen: false)
        )
        
        media?.track(MediaFullscreenChangeEvent(fullscreen: true))
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(true, firstEvent?.payload["fullscreen"] as? Bool)
        XCTAssertEqual(true, firstPlayer?["fullscreen"] as? Bool)
    }
    
    func testTrackingPictureInPictureChangeEventUpdatesPictureInPictureInMediaPlayer() {
        let media = mediaController?.startMediaTracking(
            id: "media1",
            player: MediaPlayerEntity(pictureInPicture: false)
        )
        
        media?.track(MediaPictureInPictureChangeEvent(pictureInPicture: true))
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(true, firstEvent?.payload["pictureInPicture"] as? Bool)
        XCTAssertEqual(true, firstPlayer?["pictureInPicture"] as? Bool)
    }
    
    func testTrackingAdFirstQuartileSetsPercentProgress() {
        let media = mediaController?.startMediaTracking(id: "media1")
        
        media?.track(MediaAdFirstQuartileEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(25, firstEvent?.payload["percentProgress"] as? Int)
    }
    
    func testTrackingAdMidpointSetsPercentProgress() {
        let media = mediaController?.startMediaTracking(id: "media1")
        
        media?.track(MediaAdMidpointEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(50, firstEvent?.payload["percentProgress"] as? Int)
    }
    
    func testTrackingAdThirdQuartileSetsPercentProgress() {
        let media = mediaController?.startMediaTracking(id: "media1")
        
        media?.track(MediaAdThirdQuartileEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(75, firstEvent?.payload["percentProgress"] as? Int)
    }
    
    func testAddsPercentProgressPropertyToAdEvents() {
        let media = mediaController?.startMediaTracking(id: "media1")
        
        media?.track(MediaAdClickEvent(percentProgress: 15))
        media?.track(MediaAdSkipEvent(percentProgress: 30))
        media?.track(MediaAdResumeEvent(percentProgress: 40))
        media?.track(MediaAdPauseEvent(percentProgress: 50))
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(15, firstEvent?.payload["percentProgress"] as? Int)
        XCTAssertEqual(30, secondEvent?.payload["percentProgress"] as? Int)
        XCTAssertEqual(40, trackedEvents[2].payload["percentProgress"] as? Int)
        XCTAssertEqual(50, trackedEvents[3].payload["percentProgress"] as? Int)
    }
    
    func testSetsQualityPropertiesInQualityChangeEvent() {
        let media = mediaController?.startMediaTracking(
            id: "media1",
            player: MediaPlayerEntity(quality: "720p")
        )
        
        media?.track(MediaQualityChangeEvent(
            newQuality: "1080p",
            bitrate: 3333,
            framesPerSecond: 60
        ))
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual("720p", firstEvent?.payload["previousQuality"] as? String)
        XCTAssertEqual("1080p", firstEvent?.payload["newQuality"] as? String)
        XCTAssertEqual("1080p", firstPlayer?["quality"] as? String)
        XCTAssertEqual(3333, firstEvent?.payload["bitrate"] as? Int)
        XCTAssertEqual(60, firstEvent?.payload["framesPerSecond"] as? Int)
    }
    
    func testSetsPropertiesOfErrorEvent() {
        let media = mediaController?.startMediaTracking(id: "media1")
        
        media?.track(MediaErrorEvent(
            errorCode: "501",
            errorName: "forbidden",
            errorDescription: "Failed to load resource"
        ))
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual("501", firstEvent?.payload["errorCode"] as? String)
        XCTAssertEqual("forbidden", firstEvent?.payload["errorName"] as? String)
        XCTAssertEqual("Failed to load resource", firstEvent?.payload["errorDescription"] as? String)
    }
    
    func testTracksCustomEvent() {
        let media = mediaController?.startMediaTracking(id: "media1", player: MediaPlayerEntity(label: "Video"))
        
        media?.track(ScreenView(name: "sv"))
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(kSPScreenViewSchema, firstEvent?.schema)
        XCTAssertEqual("Video", firstPlayer?["label"] as? String)
        
    }
    
    // MARK: Session
    
    func testAddsMediaSessionContextEntityWithGivenID() {
        let media = mediaController?.startMediaTracking(id: "media1")
        
        media?.track(MediaReadyEvent())
        
        waitForEventsToBeTracked()
        
        XCTAssertNotNil(firstSession)
        XCTAssertEqual("media1", firstSession?["mediaSessionId"] as? String)
    }
    
    func testCalculatesSessionStats() {
        let timeTraveler = TimeTraveler()
        let session = MediaSessionTracking(id: "media1",
                                           dateGenerator: timeTraveler.generateDate)
        let media = MediaTrackingImpl(id: "media1",
                                      tracker: tracker!,
                                      player: MediaPlayerEntity(duration: 10),
                                      session: session)
        
        media.track(MediaPlayEvent())
        timeTraveler.travel(by: 10.0)
        media.update(player: MediaPlayerEntity(currentTime: 10.0))
        media.track(MediaEndEvent())
        
        waitForEventsToBeTracked()
        
        let sessionEntity = trackedEvents.last?.mediaPlayerSessionData
        XCTAssertNotNil(sessionEntity)
        XCTAssertEqual(10.0, sessionEntity?["timePlayed"] as? Double)
        XCTAssertEqual(11, sessionEntity?["contentWatched"] as? Int)
    }
    
    // MARK: Ping events
    
    func testStartsSendingPingEventsAfterSessionStarts() {
        let pingInterval = MediaPingInterval(timerProvider: MockTimer.self)
        _ = MediaTrackingImpl(id: "media1", tracker: tracker!, pingInterval: pingInterval)
        
        MockTimer.currentTimer.fire()
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.schema?.contains("ping") ?? false)
    }
    
    func testShouldSendPingEventsRegardlessOfOtherEvents() {
        let pingInterval = MediaPingInterval(timerProvider: MockTimer.self)
        let media = MediaTrackingImpl(id: "media1", tracker: tracker!, pingInterval: pingInterval)
        
        media.track(MediaPlayEvent())
        MockTimer.currentTimer.fire()
        media.track(MediaPauseEvent())
        MockTimer.currentTimer.fire()
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(4, trackedEvents.count)
    }
    
    func testShouldStopSendingPingEventsWhenPaused() {
        let pingInterval = MediaPingInterval(maxPausedPings: 2, timerProvider: MockTimer.self)
        let media = MediaTrackingImpl(id: "media1", tracker: tracker!, pingInterval: pingInterval)
        
        media.update(player: MediaPlayerEntity(paused: true))
        for _ in 0..<5 {
            MockTimer.currentTimer.fire()
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(2, trackedEvents.count)
    }
    
    func testShouldNotStopSendingPingEventsWhenPlaying() {
        let pingInterval = MediaPingInterval(maxPausedPings: 2, timerProvider: MockTimer.self)
        let media = MediaTrackingImpl(id: "media1", tracker: tracker!, pingInterval: pingInterval)
        
        media.update(player: MediaPlayerEntity(paused: false))
        for _ in 0..<5 {
            MockTimer.currentTimer.fire()
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(5, trackedEvents.count)
    }
    
    // MARK: Percent progress
    
    func testShouldSendProgressEventsWhenBoundariesReached() {
        let configuration = MediaTrackingConfiguration(id: "media",
                                                       player: MediaPlayerEntity(duration: 100))
            .boundaries([10, 50, 90])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(MediaPlayEvent())
        for i in 1..<100 {
            media?.update(player: MediaPlayerEntity(currentTime: Double(i)))
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(4, trackedEvents.count)
        XCTAssertEqual(3, trackedEvents.filter { $0.schema?.contains("percent_progress") ?? false }.count)
    }
    
    func testDoesntSendProgressEventsIfPaused() {
        let configuration = MediaTrackingConfiguration(id: "media",
                                                       player: MediaPlayerEntity(duration: 100))
            .boundaries([10, 50, 90])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(MediaPauseEvent())
        for i in 1..<100 {
            media?.update(player: MediaPlayerEntity(currentTime: Double(i)))
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
    }
    
    func testDoesntSendProgressEventMultipleTimes() {
        let configuration = MediaTrackingConfiguration(id: "media",
                                                       player: MediaPlayerEntity(duration: 100))
            .boundaries([10, 50, 90])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(MediaPlayEvent())
        for i in 1..<100 {
            media?.update(player: MediaPlayerEntity(currentTime: Double(i)))
        }
        media?.track(MediaSeekEndEvent(), player: MediaPlayerEntity(currentTime: 0))
        for i in 1..<100 {
            media?.update(player: MediaPlayerEntity(currentTime: Double(i)))
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(5, trackedEvents.count)
        XCTAssertEqual(3, trackedEvents.filter { $0.schema?.contains("percent_progress") ?? false }.count)
    }
    
    // MARK: Helper functions
    
    private func createTracker() -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        
        let namespace = "testMedia" + String(describing: Int.random(in: 0..<100))
        let plugin = PluginConfiguration(identifier: "testPlugin" + namespace)
            .afterTrack { event in
                if namespace == self.tracker?.namespace {
                    self.trackedEvents.append(event)
                }
            }
        
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, plugin])!
    }
    
    private func waitForEventsToBeTracked() {
        let expect = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () -> Void in
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }
}

extension InspectableEvent {
    var mediaPlayerData: [String : Any]? {
        return entities.first { $0.schema == MediaSchemata.playerSchema }?.data
    }
    
    var mediaPlayerSessionData: [String : Any]? {
        return entities.first { $0.schema == MediaSchemata.sessionSchema }?.data
    }
}

