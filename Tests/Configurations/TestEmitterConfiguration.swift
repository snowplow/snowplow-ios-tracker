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

class TestEmitterConfiguration: XCTestCase {
    override func setUp() {
        super.setUp()
        Logger.logLevel = .verbose
    }

    override func tearDown() {
        Snowplow.removeAllTrackers()
        super.tearDown()
    }

    func testPauseEmitter() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let emitterConfig = EmitterConfiguration()
        emitterConfig.eventStore = MockEventStore()
        emitterConfig.bufferOption = .single
        let networkConfig = NetworkConfiguration(networkConnection: networkConnection)

        let tracker = createTracker(networkConfig: networkConfig, emitterConfig: emitterConfig)

        tracker.emitter?.pause()
        _ = tracker.track(Structured(category: "cat", action: "act"))
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(1, tracker.emitter?.dbCount)
        XCTAssertEqual(0, networkConnection.previousResults.count)

        tracker.emitter?.resume()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(1, networkConnection.previousResults.count)
        XCTAssertEqual(0, tracker.emitter?.dbCount)
    }

    func testActivatesServerAnonymisationInEmitter() {
        let emitterConfig = EmitterConfiguration()
        emitterConfig.serverAnonymisation = true

        let networkConfig = NetworkConfiguration(endpoint: "", method: .post)

        let tracker = createTracker(networkConfig: networkConfig, emitterConfig: emitterConfig)

        XCTAssertTrue(tracker.emitter?.serverAnonymisation ?? false)
    }
    
    func testRespectsEmitRange() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let emitterConfig = EmitterConfiguration()
        emitterConfig.eventStore = MockEventStore()
        emitterConfig.emitRange = 2
        let networkConfig = NetworkConfiguration(networkConnection: networkConnection)

        let tracker = createTracker(networkConfig: networkConfig, emitterConfig: emitterConfig)

        tracker.emitter?.pause()
        for i in 0..<10 {
            _ = tracker.track(Structured(category: "cat", action: "act").value(NSNumber(value: i)))
        }
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(10, tracker.emitter?.dbCount)
        XCTAssertEqual(0, networkConnection.previousResults.count)

        tracker.emitter?.resume()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(5, networkConnection.previousResults.count) // 5 requests for 10 events – emit range 2
        XCTAssertEqual(0, tracker.emitter?.dbCount)
    }
    
    private func createTracker(networkConfig: NetworkConfiguration, emitterConfig: EmitterConfiguration) -> TrackerController {
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.screenViewAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        let namespace = "testEmitter" + String(describing: Int.random(in: 0..<100))
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, emitterConfig])!
    }
    
}
