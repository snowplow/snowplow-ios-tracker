//
//  TestEmitterConfiguration.swift
//  Snowplow-iOSTests
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Alex Benini, Matus Tomlein
//  License: Apache License Version 2.0
//

import XCTest
@testable import SnowplowTracker

class TestEmitterConfiguration: XCTestCase {
    override func setUp() {
        super.setUp()
        Logger.logLevel = .verbose
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPauseEmitter() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let emitterConfig = EmitterConfiguration()
        emitterConfig.eventStore = MockEventStore()
        emitterConfig.bufferOption = .single
        let networkConfig = NetworkConfiguration(networkConnection: networkConnection)

        let trackerConfig = TrackerConfiguration(appId: "appid")
        trackerConfig.installAutotracking = false
        trackerConfig.screenViewAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig, emitterConfig])
        XCTAssertNotNil(tracker)

        tracker?.emitter?.pause()
        _ = tracker?.track(Structured(category: "cat", action: "act"))
        Thread.sleep(forTimeInterval: 3)
        XCTAssertEqual(1, tracker?.emitter?.dbCount)
        XCTAssertEqual(0, networkConnection.previousResults.count)

        tracker?.emitter?.resume()
        Thread.sleep(forTimeInterval: 3)
        XCTAssertEqual(1, networkConnection.previousResults.count)
        XCTAssertEqual(0, tracker?.emitter?.dbCount)
    }

    func testActivatesServerAnonymisationInEmitter() {
        let emitterConfig = EmitterConfiguration()
        emitterConfig.serverAnonymisation = true

        let networkConfig = NetworkConfiguration(endpoint: "", method: .post)

        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [emitterConfig])

        XCTAssertTrue(tracker?.emitter?.serverAnonymisation ?? false)
    }
}
