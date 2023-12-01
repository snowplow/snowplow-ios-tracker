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

import Foundation
@testable import SnowplowTracker

class MockEventStore: NSObject, EventStore {
    
    var db: [Int64 : Payload] = [:]
    var lastInsertedRow = 0

    override init() {
        super.init()
        db = [:]
        lastInsertedRow = -1
    }

    func addEvent(_ payload: Payload) {
        lastInsertedRow += 1
        logVerbose(message: "Add \(payload)")
        db[Int64(lastInsertedRow)] = payload
    }

    func removeEvent(withId storeId: Int64) -> Bool {
        logVerbose(message: "Remove \(storeId)")
        return db.removeValue(forKey: storeId) != nil
    }

    func removeEvents(withIds storeIds: [Int64]) -> Bool {
        let result = true
        for storeId in storeIds {
            db.removeValue(forKey: storeId)
        }
        return result
    }

    func removeAllEvents() -> Bool {
        db.removeAll()
        lastInsertedRow = -1
        return true
    }

    func count() -> UInt {
        return UInt(db.count)
    }

    func emittableEvents(withQueryLimit queryLimit: UInt) -> [EmitterEvent] {
        var eventIds: [Int64] = []
        var events: [EmitterEvent] = []
        for (key, obj) in db {
            let payloadCopy = Payload(dictionary: obj.dictionary)
            let event = EmitterEvent(payload: payloadCopy, storeId: key)
            events.append(event)
            eventIds.append(event.storeId)
        }
        if queryLimit < events.count {
            events = Array(events.prefix(Int(queryLimit)))
        }
        logVerbose(message: "emittableEventsWithQueryLimit: \(eventIds)")
        return events
    }
}
