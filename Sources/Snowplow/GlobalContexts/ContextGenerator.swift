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

/// @protocol SPContextGenerator
/// A context generator used to generate global contexts.
@objc(SPContextGenerator)
public protocol ContextGenerator: NSObjectProtocol {
    /// Takes event information and decide if the context needs to be generated.
    /// - Parameter event: informations about the event to process.
    /// - Returns: whether the context has to be generated.
    @objc
    func filter(from event: InspectableEvent) -> Bool
    /// Takes event information and generates a context.
    /// - Parameter event: informations about the event to process.
    /// - Returns: a user-generated self-describing JSON.
    @objc
    func generator(from event: InspectableEvent) -> [SelfDescribingJson]?
}
