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

import XCTest
@testable import SnowplowTracker

class TestInternalQueue: XCTestCase {
    override func tearDown() {
        Snowplow.removeAllTrackers()
        super.tearDown()
    }

    // MARK: - InternalQueue.sync reentrancy

    func testSyncCallsThroughDirectlyWhenAlreadyOnQueue() {
        var innerRan = false
        let result: Int = InternalQueue.sync {
            InternalQueue.sync {
                innerRan = true
                return 42
            }
        }
        XCTAssertTrue(innerRan)
        XCTAssertEqual(result, 42)
    }

    func testSyncFromOffQueueStillDispatchesToTheSerialQueue() {
        let result: Int = InternalQueue.sync {
            return 7
        }
        XCTAssertEqual(result, 7)
    }

    // MARK: - Calling back into Controller APIs from on-queue callbacks

    func testSettingControllerPropertyFromPluginAfterTrackDoesNotCrash() {
        var tracker: TrackerController!
        let expect = expectation(description: "afterTrack called")
        let plugin = PluginConfiguration(identifier: "plugin")
            .afterTrack { _ in
                tracker.screenContext = false
                expect.fulfill()
            }

        tracker = createTracker([plugin])
        tracker.screenContext = true

        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [expect], timeout: 2)

        XCTAssertFalse(tracker.screenContext)
    }

    func testSettingControllerPropertyFromPluginEntitiesDoesNotCrash() {
        var tracker: TrackerController!
        let plugin = PluginConfiguration(identifier: "plugin")
            .entities { _ in
                tracker.screenEngagementAutotracking = false
                return []
            }

        let expect = expectation(description: "event tracked")
        let eventSink = EventSink { _ in expect.fulfill() }
        tracker = createTracker([plugin, eventSink])
        tracker.screenEngagementAutotracking = true

        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [expect], timeout: 2)

        XCTAssertFalse(tracker.screenEngagementAutotracking)
    }

    func testSettingControllerPropertyFromPluginFilterDoesNotCrash() {
        var tracker: TrackerController!
        let plugin = PluginConfiguration(identifier: "plugin")
            .filter { _ in
                tracker.screenContext = false
                return true
            }

        let expect = expectation(description: "event tracked")
        let eventSink = EventSink { _ in expect.fulfill() }
        tracker = createTracker([plugin, eventSink])
        tracker.screenContext = true

        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [expect], timeout: 2)

        XCTAssertFalse(tracker.screenContext)
    }

    func testSettingControllerPropertyFromRequestCallbackDoesNotCrash() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let networkConfig = NetworkConfiguration(networkConnection: networkConnection)
        let emitterConfig = EmitterConfiguration()

        let expect = expectation(description: "request callback invoked")
        let requestCallback = OnQueueControllerMutatingRequestCallback {
            expect.fulfill()
        }
        emitterConfig.requestCallback = requestCallback

        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        trackerConfig.screenContext = true

        let tracker = Snowplow.createTracker(
            namespace: "testInternalQueue" + String(describing: Int.random(in: 0..<100)),
            network: networkConfig,
            configurations: [trackerConfig, emitterConfig]
        )
        requestCallback.tracker = tracker

        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [expect], timeout: 5)

        XCTAssertFalse(tracker.screenContext)
    }

    private func createTracker(_ configurations: [ConfigurationProtocol]) -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        let namespace = "testInternalQueue" + String(describing: Int.random(in: 0..<100))
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: configurations + [trackerConfig])
    }
}

/// A `RequestCallback` that mutates a Controller property from `onSuccess`/`onFailure`, which run
/// on the tracker's internal queue.
private class OnQueueControllerMutatingRequestCallback: NSObject, RequestCallback {
    var tracker: TrackerController?
    private let onCalled: () -> Void

    init(onCalled: @escaping () -> Void) {
        self.onCalled = onCalled
    }

    func onSuccess(withCount successCount: Int) {
        tracker?.screenContext = false
        onCalled()
    }

    func onFailure(withCount failureCount: Int, successCount: Int) {
        tracker?.screenContext = false
        onCalled()
    }
}
