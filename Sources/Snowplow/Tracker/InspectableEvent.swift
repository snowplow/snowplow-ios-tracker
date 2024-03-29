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

/// The inspectable properties of the event used to generate contexts.
@objc(SPInspectableEvent)
public protocol InspectableEvent {
    /// The schema of the event
    @objc
    var schema: String? { get }

    /// The name of the event
    @objc
    var eventName: String? { get }

    /// The payload of the event
    @objc
    var payload: [String : Any] { get }

    /// The list of context entities
    @objc
    var entities: [SelfDescribingJson] { get }
}
