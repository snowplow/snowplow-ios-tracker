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

class TestImmersiveSpaceState: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testImmersiveSpaceStateMachine() {
        let eventStore = MockEventStore()
        let emitter = Emitter(
            networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500),
            namespace: "namespace",
            eventStore: eventStore
        )
        let tracker = Tracker(trackerNamespace: "namespace", appId: nil, emitter: emitter) { tracker in
            tracker.base64Encoded = false
            tracker.immersiveSpaceContext = true
        }

        // Send events
        
        // no entity before OpenImmersiveSpaceEvent
        track(Timing(category: "category", variable: "variable", timing: 123), tracker)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        var payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        var entities = (payload?["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertFalse(entities!.contains("immersive_space"))
        
        // OpenImmersiveSpaceEvent has the entity
        track(OpenImmersiveSpaceEvent(id: "space"), tracker)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertTrue(entities!.contains("immersive_space"))
        
        // as do subsequent events
        track(Timing(category: "category", variable: "variable", timing: 123), tracker)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertTrue(entities!.contains("immersive_space"))
        
        // including DismissImmersiveSpaceEvent
        track(DismissImmersiveSpaceEvent(), tracker)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertTrue(entities!.contains("immersive_space"))
        
        // events following the dismiss event do not have the entity
        track(Foreground(index: 1), tracker)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertFalse(entities!.contains("immersive_space"))
        
        // including further dismiss events
        track(DismissImmersiveSpaceEvent(), tracker)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertFalse(entities!.contains("immersive_space"))
        
        // tracking multiple OpenImmersiveSpaceEvent doesn't change the ImmersiveSpaceState
        // because only one immersive space can be open at once
        track(OpenImmersiveSpaceEvent(id: "original space state"), tracker)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        
        track(OpenImmersiveSpaceEvent(id: "second space"), tracker)
        if eventStore.lastInsertedRow == -1 {
            XCTFail()
        }
        payload = eventStore.db[Int64(eventStore.lastInsertedRow)]
        _ = eventStore.removeAllEvents()
        entities = (payload?["co"]) as? String
        XCTAssertNotNil(entities)
        XCTAssertTrue(entities!.contains("original space state"))
        XCTAssertFalse(entities!.contains("second space"))
    }
    
    private func track(_ event: Event, _ tracker: Tracker) {
        InternalQueue.sync {
            _ = tracker.track(event)
        }
    }
}
