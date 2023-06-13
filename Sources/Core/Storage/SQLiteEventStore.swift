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

import FMDB
import Foundation

let _queryCreateTable = "CREATE TABLE IF NOT EXISTS 'events' (id INTEGER PRIMARY KEY, eventData BLOB, dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"
let _querySelectAll = "SELECT * FROM 'events'"
let _querySelectCount = "SELECT Count(*) FROM 'events'"
let _queryInsertEvent = "INSERT INTO 'events' (eventData) VALUES (?)"
let _querySelectId = "SELECT * FROM 'events' WHERE id=?"
let _queryDeleteId = "DELETE FROM 'events' WHERE id=?"
let _queryDeleteIds = "DELETE FROM 'events' WHERE id IN (%@)"
let _queryDeleteAll = "DELETE FROM 'events'"

class SQLiteEventStore: NSObject, EventStore {
    var namespace: String
    var sqliteFilename: String
    var dbPath: String
    var queue: FMDatabaseQueue?
    var sendLimit: Int

    /// IMPORTANT: This method is for internal use only. It's signature and behaviour might change in any
    /// future tracker release.
    ///
    /// Clears all the EventStores not associated at any of the namespaces passed as parameter.
    ///
    /// - Parameter allowedNamespaces: The namespace allowed. All the EventStores not associated at any of
    ///                          the allowedNamespaces will be cleared.
    /// - Returns: The list of namespaces that have been found with EventStores and have been cleared out.
    class func removeUnsentEventsExcept(forNamespaces allowedNamespaces: [String]?) -> [String]? {
        #if os(tvOS)
        let libraryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).map(\.path)[0]
        #else
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        #endif
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        var files: [String]? = nil
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: snowplowDirPath)
        } catch {
        }
        var allowedFiles: [String]? = []
        for namespace in allowedNamespaces ?? [] {
            var regex: NSRegularExpression? = nil
            do {
                regex = try NSRegularExpression(pattern: "[^a-zA-Z0-9_]+", options: [])
            } catch {
            }
            let sqliteSuffix = regex?.stringByReplacingMatches(in: namespace, options: [], range: NSRange(location: 0, length: namespace.count), withTemplate: "-")
            let sqliteFilename = "snowplowEvents-\(sqliteSuffix ?? "").sqlite"
            allowedFiles?.append(sqliteFilename)
        }
        var removedFiles: [String]? = []
        for file in files ?? [] {
            if !(allowedFiles?.contains(file) ?? false) {
                let pathToRemove = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent(file).path
                try? FileManager.default.removeItem(atPath: pathToRemove)
                removedFiles?.append(file)
            }
        }
        return removedFiles
    }

    ///  Basic initializer that creates a database event table (if one does not exist) and then closes the connection.
    convenience init(namespace: String?) {
        self.init(namespace: namespace, limit: 250)
    }

    init(namespace: String?, limit: Int) {
        self.namespace = namespace ?? ""
        sendLimit = limit

        #if os(tvOS)
        let libraryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).map(\.path)[0]
        #else
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        #endif
        // Create snowplow subdirectory if it doesn't exist
        let snowplowDirPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplow").path
        try? FileManager.default.createDirectory(atPath: snowplowDirPath, withIntermediateDirectories: true, attributes: nil)

        // Create path for the database
        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: "[^a-zA-Z0-9_]+", options: [])
        } catch {
        }
        let sqliteSuffix = regex?.stringByReplacingMatches(in: self.namespace, options: [], range: NSRange(location: 0, length: namespace?.count ?? 0), withTemplate: "-")
        sqliteFilename = "snowplowEvents-\(sqliteSuffix ?? "").sqlite"
        dbPath = URL(fileURLWithPath: snowplowDirPath).appendingPathComponent(sqliteFilename).path

        // Migrate old database if it exists
        let oldDbPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplowEvents.sqlite").path
        if FileManager.default.fileExists(atPath: oldDbPath) {
            try? FileManager.default.moveItem(atPath: oldDbPath, toPath: dbPath)
        }

        // Create database
        queue = FMDatabaseQueue(path: dbPath)
        super.init()
        _ = createTable()
    }

    deinit {
        queue?.close()
    }

    // MARK: SPEventStore implementation methods

    func addEvent(_ payload: Payload) {
        _ = insertDictionaryData(payload.dictionary)
    }

    func removeEvent(withId storeId: Int64) -> Bool {
        var res = false
        queue?.inDatabase({ db in
            if db.open() {
                logDebug(message: String(format: "Removing %d from database now.", storeId))
                res = db.executeUpdate(_queryDeleteId, withArgumentsIn: [storeId])
            }
        })
        return res
    }

    func removeEvents(withIds storeIds: [Int64]) -> Bool {
        var res = false
        queue?.inDatabase({ db in
            if db.open() && storeIds.count != 0 {
                let ids = storeIds.map { String(describing: $0) }.joined(separator: ",")
                logDebug(message: String(format: "Removing [%@] from database now.", ids))
                let query = String(format: _queryDeleteIds, ids)
                res = db.executeUpdate(query, withArgumentsIn: [])
            }
        })
        return res
    }

    func removeAllEvents() -> Bool {
        var res = false
        queue?.inDatabase({ db in
            if db.open() {
                logDebug(message: "Removing all events from database now.")
                res = db.executeUpdate(_queryDeleteAll, withArgumentsIn: [])
            }
        })
        return res
    }

    func count() -> UInt {
        var num: UInt = 0
        queue?.inDatabase({ db in
            if db.open() {
                if let s = db.executeQuery(_querySelectCount, withArgumentsIn: []) {
                    while s.next() {
                        num = NSNumber(value: s.int(forColumnIndex: 0)).uintValue
                    }
                    s.close()
                }
            }
        })
        return num
    }

    func emittableEvents(withQueryLimit queryLimit: UInt) -> [EmitterEvent] {
        return getAllEventsLimited(min(queryLimit, UInt(sendLimit))) ?? []
    }

    // MARK: SPSQLiteEventStore methods

    func createTable() -> Bool {
        var res = false
        queue?.inDatabase({ db in
            if db.open() {
                res = db.executeStatements(_queryCreateTable)
            }
        })
        return res
    }

    ///  Inserts events into the sqlite table for the app identified with it's bundleId (appId).
    ///  - Parameter payload: A SnowplowPayload instance to be inserted into the database.
    ///  - Returns: If the insert was successful, we return the rowId of the inserted entry, otherwise -1. We explicitly do this in the case of an error, sqlite would return the previous successful insert leading to incorrect data removals.
    func insertEvent(_ payload: Payload?) -> Int64 {
        return insertDictionaryData(payload?.dictionary)
    }

    func insertDictionaryData(_ dict: [AnyHashable : Any]?) -> Int64 {
        var res: Int64 = -1
        if dict == nil {
            return res
        }
        queue?.inDatabase({ db in
            if db.open() {
                if let dict = dict,
                   let data = try? JSONSerialization.data(withJSONObject: dict) {
                    try? db.executeUpdate(_queryInsertEvent, values: [data])
                    res = db.lastInsertRowId
                }
            }
        })
        return res
    }

    ///  Finds the row in the event table with the supplied ID.
    ///  - Parameter id_: Unique ID of the row in the events table to be returned.
    ///  - Returns: A dictionary containing data with keys: 'ID', 'eventData', and 'dateCreated'.
    func getEventWithId(_ id_: Int64) -> EmitterEvent? {
        var event: EmitterEvent? = nil
        queue?.inDatabase({ db in
            if db.open() {
                if let s = try? db.executeQuery(_querySelectId, values: [id_]) {
                    while s.next() {
                        if let data = s.data(forColumn: "eventData"),
                           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            let payload = Payload(dictionary: dict)
                            event = EmitterEvent(payload: payload, storeId: id_)
                        }
                    }
                    s.close()
                }
            }
        })
        return event
    }

    ///  Returns all the events in an array of dictionaries.
    ///  - Returns: An array with each dictionary element containing key-value pairs of 'date', 'data', 'ID'.
    func getAllEvents() -> [EmitterEvent]? {
        return self.getAllEvents(withQuery: _querySelectAll)
    }

    ///  Returns limited number the events that are NOT pending in an array of dictionaries.
    ///  - Returns: An array with each dictionary element containing key-value pairs of 'date', 'data', 'ID'.
    func getAllEventsLimited(_ limit: UInt) -> [EmitterEvent]? {
        let query = "\(_querySelectAll) LIMIT \((NSNumber(value: limit)).stringValue)"
        return getAllEvents(withQuery: query)
    }

    func getAllEvents(withQuery query: String) -> [EmitterEvent]? {
        var res: [EmitterEvent] = []
        queue?.inDatabase({ db in
            if db.open() {
                if let s = try? db.executeQuery(query, values: []) {
                    while s.next() {
                        let index = s.longLongInt(forColumn: "ID")
                        if let data = s.data(forColumn: "eventData"),
                           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            let payload = Payload(dictionary: dict)
                            let event = EmitterEvent(payload: payload, storeId: index)
                            res.append(event)
                        }
                    }
                    s.close()
                }
            }
        })
        return res
    }

    ///  The row ID of the last insert made.
    ///  - Returns: The row ID of the last insert made.
    func getLastInsertedRowId() -> Int64 {
        var res: Int64 = -1
        queue?.inDatabase({ db in
            res = db.lastInsertRowId
        })
        return res
    }
}

#endif
