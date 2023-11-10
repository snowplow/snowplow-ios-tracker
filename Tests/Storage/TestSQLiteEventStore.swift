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

#if os(iOS) || os(macOS)

import XCTest
@testable import SnowplowTracker

class TestSQLiteEventStore: XCTestCase {

    func testInsertPayload() {
        let eventStore = createEventStore("aNamespace")
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
        let emittableEvents = emittableEvents(withQueryLimit: 10, eventStore)
        XCTAssertEqual(emittableEvents.first?.payload.dictionary as! [String : String],
                       payload.dictionary as! [String : String])
        removeEvent(withId: emittableEvents.first?.storeId ?? 0, eventStore)

        XCTAssertEqual(count(eventStore), 0)
    }

    func testInsertManyPayloads() {
        let eventStore = createEventStore("aNamespace")
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

    func testSQLiteEventStoreCreateSQLiteFile() {
        let eventStore = createEventStore("aNamespace")
        
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        let dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNamespace.sqlite").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbPath))
    }

    func testSQLiteEventStoreInvalidNamespaceConversion() {
        let eventStore = createEventStore("namespace*.^?1ò2@")
        
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        let dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-namespace-1-2-.sqlite").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbPath))
    }

    func testMigrationFromLegacyToNamespacedEventStore() {
        var eventStore = self.createEventStore("aNamespace")
        addEvent(Payload(dictionary: [
            "key": "value"
        ]), eventStore)
        XCTAssertEqual(1, count(eventStore))

        // Create fake legacy database
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        var newDbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNamespace.sqlite").path
        let oldDbPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplowEvents.sqlite").path
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldDbPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: newDbPath))
        try? FileManager.default.moveItem(atPath: newDbPath, toPath: oldDbPath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: oldDbPath))
        XCTAssertFalse(FileManager.default.fileExists(atPath: newDbPath))

        // Migrate database when SQLiteEventStore is launched the first time
        eventStore = createEventStore("aNewNamespace")
        XCTAssertEqual(1, count(eventStore))
        newDbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNewNamespace.sqlite").path
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldDbPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: newDbPath))
        for event in emittableEvents(withQueryLimit: 100, eventStore) {
            XCTAssertEqual("value", event.payload.dictionary["key"] as? String)
        }
    }

    func testMultipleAccessToSameSQLiteFile() {
        let eventStore1 = createEventStore("aNamespace")
        addEvent(Payload(dictionary: [
            "key1": "value1"
        ]), eventStore1)
        XCTAssertEqual(1, count(eventStore1))

        let eventStore2 = SQLiteEventStore(namespace: "aNamespace")
        addEvent(Payload(dictionary: [
            "key2": "value2"
        ]), eventStore2)
        XCTAssertEqual(2, count(eventStore2))
    }
    
    private func createEventStore(_ namespace: String, limit: Int = 250) -> SQLiteEventStore {
        DatabaseHelpers.clearPreviousDatabase(namespace)
        return SQLiteEventStore(namespace: namespace, limit: limit)
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

#endif
