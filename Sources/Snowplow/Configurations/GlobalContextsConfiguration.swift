//  SPGlobalContextsConfiguration.swift
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

@objc(SPGlobalContextsConfigurationProtocol)
public protocol GlobalContextsConfigurationProtocol: AnyObject {
    @objc
    var contextGenerators: [String : GlobalContext] { get set }
    /// Add a GlobalContext generator to the configuration of the tracker.
    /// - Parameters:
    ///   - tag: The label identifying the generator in the tracker.
    ///   - generator: The GlobalContext generator.
    /// - Returns: Whether the adding operation has succeeded.
    @objc
    func add(tag: String, contextGenerator generator: GlobalContext) -> Bool
    /// Remove a GlobalContext generator from the configuration of the tracker.
    /// - Parameter tag: The label identifying the generator in the tracker.
    /// - Returns: Whether the removing operation has succeded.
    @objc
    func remove(tag: String) -> GlobalContext?
}

/// This class allows the setup of Global Contexts which are attached to selected events.
@objc(SPGlobalContextsConfiguration)
public class GlobalContextsConfiguration: Configuration, GlobalContextsConfigurationProtocol {
    @objc
    public var contextGenerators: [String : GlobalContext] = [:]

    @objc
    public func add(tag: String, contextGenerator generator: GlobalContext) -> Bool {
        if (contextGenerators)[tag] != nil {
            return false
        }
        (contextGenerators)[tag] = generator
        return true
    }

    @objc
    public func remove(tag: String) -> GlobalContext? {
        let toDelete = (contextGenerators)[tag]
        if toDelete != nil {
            contextGenerators.removeValue(forKey: tag)
        }
        return toDelete
    }

    // MARK: - NSCopying

    @objc
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = GlobalContextsConfiguration()
        copy.contextGenerators = contextGenerators
        return copy
    }

    // MARK: - NSCoding (No coding possible as we can't encode and decode the contextGenerators)
}