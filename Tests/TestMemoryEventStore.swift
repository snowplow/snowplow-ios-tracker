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
    
    func testRemoveOldEventsByAge() {
        let eventStore = MemoryEventStore()
        
        for (i, timeDiff) in [5.0, 4.0, 3.0, 2.0, 1.0].enumerated() {
            let payload = Payload()
            payload.addValueToPayload(getTimestamp(Date().timeIntervalSince1970 - timeDiff), forKey: "dtm")
            payload.addValueToPayload(String(i + 1), forKey: "eid")
            addEvent(payload, eventStore)
        }
        
        XCTAssertEqual(count(eventStore), 5)
        
        removeOldEvents(maxSize: 5, maxAge: 3, eventStore)
        XCTAssertEqual(count(eventStore), 2)
        
        let events = emittableEvents(withQueryLimit: 5, eventStore)
        XCTAssertEqual(
            events.map { $0.payload["eid"] as! String }.sorted(),
            ["4", "5"]
        )
    }
    
    func testRemoveOldestEventsByMaxSize() {
        let eventStore = MemoryEventStore()
        
        for i in 0..<5 {
            let payload = Payload()
            payload.addValueToPayload(String(i + 1), forKey: "eid")
            addEvent(payload, eventStore)
        }
        
        XCTAssertEqual(count(eventStore), 5)
        
        removeOldEvents(maxSize: 2, maxAge: 5, eventStore)
        XCTAssertEqual(count(eventStore), 2)
        
        let events = emittableEvents(withQueryLimit: 5, eventStore)
        XCTAssertEqual(
            events.map { $0.payload["eid"] as! String }.sorted(),
            ["4", "5"]
        )
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
    
    private func removeOldEvents(maxSize: Int64, maxAge: TimeInterval, _ eventStore: EventStore) {
        InternalQueue.sync { eventStore.removeOldEvents(maxSize: maxSize, maxAge: maxAge) }
    }
    
    private func getTimestamp(_ timeInterval: TimeInterval) -> String {
        return String(format: "%lld", Int64(timeInterval * 1000))
    }
}
