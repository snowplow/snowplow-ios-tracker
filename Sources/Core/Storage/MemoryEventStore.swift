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

    private var sendLimit: UInt
    private var index: Int64
    private var eventBuffer: [EmitterEvent] = []

    convenience override init() {
        self.init(limit: 250)
    }

    init(limit: UInt) {
        sendLimit = limit
        index = 0
    }

    // Interface methods

    func addEvent(_ payload: Payload) {
        InternalQueue.onQueuePrecondition()
        
        let item = EmitterEvent(payload: payload, storeId: index)
        eventBuffer.append(item)
        index += 1
    }

    func count() -> UInt {
        InternalQueue.onQueuePrecondition()
        
        return UInt(eventBuffer.count)
    }

    func emittableEvents(withQueryLimit queryLimit: UInt) -> [EmitterEvent] {
        InternalQueue.onQueuePrecondition()
        
        let limit = min(queryLimit, sendLimit)
        
        return Array(eventBuffer.prefix(Int(limit)))
    }

    func removeAllEvents() -> Bool {
        InternalQueue.onQueuePrecondition()
        
        eventBuffer.removeAll()
        return true
    }

    func removeEvent(withId storeId: Int64) -> Bool {
        InternalQueue.onQueuePrecondition()
        
        return removeEvents(withIds: [storeId])
    }

    func removeEvents(withIds storeIds: [Int64]) -> Bool {
        InternalQueue.onQueuePrecondition()
        
        eventBuffer = eventBuffer.filter { !storeIds.contains($0.storeId) }
        return true
    }
    
    func removeOldEvents(maxSize: Int64, maxAge: TimeInterval) {
        InternalQueue.onQueuePrecondition()
        
        let currentTimestamp = Date().timeIntervalSince1970
        
        // remove old events by age
        eventBuffer = eventBuffer.filter { emitterEvent in
            if let timestampString = emitterEvent.payload[kSPTimestamp] as? String,
               let timestamp = Double(timestampString) {
                let timestampSecs = timestamp / 1000.0
                return currentTimestamp - timestampSecs <= maxAge
            }
            return true
        }
        
        // remove old events by size limit
        eventBuffer = Array(eventBuffer.suffix(Int(maxSize)))
    }
}
