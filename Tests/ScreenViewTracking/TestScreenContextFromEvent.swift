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

class TestScreenContextFromEvent: XCTestCase {

    func testAddsTheCurrentScreenToEventsWithACallerScreenEntityByDefault() {
        let timing = trackAndWait(screenContextFromEvent: nil, match: isTiming) { tracker in
            _ = tracker.track(ScreenView(name: "Screen 1"))
            _ = tracker.track(Timing(category: "c1", variable: "v1", timing: 1).entities([self.callerScreen("Screen A")]))
        }

        XCTAssertEqual(Set(screenNames(timing)), ["Screen A", "Screen 1"])
    }

    func testKeepsTheScreenEntityAttachedByTheCaller() {
        let callerId = UUID().uuidString
        let timing = trackAndWait(screenContextFromEvent: true, match: isTiming) { tracker in
            _ = tracker.track(ScreenView(name: "Screen 1"))
            _ = tracker.track(ScreenView(name: "Screen 2"))
            _ = tracker.track(Timing(category: "c1", variable: "v1", timing: 1).entities([self.callerScreen("Screen 1", id: callerId)]))
        }

        let screens = screenEntities(timing)
        XCTAssertEqual(screens.count, 1)
        XCTAssertEqual(screens.first?["name"] as? String, "Screen 1")
        XCTAssertEqual(screens.first?["id"] as? String, callerId)
    }

    func testDoesNotDuplicateTheScreenEntityAttachedByTheCaller() {
        var events: [InspectableEvent] = []
        let expectEvents = expectation(description: "Structured events")
        expectEvents.expectedFulfillmentCount = 2
        let tracker = createTracker(screenContextFromEvent: true) { event in
            if event.eventName == "se" {
                events.append(event)
                expectEvents.fulfill()
            }
        }

        _ = tracker.track(Structured(category: "before", action: "a").entities([callerScreen("Screen A")]))
        _ = tracker.track(ScreenView(name: "Screen 1"))
        _ = tracker.track(Structured(category: "after", action: "a").entities([callerScreen("Screen A")]))
        wait(for: [expectEvents], timeout: 10)

        for event in events {
            XCTAssertEqual(screenNames(event), ["Screen A"])
        }
    }

    func testAttachesTheCurrentScreenWhenTheCallerDoesNotAttachOne() {
        let timing = trackAndWait(screenContextFromEvent: true, match: isTiming) { tracker in
            _ = tracker.track(ScreenView(name: "Screen 1"))
            _ = tracker.track(ScreenView(name: "Screen 2"))
            _ = tracker.track(Timing(category: "c1", variable: "v1", timing: 1))
        }

        XCTAssertEqual(screenNames(timing), ["Screen 2"])
    }

    func testScreenEndKeepsTheEndingScreenAfterEventsWithCallerScreenEntities() {
        let screenEnd = trackAndWait(screenContextFromEvent: true, match: { $0.schema == kSPScreenEndSchema }) { tracker in
            _ = tracker.track(ScreenView(name: "Screen 1"))
            _ = tracker.track(Timing(category: "c1", variable: "v1", timing: 1).entities([self.callerScreen("Screen A")]))
            _ = tracker.track(ScreenView(name: "Screen 2"))
        }

        XCTAssertEqual(screenNames(screenEnd), ["Screen 1"])
    }

    func testKeepsTheCallerScreenEntityAfterEnablingScreenContextFromEventAtRuntime() {
        let expectTiming = expectation(description: "Timing event")
        var timing: InspectableEvent?
        let tracker = createTracker(screenContextFromEvent: nil) { event in
            if self.isTiming(event) {
                timing = event
                expectTiming.fulfill()
            }
        }
        tracker.screenContextFromEvent = true

        _ = tracker.track(ScreenView(name: "Screen 1"))
        _ = tracker.track(Timing(category: "c1", variable: "v1", timing: 1).entities([callerScreen("Screen A")]))
        wait(for: [expectTiming], timeout: 10)

        XCTAssertTrue(tracker.screenContextFromEvent)
        XCTAssertEqual(screenNames(timing), ["Screen A"])
    }

    func testKeepsTheCallerScreenEntityOfAnotherVersion() {
        let otherVersion = "iglu:com.snowplowanalytics.mobile/screen/jsonschema/1-0-1"
        let timing = trackAndWait(screenContextFromEvent: true, match: isTiming) { tracker in
            _ = tracker.track(ScreenView(name: "Screen 1"))
            _ = tracker.track(Timing(category: "c1", variable: "v1", timing: 1).entities([
                SelfDescribingJson(schema: otherVersion, andDictionary: ["name": "Screen A", "id": UUID().uuidString])
            ]))
        }

        XCTAssertEqual(screenEntities(timing).count, 0)
        XCTAssertEqual(timing?.entities.filter { $0.schema == otherVersion }.count, 1)
    }

    func testScreenViewKeepsItsOwnScreenEntityWithACallerScreenEntity() {
        let screenView = trackAndWait(screenContextFromEvent: true, match: {
            $0.schema == kSPScreenViewSchema && $0.payload[kSPSvName] as? String == "Screen 2"
        }) { tracker in
            _ = tracker.track(ScreenView(name: "Screen 1"))
            _ = tracker.track(ScreenView(name: "Screen 2").entities([self.callerScreen("Screen A")]))
        }

        XCTAssertEqual(Set(screenNames(screenView)), ["Screen A", "Screen 2"])
    }

    // MARK: - Helpers

    private func isTiming(_ event: InspectableEvent) -> Bool {
        return event.schema == kSPUserTimingsSchema
    }

    private func callerScreen(_ name: String, id: String = UUID().uuidString) -> SelfDescribingJson {
        return SelfDescribingJson(schema: kSPScreenContextSchema, andDictionary: ["name": name, "id": id])
    }

    private func screenEntities(_ event: InspectableEvent?) -> [[String: Any]] {
        return (event?.entities ?? [])
            .filter { $0.schema == kSPScreenContextSchema }
            .map { $0.data }
    }

    private func screenNames(_ event: InspectableEvent?) -> [String] {
        return screenEntities(event).compactMap { $0["name"] as? String }
    }

    /// Tracks events and returns the first tracked event that matches.
    private func trackAndWait(screenContextFromEvent: Bool?,
                              match: @escaping (InspectableEvent) -> Bool,
                              track: (TrackerController) -> Void) -> InspectableEvent? {
        let expectEvent = expectation(description: "Matching event")
        var matched: InspectableEvent?
        let tracker = createTracker(screenContextFromEvent: screenContextFromEvent) { event in
            if matched == nil && match(event) {
                matched = event
                expectEvent.fulfill()
            }
        }
        track(tracker)
        wait(for: [expectEvent], timeout: 10)
        return matched
    }

    private func createTracker(screenContextFromEvent: Bool?,
                               callback: @escaping (InspectableEvent) -> Void) -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        trackerConfig.screenViewAutotracking = false
        if let screenContextFromEvent = screenContextFromEvent {
            trackerConfig.screenContextFromEvent = screenContextFromEvent
        }
        let namespace = "testScreenContextFromEvent" + UUID().uuidString
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, EventSink(callback: callback)])
    }
}
