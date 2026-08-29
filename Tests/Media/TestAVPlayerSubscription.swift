//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

#if !os(watchOS)
import XCTest
import AVKit
@testable import SnowplowTracker

class TestAVPlayerSubscription: XCTestCase {

    var eventSink: EventSink?
    var trackedEvents: [InspectableEvent] { return eventSink?.trackedEvents ?? [] }
    var tracker: TrackerController?

    override func setUp() {
        tracker = createTracker()
    }

    override func tearDown() {
        Snowplow.removeAllTrackers()
        eventSink = nil
    }

    func testDoesNotTrackNotificationsFromUnrelatedAVPlayerItem() {
        let trackedPlayerItem = AVPlayerItem(url: URL(string: "https://snowplow.io/tracked.mp4")!)
        let trackedPlayer = AVPlayer(playerItem: trackedPlayerItem)
        _ = tracker?.media.startMediaTracking(player: trackedPlayer,
                                              configuration: MediaTrackingConfiguration(id: "media1"))

        let unrelatedItem = AVPlayerItem(url: URL(string: "https://snowplow.io/unrelated.mp4")!)
        NotificationCenter.default.post(name: .AVPlayerItemDidPlayToEndTime, object: unrelatedItem)

        waitForEventsToBeTracked()

        XCTAssertEqual(0, trackedEvents.count, "Should not track events from unrelated AVPlayerItem")

        tracker?.media.endMediaTracking(id: "media1")
    }

    func testTracksNotificationFromTrackedAVPlayerItem() {
        let trackedPlayerItem = AVPlayerItem(url: URL(string: "https://snowplow.io/tracked.mp4")!)
        let trackedPlayer = AVPlayer(playerItem: trackedPlayerItem)
        _ = tracker?.media.startMediaTracking(player: trackedPlayer,
                                              configuration: MediaTrackingConfiguration(id: "media1"))

        NotificationCenter.default.post(name: .AVPlayerItemDidPlayToEndTime, object: trackedPlayerItem)

        waitForEventsToBeTracked()

        XCTAssertEqual(1, trackedEvents.count)
        XCTAssertTrue(trackedEvents.first?.schema?.contains("end") ?? false)

        tracker?.media.endMediaTracking(id: "media1")
    }

    func testDoesNotTrackBufferStartFromUnrelatedAVPlayerItem() {
        let trackedPlayerItem = AVPlayerItem(url: URL(string: "https://snowplow.io/tracked.mp4")!)
        let trackedPlayer = AVPlayer(playerItem: trackedPlayerItem)
        _ = tracker?.media.startMediaTracking(player: trackedPlayer,
                                              configuration: MediaTrackingConfiguration(id: "media1"))

        let unrelatedItem = AVPlayerItem(url: URL(string: "https://snowplow.io/unrelated.mp4")!)
        NotificationCenter.default.post(name: .AVPlayerItemPlaybackStalled, object: unrelatedItem)

        waitForEventsToBeTracked()

        XCTAssertEqual(0, trackedEvents.count, "Should not track buffer start from unrelated AVPlayerItem")

        tracker?.media.endMediaTracking(id: "media1")
    }

    // MARK: - Helpers

    private func createTracker() -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false

        let namespace = "testAVPlayer" + String(describing: Int.random(in: 0..<100))
        self.eventSink = EventSink()
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, eventSink!])
    }

    private func waitForEventsToBeTracked() {
        let expect = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }
}
#endif
