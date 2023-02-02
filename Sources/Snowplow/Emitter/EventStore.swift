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

/// Protocol to implement storage for events that are queued to be sent.
@objc(SPEventStore)
public protocol EventStore: NSObjectProtocol {
    /// Adds an event to the store.
    /// - Parameter payload: the payload to be added
    @objc
    func addEvent(_ payload: Payload)
    /// Removes an event from the store.
    /// - Parameter storeId: the identifier of the event in the store.
    /// - Returns: a boolean of success to remove.
    @objc
    func removeEvent(withId storeId: Int64) -> Bool
    /// Removes a range of events from the store.
    /// - Parameter storeIds: the events' identifiers in the store.
    /// - Returns: a boolean of success to remove.
    @objc
    func removeEvents(withIds storeIds: [Int64]) -> Bool
    /// Empties the store of all the events.
    /// - Returns: a boolean of success to remove.
    @objc
    func removeAllEvents() -> Bool
    /// Returns amount of events currently in the store.
    /// - Returns: the count of events in the store.
    @objc
    func count() -> UInt
    /// Returns a list of EmitterEvent objects which contains events and related ids.
    /// - Parameter queryLimit: is the maximum number of events returned.
    /// - Returns: EmitterEvent objects containing storeIds and event payloads.
    @objc
    func emittableEvents(withQueryLimit queryLimit: UInt) -> [EmitterEvent]
}
