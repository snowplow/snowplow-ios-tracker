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

class TestMemoryEventStore: XCTestCase {
    func testInit() {
        let eventStore = MemoryEventStore()
        XCTAssertNotNil(eventStore)
    }

    func testInsertPayload() {
        let eventStore = MemoryEventStore()
        _ = eventStore.removeAllEvents()

        // Build an event
        let payload = Payload()
        payload.addValueToPayload("pv", forKey: "e")
        payload.addValueToPayload("www.foobar.com", forKey: "url")
        payload.addValueToPayload("Welcome to foobar!", forKey: "page")
        payload.addValueToPayload("MEEEE", forKey: "refr")

        // Insert an event
        eventStore.addEvent(payload)

        XCTAssertEqual(eventStore.count(), 1)
        let events = eventStore.emittableEvents(withQueryLimit: 1)
        XCTAssertEqual(events[0].payload.dictionary as! [String : String],
                       payload.dictionary as! [String : String])
        _ = eventStore.removeEvent(withId: 0)

        XCTAssertEqual(eventStore.count(), 0)
    }

    func testInsertManyPayloads() {
        let eventStore = MemoryEventStore()
        _ = eventStore.removeAllEvents()

        // Build an event
        let payload = Payload()
        payload.addValueToPayload("pv", forKey: "e")
        payload.addValueToPayload("www.foobar.com", forKey: "url")
        payload.addValueToPayload("Welcome to foobar!", forKey: "page")
        payload.addValueToPayload("MEEEE", forKey: "refr")

        for _ in 0..<250 {
            eventStore.addEvent(payload)
        }

        XCTAssertEqual(eventStore.count(), 250)
        XCTAssertEqual(eventStore.emittableEvents(withQueryLimit: 600).count, 250)
        XCTAssertEqual(eventStore.emittableEvents(withQueryLimit: 150).count, 150)

        _ = eventStore.removeAllEvents()
        XCTAssertEqual(eventStore.count(), 0)
    }
}
