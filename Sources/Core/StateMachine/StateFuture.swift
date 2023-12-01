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

/// StateFuture represents the placeholder of a future computation.
/// The proper state value is computed when it's observed. Until that moment the StateFuture keeps the elements
/// (event, previous StateFuture, StateMachine) needed to calculate the real state value.
/// For this reason, the StateFuture can be the head of StateFuture chain which will collapse once the StateFuture
/// head is asked to get the real state value.
class StateFuture {
    private var event: Event?
    private var previousState: StateFuture?
    private var stateMachine: StateMachineProtocol?
    private var computedState: State?

    init(event: Event, previousState: StateFuture?, stateMachine: StateMachineProtocol) {
        self.event = event
        self.previousState = previousState
        self.stateMachine = stateMachine
    }

    func computeState() -> State? {
        if computedState == nil {
            if let stateMachine = stateMachine, let event = event {
                computedState = stateMachine.transition(from: event, state: previousState?.computeState())
                previousState = nil
                self.event = nil
                self.stateMachine = nil
            }
        }
        return computedState
    }
}
