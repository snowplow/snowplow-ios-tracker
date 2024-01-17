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

class TestVisionOSEvents: XCTestCase {
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
    
    func testTrackOpenWindow() {
        let event = OpenWindowEvent(
            id: "group_id"
        )
        
        _ = tracker?.track(event)
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssertEqual(swiftuiOpenWindowSchema, event.schema)
        
        let entities = trackedEvents[0].entities
        XCTAssertEqual(1, getWindowGroupEntities(entities).count)
    }
    
    func testTrackDismissWindow() {
        let event = DismissWindowEvent(
            id: "window",
            windowStyle: .automatic
        )
        
        _ = tracker?.track(event)
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssertEqual(swiftuiDismissWindowSchema, event.schema)
        
        let entities = trackedEvents[0].entities
        XCTAssertEqual(1, getWindowGroupEntities(entities).count)
    }
    
    private func createTracker() -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        
        let namespace = "testVisionOS" + String(describing: Int.random(in: 0..<100))
        eventSink = EventSink()
        
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, eventSink!])
    }
    
    private func waitForEventsToBeTracked() {
        let expect = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () -> Void in
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }
    
    private func getWindowGroupEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == swiftuiWindowGroupSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
}
