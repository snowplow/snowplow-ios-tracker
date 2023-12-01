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

import Foundation

class SQLiteEventStore: NSObject, EventStore {
    private let database: Database
    private var sendLimit: Int

    init(namespace: String?, limit: Int = 250) {
        let namespace = namespace ?? ""
        
        // Migrate old database if it exists
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).map(\.path)[0]
        let oldDbPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("snowplowEvents.sqlite").path
        if FileManager.default.fileExists(atPath: oldDbPath) {
            let newDbPath = Database.dbPath(namespace: namespace)
            try? FileManager.default.moveItem(atPath: oldDbPath, toPath: newDbPath)
        }
        
        database = Database(namespace: namespace)
        sendLimit = limit
    }

    // MARK: SPEventStore implementation methods

    func addEvent(_ payload: Payload) {
        InternalQueue.onQueuePrecondition()
        
        self.database.insertRow(payload.dictionary)
    }

    func removeEvent(withId storeId: Int64) -> Bool {
        InternalQueue.onQueuePrecondition()
        
        return database.deleteRows(ids: [storeId])
    }

    func removeEvents(withIds storeIds: [Int64]) -> Bool {
        InternalQueue.onQueuePrecondition()
        
        return database.deleteRows(ids: storeIds)
    }

    func removeAllEvents() -> Bool {
        InternalQueue.onQueuePrecondition()
        
        return database.deleteRows()
    }

    func count() -> UInt {
        InternalQueue.onQueuePrecondition()
        
        if let count = database.countRows() {
            return UInt(count)
        }
        return 0
    }

    func emittableEvents(withQueryLimit queryLimit: UInt) -> [EmitterEvent] {
        InternalQueue.onQueuePrecondition()
        
        let limit = min(Int(queryLimit), sendLimit)
        let rows = database.readRows(numRows: limit)
        return rows.map { row in
            let payload = Payload(dictionary: row.data)
            return EmitterEvent(payload: payload, storeId: row.id)
        }
    }
}

#endif
