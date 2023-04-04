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
    override func setUp() {
        _ = SQLiteEventStore.removeUnsentEventsExcept(forNamespaces: [])
    }

    func testInit() {
        let eventStore = SQLiteEventStore(namespace: "aNamespace")
        XCTAssertNotNil(eventStore)
    }

    func testInsertPayload() {
        let eventStore = SQLiteEventStore(namespace: "aNamespace")
        _ = eventStore.removeAllEvents()

        // Build an event
        let payload = Payload()
        payload.addValueToPayload("pv", forKey: "e")
        payload.addValueToPayload("www.foobar.com", forKey: "url")
        payload.addValueToPayload("Welcome to foobar!", forKey: "page")
        payload.addValueToPayload("MEEEE", forKey: "refr")

        // Insert an event
        _ = eventStore.insertEvent(payload)

        XCTAssertEqual(eventStore.count(), 1)
        XCTAssertEqual(eventStore.getEventWithId(1)?.payload.dictionary as! [String : String],
                       payload.dictionary as! [String : String])
        XCTAssertEqual(eventStore.getLastInsertedRowId(), 1)
        _ = eventStore.removeEvent(withId: 1)

        XCTAssertEqual(eventStore.count(), 0)
    }

    func testInsertManyPayloads() {
        let eventStore = SQLiteEventStore(namespace: "aNamespace")
        _ = eventStore.removeAllEvents()

        // Build an event
        let payload = Payload()
        payload.addValueToPayload("pv", forKey: "e")
        payload.addValueToPayload("www.foobar.com", forKey: "url")
        payload.addValueToPayload("Welcome to foobar!", forKey: "page")
        payload.addValueToPayload("MEEEE", forKey: "refr")

        for _ in 0..<250 {
            _ = eventStore.insertEvent(payload)
        }

        XCTAssertEqual(eventStore.count(), 250)
        XCTAssertEqual(eventStore.getAllEventsLimited(600)?.count, 250)
        XCTAssertEqual(eventStore.getAllEventsLimited(150)?.count, 150)
        XCTAssertEqual(eventStore.getAllEvents()?.count, 250)

        _ = eventStore.removeAllEvents()
        XCTAssertEqual(eventStore.count(), 0)
    }

    func testSQLiteEventStoreCreateSQLiteFile() {
        _ = SQLiteEventStore(namespace: "aNamespace")
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        let dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNamespace.sqlite").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbPath))
    }

    func testSQLiteEventStoreRemoveFiles() {
        _ = SQLiteEventStore(namespace: "aNamespace1")
        _ = SQLiteEventStore(namespace: "aNamespace2")
        _ = SQLiteEventStore(namespace: "aNamespace3")
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        _ = SQLiteEventStore.removeUnsentEventsExcept(forNamespaces: ["aNamespace2"])
        var dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNamespace1.sqlite").path
        XCTAssertFalse(FileManager.default.fileExists(atPath: dbPath))
        dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNamespace2.sqlite").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbPath))
        dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNamespace3.sqlite").path
        XCTAssertFalse(FileManager.default.fileExists(atPath: dbPath))
    }

    func testSQLiteEventStoreInvalidNamespaceConversion() {
        _ = SQLiteEventStore(namespace: "namespace*.^?1ò2@")
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        let dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-namespace-1-2-.sqlite").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: dbPath))
    }

    func testMigrationFromLegacyToNamespacedEventStore() {
        var eventStore = SQLiteEventStore(namespace: "aNamespace")
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
        eventStore = SQLiteEventStore(namespace: "aNewNamespace")
        newDbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent("snowplowEvents-aNewNamespace.sqlite").path
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldDbPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: newDbPath))
        XCTAssertEqual(1, eventStore.count())
        for event in eventStore.getAllEvents() ?? [] {
            XCTAssertEqual("value", event.payload.dictionary["key"] as? String)
        }
    }

    func testMultipleAccessToSameSQLiteFile() {
        let eventStore1 = SQLiteEventStore(namespace: "aNamespace")
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
}

#endif
