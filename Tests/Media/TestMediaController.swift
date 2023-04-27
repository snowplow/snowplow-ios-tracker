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
    var firstMediaPlayer: [String : Any]? { firstEvent?.mediaPlayerData }
    var firstMediaSession: [String : Any]? { firstEvent?.mediaPlayerSessionData }
    
    override func setUp() {
        tracker = createTracker()
    }
    
    override func tearDown() {
        Snowplow.removeAllTrackers()
        trackedEvents.removeAll()
    }
    
    // MARK: Media player event tests
    
    func testSetsPausedToFalseWhenPlayEventIsTracked() {
        let media = mediaController?.startMediaTracking(id: "media1", label: nil, media: MediaUpdate(paused: true))
        media?.track(.play)
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.schema?.contains("play") ?? false)
        XCTAssertNotNil(firstMediaPlayer)
        XCTAssertFalse(firstMediaPlayer?["paused"] as? Bool ?? true)
        
        mediaController?.endMediaTracking(id: "media1")
    }
    
    func testSetsPausedToTrueWhenPauseIsTracked() {
        let media = mediaController?.startMediaTracking(id: "media1", label: nil, media: MediaUpdate(paused: false))
        media?.track(.pause)
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.schema?.contains("pause") ?? false)
        XCTAssertNotNil(firstMediaPlayer)
        XCTAssertTrue(firstMediaPlayer?["paused"] as? Bool ?? false)
    }
    
    func testSetsPausedAndEndedToTrueWhenEndIsTracked() {
        let media = mediaController?.startMediaTracking(id: "media1", label: nil, media: MediaUpdate(ended: false, paused: false))
        media?.track(.end)
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.schema?.contains("end") ?? false)
        XCTAssertNotNil(firstMediaPlayer)
        XCTAssertTrue(firstMediaPlayer?["paused"] as? Bool ?? false)
        XCTAssertTrue(firstMediaPlayer?["ended"] as? Bool ?? false)
    }
    
    func testUpdatesPercentProgress() {
        let media = mediaController?.startMediaTracking(id: "media1", label: nil, media: MediaUpdate(duration: 100))
        
        media?.track(.play, media: MediaUpdate(currentTime: 50))
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssertNotNil(firstMediaPlayer)
        XCTAssertEqual(50.0, firstMediaPlayer?["currentTime"] as? Double)
        XCTAssertEqual(50, firstMediaPlayer?["percentProgress"] as? Int)
    }
    
    func testDoesntTrackSeekStartMultipleTimes() {
        let media = mediaController?.startMediaTracking(id: "media1", label: nil)
        
        media?.track(.seekStart, media: MediaUpdate(currentTime: 1))
        media?.track(.seekStart, media: MediaUpdate(currentTime: 2))
        media?.track(.seekEnd, media: MediaUpdate(currentTime: 2))
        media?.track(.seekStart, media: MediaUpdate(currentTime: 3))

        waitForEventsToBeTracked()
        
        XCTAssertEqual(3, trackedEvents.count)
        XCTAssertEqual(2, trackedEvents.filter { $0.schema?.contains("seek_start") ?? false }.count)
    }
    
    func testDoesntTrackEventsExcludedFromCaptureEvents() {
        let configuration = MediaTrackingConfiguration(id: "media1")
            .captureEvents([.play])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(.play)
        media?.track(.pause)

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
        
        media?.track(.play)

        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.entities.contains { $0.schema == "test" } ?? false)
    }
    
    func testAddsEntitiesTrackedWithEvent() {
        let media = mediaController?.startMediaTracking(id: "media1", label: nil)
        
        media?.track(
            event: MediaEvent(.ready, entities: [
                SelfDescribingJson(schema: "test1", andData: [:])
            ])
        )

        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(firstEvent?.entities.contains { $0.schema == "test1" } ?? false)
    }
    
    // MARK: Session
    
    func testAddsMediaSessionContextEntityWithGivenID() {
        let media = mediaController?.startMediaTracking(id: "media1", label: nil)
        
        media?.track(.ready)

        waitForEventsToBeTracked()
        
        XCTAssertNotNil(firstMediaSession)
        XCTAssertEqual("media1", firstMediaSession?["mediaSessionId"] as? String)
    }
    
    func testCalculatesSessionStats() {
        let timeTraveler = TimeTraveler()
        let session = MediaSessionTracking(id: "media1",
                                           dateGenerator: timeTraveler.generateDate)
        let media = MediaTrackingImpl(id: "media1",
                                      tracker: tracker!,
                                      mediaPlayer: MediaUpdate(duration: 10),
                                      session: session)
        
        media.track(.play)
        timeTraveler.travel(by: 10.0)
        media.update(media: MediaUpdate(currentTime: 10.0))
        media.track(.end)

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
        
        media.track(.play)
        MockTimer.currentTimer.fire()
        media.track(.pause)
        MockTimer.currentTimer.fire()
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(4, trackedEvents.count)
    }
    
    func testShouldStopSendingPingEventsWhenPaused() {
        let pingInterval = MediaPingInterval(maxPausedPings: 2, timerProvider: MockTimer.self)
        let media = MediaTrackingImpl(id: "media1", tracker: tracker!, pingInterval: pingInterval)
        
        media.update(media: MediaUpdate(paused: true))
        for _ in 0..<5 {
            MockTimer.currentTimer.fire()
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(2, trackedEvents.count)
    }
    
    func testShouldNotStopSendingPingEventsWhenPlaying() {
        let pingInterval = MediaPingInterval(maxPausedPings: 2, timerProvider: MockTimer.self)
        let media = MediaTrackingImpl(id: "media1", tracker: tracker!, pingInterval: pingInterval)
        
        media.update(media: MediaUpdate(paused: false))
        for _ in 0..<5 {
            MockTimer.currentTimer.fire()
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(5, trackedEvents.count)
    }
    
    // MARK: Percent progress
    
    func testShouldSendProgressEventsWhenBoundariesReached() {
        let configuration = MediaTrackingConfiguration(id: "media",
                                                       media: MediaUpdate(duration: 100))
            .boundaries([10, 50, 90])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(.play)
        for i in 1..<100 {
            media?.update(media: MediaUpdate(currentTime: Double(i)))
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(4, trackedEvents.count)
        XCTAssertEqual(3, trackedEvents.filter { $0.schema?.contains("percent_progress") ?? false }.count)
    }
    
    func testDoesntSendProgressEventsIfPaused() {
        let configuration = MediaTrackingConfiguration(id: "media",
                                                       media: MediaUpdate(duration: 100))
            .boundaries([10, 50, 90])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(.pause)
        for i in 1..<100 {
            media?.update(media: MediaUpdate(currentTime: Double(i)))
        }
        
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
    }
    
    func testDoesntSendProgressEventMultipleTimes() {
        let configuration = MediaTrackingConfiguration(id: "media",
                                                       media: MediaUpdate(duration: 100))
            .boundaries([10, 50, 90])
        let media = mediaController?.startMediaTracking(configuration: configuration)
        
        media?.track(.play)
        for i in 1..<100 {
            media?.update(media: MediaUpdate(currentTime: Double(i)))
        }
        media?.track(.seekEnd, media: MediaUpdate(currentTime: 0))
        for i in 1..<100 {
            media?.update(media: MediaUpdate(currentTime: Double(i)))
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
        return entities.first { $0.schema.contains("/media_player/") }?.data
    }
    
    var mediaPlayerSessionData: [String : Any]? {
        return entities.first { $0.schema.contains("/media_player_session/") }?.data
    }
}

