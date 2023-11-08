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

class MemoryEventStore: NSObject, EventStore {

    var sendLimit: UInt
    var index: Int64
    var orderedSet: NSMutableOrderedSet

    convenience override init() {
        self.init(limit: 250)
    }

    init(limit: UInt) {
        orderedSet = NSMutableOrderedSet()
        sendLimit = limit
        index = 0
    }

    // Interface methods

    func addEvent(_ payload: Payload) {
        let item = EmitterEvent(payload: payload, storeId: index)
        orderedSet.add(item)
        index += 1
    }

    func count() -> UInt {
        return UInt(orderedSet.count)
    }

    func emittableEvents(withQueryLimit queryLimit: UInt) -> [EmitterEvent] {
        let setCount = (orderedSet).count
        if setCount <= 0 {
            return []
        }
        let len = min(Int(queryLimit), setCount)
        _ = NSRange(location: 0, length: len)
        var count = 0
        let indexes = orderedSet.indexes { _, _, _ in
            count += 1
            return count <= queryLimit
        }
        let objects = orderedSet.objects(at: indexes)
        var result: [EmitterEvent] = []
        for object in objects {
            if let event = object as? EmitterEvent {
                result.append(event)
            }
        }
        return result
    }

    func removeAllEvents() -> Bool {
        orderedSet.removeAllObjects()
        return true
    }

    func removeEvent(withId storeId: Int64) -> Bool {
        return removeEvents(withIds: [storeId])
    }

    func removeEvents(withIds storeIds: [Int64]) -> Bool {
        var itemsToRemove: [EmitterEvent] = []
        for item in orderedSet {
            guard let item = item as? EmitterEvent else {
                continue
            }
            if storeIds.contains(item.storeId) {
                itemsToRemove.append(item)
            }
        }
        orderedSet.removeObjects(in: itemsToRemove)
        return true
    }
}
