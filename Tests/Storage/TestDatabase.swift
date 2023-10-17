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

class TestDatabase: XCTestCase {
    
    func testDatabasePathConsistentForNamespace() {
        XCTAssertEqual(Database.dbPath(namespace: "ns1"), Database.dbPath(namespace: "ns1"))
    }
    
    func testDatabasePathDiffersByNamespace() {
        XCTAssertNotEqual(Database.dbPath(namespace: "ns1"), Database.dbPath(namespace: "ns2"))
    }
    
    func testDatabasePathDoesntContainSpecialChars() {
        XCTAssertFalse(Database.dbPath(namespace: "%*$@db").contains("%*$@"))
    }

    func testInsertsAndReadsRow() {
        let database = createDatabase("db1")
        
        database.insertRow(["test": true])
        let rows = database.readRows(numRows: 100)
        
        XCTAssertEqual(1, rows.count)
        XCTAssertEqual(
            try? JSONSerialization.data(withJSONObject: rows.first?.data ?? []),
            try? JSONSerialization.data(withJSONObject: ["test": true])
        )
    }

    func testCanWorkWithTwoOpenDatabases() {
        let db1 = createDatabase("db1")
        let db2 = createDatabase("db2")
        
        db1.insertRow(["test": 1])
        db2.insertRow(["test": 2])
        let rows1 = db1.readRows(numRows: 100)
        let rows2 = db2.readRows(numRows: 100)
        
        XCTAssertEqual(1, rows1.count)
        XCTAssertEqual(1, rows2.count)
        
        XCTAssertNotEqual(
            try? JSONSerialization.data(withJSONObject: rows1.first?.data ?? []),
            try? JSONSerialization.data(withJSONObject: rows2.first?.data ?? [])
        )
    }
    
    func testDeleteAllRows() {
        let db = createDatabase("db")
        
        db.insertRow(["test": 1])
        db.insertRow(["test": 2])
        
        XCTAssertEqual(db.readRows(numRows: 100).count, 2)
        
        XCTAssertTrue(db.deleteRows())
        
        XCTAssertEqual(db.readRows(numRows: 100).count, 0)
    }
    
    func testDeleteSpecificRows() {
        let db = createDatabase("db")
        
        db.insertRow(["test": 1])
        db.insertRow(["test": 2])
        
        let rows = db.readRows(numRows: 100)
        XCTAssertEqual(rows.count, 2)
        
        XCTAssertTrue(db.deleteRows(ids: [rows.first?.id ?? 0]))
        
        let newRows = db.readRows(numRows: 100)
        XCTAssertEqual(newRows.count, 1)
        XCTAssertEqual(newRows.first?.id, rows.last?.id)
    }
    
    func testSelectRowsWithLimit() {
        let db = createDatabase("db")
        
        db.insertRow(["test": 1])
        db.insertRow(["test": 2])
        
        let rows = db.readRows(numRows: 1)
        XCTAssertEqual(rows.count, 1)
    }
    
    func testCountRows() {
        let db = createDatabase("db")
        
        db.insertRow(["test": 1])
        XCTAssertEqual(db.countRows(), 1)
        db.insertRow(["test": 2])
        XCTAssertEqual(db.countRows(), 2)
        XCTAssertTrue(db.deleteRows())
        XCTAssertEqual(db.countRows(), 0)
    }
    
    private func createDatabase(_ namespace: String) -> Database {
        DatabaseHelpers.clearPreviousDatabase(namespace)
        return Database(namespace: namespace)
    }
}

#endif
