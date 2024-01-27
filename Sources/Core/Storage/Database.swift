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

#if os(iOS) || os(macOS) || os(visionOS)

import Foundation
import SQLite3

class Database {
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private let dbPath: String
    
    static func dbPath(namespace: String) -> String {
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        
        // Create snowplow subdirectory if it doesn't exist
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        try? FileManager.default.createDirectory(atPath: snowplowDirPath, withIntermediateDirectories: true, attributes: nil)

        // Create path for the database
        let regex: NSRegularExpression? = try? NSRegularExpression(pattern: "[^a-zA-Z0-9_]+", options: [])
        
        let sqliteSuffix = regex?.stringByReplacingMatches(in: namespace, options: [], range: NSRange(location: 0, length: namespace.count), withTemplate: "-")
        let sqliteFilename = "snowplowEvents-\(sqliteSuffix ?? "").sqlite"
        return URL(fileURLWithPath: snowplowDirPath).appendingPathComponent(sqliteFilename).path
    }
    
    init(namespace: String) {
        dbPath = Database.dbPath(namespace: namespace)
        
        createTable()
    }
    
    private func createTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS 'events'
            (id INTEGER PRIMARY KEY, eventData BLOB, dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP)
            """
        
        _ = execute(sql: sql, name: "Create table")
    }
    
    func insertRow(_ dict: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dict) else {
            logError(message: "Failed to serialize event to save in database")
            return
        }
        
        let insertString = "INSERT INTO 'events' (eventData) VALUES (?)"
        data.withUnsafeBytes { rawBuffer in
            if let pointer = rawBuffer.baseAddress {
                prepare(sql: insertString, name: "Insert row") { insertStatement, db in
                    sqlite3_bind_blob(insertStatement, 1, pointer, Int32(rawBuffer.count), SQLITE_TRANSIENT)
                    
                    if sqlite3_step(insertStatement) == SQLITE_DONE {
                        logDebug(message: "Event stored in database")
                    } else {
                        logSqlError(message: "Failed to insert event to database", connection: db)
                    }
                }
            }
        }
    }
    
    func deleteRows(ids: [Int64]? = nil) -> Bool {
        var sql = "DELETE FROM 'events'"
        if let ids = ids {
            sql += " WHERE id IN \(idsSqlString(ids))"
        }
        return execute(sql: sql, name: "Delete rows")
    }
    
    func countRows() -> Int64? {
        var count: Int64? = nil
        let sql = "SELECT COUNT(*) AS count FROM 'events'"
        
        prepare(sql: sql, name: "Count rows") { selectStatement, _ in
            if sqlite3_step(selectStatement) == SQLITE_ROW {
                count = sqlite3_column_int64(selectStatement, 0)
            }
        }
        return count
    }
    
    private func idsSqlString(_ ids: [Int64] = []) -> String {
        return "(" + ids.map { "\($0)" }.joined(separator: ",") + ")"
    }
    
    func readRows(numRows: Int) -> [(id: Int64, data: [String: Any])] {
        var rows: [(id: Int64, data: [String: Any])] = []
        let sql = "SELECT id, eventData FROM 'events' LIMIT \(numRows)"
        
        var rowsRead: Int = 0
        prepare(sql: sql, name: "Select rows") { selectStatement, db in
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                if let blob = sqlite3_column_blob(selectStatement, 1) {
                    let blobLength = sqlite3_column_bytes(selectStatement, 1)
                    let data = Data(bytes: blob, count: Int(blobLength))
                    let id = sqlite3_column_int64(selectStatement, 0)
                    
                    if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        rows.append((id: id, data: dict))
                        
                        rowsRead += 1
                    }
                } else {
                    logSqlError(message: "No data found for row in events", connection: db)
                }
            }
            if rowsRead > 0 {
                logDebug(message: "Read \(rowsRead) events from database")
            }
        }
        return rows
    }
    
    func removeOldEvents(maxSize: Int64, maxAge: TimeInterval) {
        let sql = """
            DELETE FROM 'events'
            WHERE id NOT IN (
                SELECT id FROM events
                WHERE dateCreated >= datetime('now','-\(maxAge) seconds')
                ORDER BY dateCreated DESC, id DESC
                LIMIT \(maxSize)
            )
            """
        
        _ = execute(sql: sql, name: "Delete old events")
    }
    
    private func prepare(sql: String, name: String, closure: (OpaquePointer?, OpaquePointer?) -> ()) {
        withConnection { db in
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
                closure(statement, db)
            } else {
                logSqlError(message: "\(name) failed to prepare", connection: db)
            }
            sqlite3_finalize(statement)
        }
    }
    
    private func execute(sql: String, name: String) -> Bool {
        var success = false
        prepare(sql: sql, name: name) { statement, db in
            if sqlite3_step(statement) == SQLITE_DONE {
                logDebug(message: "\(name) successful")
                success = true
            } else {
                logSqlError(message: "\(name) failed", connection: db)
            }
        }
        return success
    }
    
    private func logSqlError(message: String? = nil, connection: OpaquePointer? = nil) {
        if let msg = message {
            logError(message: msg)
        }
        if let db = connection {
            let sqlError = String(cString: sqlite3_errmsg(db)!)
            logError(message: sqlError)
        }
    }
    
    private func withConnection<T>(closure: (OpaquePointer) -> T) -> T? {
        if let connection = open() {
            defer { close(connection) }
            return closure(connection)
        }
        return nil
    }
    
    private func open() -> OpaquePointer? {
        var connection: OpaquePointer?
        if sqlite3_open_v2(dbPath, &connection, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) != SQLITE_OK {
            logSqlError(message: "Failed to open database: \(dbPath)")
        }
        return connection
    }
    
    private func close(_ connection: OpaquePointer) {
        sqlite3_close(connection)
    }
}

#endif
