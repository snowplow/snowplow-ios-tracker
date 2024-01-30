//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

class EventStoreIQWrapper: NSObject, EventStore {
    
    private let eventStore: EventStore
    
    public init(eventStore: EventStore) {
        self.eventStore = eventStore
    }
    
    func addEvent(_ payload: Payload) {
        InternalQueue.sync { eventStore.addEvent(payload) }
    }
    
    func removeEvent(withId storeId: Int64) -> Bool {
        return InternalQueue.sync { eventStore.removeEvent(withId: storeId) }
    }
    
    func removeEvents(withIds storeIds: [Int64]) -> Bool {
        return InternalQueue.sync { eventStore.removeEvents(withIds: storeIds) }
    }
    
    func removeAllEvents() -> Bool {
        return InternalQueue.sync { eventStore.removeAllEvents() }
    }
    
    func count() -> UInt {
        return InternalQueue.sync { eventStore.count() }
    }
    
    func emittableEvents(withQueryLimit queryLimit: UInt) -> [EmitterEvent] {
        return InternalQueue.sync { eventStore.emittableEvents(withQueryLimit: queryLimit) }
    }
    
    func removeOldEvents(maxSize: Int64, maxAge: TimeInterval) {
        return InternalQueue.sync { eventStore.removeOldEvents(maxSize: maxSize, maxAge: maxAge) }
    }
    
}
