//
//  TrackerState.swift
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Foundation

/// The global tracker state which collects all the state generated by the tracker state machines.
class TrackerState: NSObject, TrackerStateSnapshot {
    private var trackerState: [String: StateFuture] = [:]

    /// Set a future computable state with a specific state identifier
    func setStateFuture(_ state: StateFuture, identifier stateIdentifier: String) {
        objc_sync_enter(self)
        trackerState[stateIdentifier] = state
        objc_sync_exit(self)
    }

    /// Get a future computable state associated with a state identifier
    func stateFuture(withIdentifier stateIdentifier: String) -> StateFuture? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return trackerState[stateIdentifier]
    }

    func remove(withIdentifier stateIdentifer: String) {
        objc_sync_enter(self)
        trackerState.removeValue(forKey: stateIdentifer)
        objc_sync_exit(self)
    }

    /// Get an immutable copy of the whole tracker state
    func snapshot() -> TrackerStateSnapshot? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let newTrackerState = TrackerState()
        newTrackerState.trackerState = trackerState
        return newTrackerState
    }

    // Protocol SPTrackerStateSnapshot

    func state(withIdentifier stateIdentifier: String) -> State? {
        return stateFuture(withIdentifier: stateIdentifier)?.computeState()
    }

    func state(withStateMachine stateMachine: StateMachineProtocol) -> State? {
        return state(withIdentifier: stateMachine.identifier)
    }
}
