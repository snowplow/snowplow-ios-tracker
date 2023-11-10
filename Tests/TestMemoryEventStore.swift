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
        removeAllEvents(eventStore)

        // Build an event
        let payload = Payload()
        payload.addValueToPayload("pv", forKey: "e")
        payload.addValueToPayload("www.foobar.com", forKey: "url")
        payload.addValueToPayload("Welcome to foobar!", forKey: "page")
        payload.addValueToPayload("MEEEE", forKey: "refr")

        // Insert an event
        addEvent(payload, eventStore)

        XCTAssertEqual(count(eventStore), 1)
        let events = emittableEvents(withQueryLimit: 1, eventStore)
        XCTAssertEqual(events[0].payload.dictionary as! [String : String],
                       payload.dictionary as! [String : String])
        removeEvent(withId: 0, eventStore)

        XCTAssertEqual(count(eventStore), 0)
    }

    func testInsertManyPayloads() {
        let eventStore = MemoryEventStore()
        removeAllEvents(eventStore)

        // Build an event
        let payload = Payload()
        payload.addValueToPayload("pv", forKey: "e")
        payload.addValueToPayload("www.foobar.com", forKey: "url")
        payload.addValueToPayload("Welcome to foobar!", forKey: "page")
        payload.addValueToPayload("MEEEE", forKey: "refr")

        for _ in 0..<250 {
            addEvent(payload, eventStore)
        }

        XCTAssertEqual(count(eventStore), 250)
        XCTAssertEqual(emittableEvents(withQueryLimit: 600, eventStore).count, 250)
        XCTAssertEqual(emittableEvents(withQueryLimit: 150, eventStore).count, 150)

        removeAllEvents(eventStore)
        XCTAssertEqual(count(eventStore), 0)
    }
    
    private func addEvent(_ payload: Payload, _ eventStore: EventStore) {
        InternalQueue.sync { eventStore.addEvent(payload) }
    }
    
    private func removeAllEvents(_ eventStore: EventStore) {
        InternalQueue.sync { _ = eventStore.removeAllEvents() }
    }
    
    private func removeEvent(withId: Int64, _ eventStore: EventStore) {
        InternalQueue.sync { _ = eventStore.removeEvent(withId: withId) }
    }
    
    private func count(_ eventStore: EventStore) -> UInt {
        InternalQueue.sync { return eventStore.count() }
    }
    
    private func emittableEvents(withQueryLimit: UInt, _ eventStore: EventStore) -> [EmitterEvent] {
        InternalQueue.sync { return eventStore.emittableEvents(withQueryLimit: withQueryLimit) }
    }
}
