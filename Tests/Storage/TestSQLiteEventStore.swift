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
        let emittableEvents = eventStore.emittableEvents(withQueryLimit: 10)
        XCTAssertEqual(emittableEvents.first?.payload.dictionary as! [String : String],
                       payload.dictionary as! [String : String])
        _ = eventStore.removeEvent(withId: emittableEvents.first?.storeId ?? 0)

        XCTAssertEqual(eventStore.count(), 0)
    }

    func testInsertManyPayloads() {
        let eventStore = createEventStore("aNamespace")
        _ = eventStore.removeAllEvents()

        // Build an event
        let payload = Payload()
        payload.addValueToPayload("pv", forKey: "e")
        payload.addValueToPayload("www.foobar.com", forKey: "url")
        payload.addValueToPayload("Welcome to foobar!", forKey: "page")
        payload.addValueToPayload("MEEEE", forKey: "refr")

        let dispatchQueue = DispatchQueue(label: "Save events", attributes: .concurrent)
        let expectations = [
            XCTestExpectation(),
            XCTestExpectation(),
            XCTestExpectation(),
            XCTestExpectation(),
            XCTestExpectation()
        ]
        for i in 0..<5 {
            dispatchQueue.async {
                for _ in 0..<500 {
                    eventStore.addEvent(payload)
                }
                expectations[i].fulfill()
            }
        }
        wait(for: expectations, timeout: 3)
        
        XCTAssertEqual(eventStore.count(), 2500)
        XCTAssertEqual(eventStore.emittableEvents(withQueryLimit: 600).count, 250)
        XCTAssertEqual(eventStore.emittableEvents(withQueryLimit: 150).count, 150)
        
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(eventStore.count(), 0)
    }

    func testSQLiteEventStoreCreateSQLiteFile() {
        let eventStore = createEventStore("aNamespace")
        _ = eventStore.count()
        
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        let dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNamespace.sqlite").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbPath))
    }

    func testSQLiteEventStoreInvalidNamespaceConversion() {
        let eventStore = createEventStore("namespace*.^?1ò2@")
        _ = eventStore.count()
        
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        let dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-namespace-1-2-.sqlite").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbPath))
    }

    func testMigrationFromLegacyToNamespacedEventStore() {
        var eventStore = self.createEventStore("aNamespace")
        eventStore.addEvent(Payload(dictionary: [
            "key": "value"
        ]))
        XCTAssertEqual(1, eventStore.count())

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
        XCTAssertEqual(1, eventStore.count())
        newDbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNewNamespace.sqlite").path
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldDbPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: newDbPath))
        for event in eventStore.emittableEvents(withQueryLimit: 100) {
            XCTAssertEqual("value", event.payload.dictionary["key"] as? String)
        }
    }

    func testMultipleAccessToSameSQLiteFile() {
        let eventStore1 = createEventStore("aNamespace")
        eventStore1.addEvent(Payload(dictionary: [
            "key1": "value1"
        ]))
        XCTAssertEqual(1, eventStore1.count())

        let eventStore2 = SQLiteEventStore(namespace: "aNamespace")
        eventStore2.addEvent(Payload(dictionary: [
            "key2": "value2"
        ]))
        XCTAssertEqual(2, eventStore2.count())
    }
    
    private func createEventStore(_ namespace: String, limit: Int = 250) -> SQLiteEventStore {
        DatabaseHelpers.clearPreviousDatabase(namespace)
        return SQLiteEventStore(namespace: namespace, limit: limit)
    }
}

#endif
