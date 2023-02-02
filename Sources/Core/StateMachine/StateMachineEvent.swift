//  Copyright (c) 2023 Snowplow Analytics Ltd. All rights reserved.
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

/// The inspectable properties of the event used to generate contexts.
protocol StateMachineEvent {
    /// The tracker state at the time the event was sent.
    var state: TrackerStateSnapshot { get }

    /// Add payload values to the event.
    /// - Parameter payload: Map of values to add to the event payload.
    /// - Returns: Whether or not the values have been successfully added to the event payload.
    func addPayloadValues(_ payload: [String : Any]) -> Bool
}
