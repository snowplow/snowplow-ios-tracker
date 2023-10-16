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

import Foundation
class TestScreenState: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInvalidScreenState() {
        var screenState = ScreenState(name: "name", screenId: "some id")

        // Test builder setting properly
        XCTAssertEqual(screenState.isValid, false)

        // ID and name required (screen id generated)
        screenState = ScreenState(name: "some name", type: "some type", screenId: nil)

        // Test builder setting properly
        XCTAssertEqual(screenState.isValid, true)
    }

    func testValidScreenState() {
        let uuid = UUID().uuidString
        var screenState = ScreenState(name: "some name", type: "some type", screenId: uuid)

        // Test builder
        XCTAssertEqual(screenState.isValid, true)
        XCTAssertNotNil(screenState.payload)

        // ID and name required
        screenState = ScreenState(name: "some name", screenId: uuid)

        // Test builder setting properly
        XCTAssertEqual(screenState.isValid, true)
        XCTAssertNotNil(screenState.payload)
        let payload = screenState.payload
        let dictionary = payload?.dictionary
        XCTAssertEqual(dictionary?[kSPScreenName] as? String, "some name")
        XCTAssertEqual(dictionary?[kSPScreenId] as? String, uuid)
    }

    func testScreenStateMachine() {
        let eventStore = MockEventStore()
        let emitter = Emitter(namespace: "namespace", urlEndpoint: "http://snowplow-fake-url.com", eventStore: eventStore)
        let tracker = Tracker(trackerNamespace: "namespace", appId: nil, emitter: emitter) { tracker in
            tracker.base64Encoded = false
            tracker.screenContext = true
            tracker.applicationContext = false
        }
        emitter.pauseEmit()

        // Send events
        _ = tracker.track(Timing(category: "category", variable: "variable", timing: 123))
        Thread.sleep(forTimeInterval: 1)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        var payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        var entities = (payload?.dictionary["co"]) as? String
        XCTAssertNil(entities)

        let uuid = UUID()
        _ = tracker.track(ScreenView(name: "screen1", screenId: uuid))
        Thread.sleep(forTimeInterval: 1)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?.dictionary["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertTrue(entities!.contains(uuid.uuidString))

        _ = tracker.track(Timing(category: "category", variable: "variable", timing: 123))
        Thread.sleep(forTimeInterval: 1)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?.dictionary["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertTrue(entities!.contains(uuid.uuidString))

        let uuid2 = UUID()
        _ = tracker.track(ScreenView(name: "screen2", screenId: uuid2))
        Thread.sleep(forTimeInterval: 1)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?.dictionary["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertTrue(entities!.contains(uuid2.uuidString))
        let eventPayload = (payload?.dictionary["ue_pr"]) as? String
        XCTAssertNotNil(eventPayload)
        XCTAssertTrue(eventPayload!.contains(uuid.uuidString))
        XCTAssertTrue(eventPayload!.contains(uuid2.uuidString))

        _ = tracker.track(Timing(category: "category", variable: "variable", timing: 123))
        Thread.sleep(forTimeInterval: 1)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?.dictionary["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertTrue(entities!.contains(uuid2.uuidString))
    }
}
