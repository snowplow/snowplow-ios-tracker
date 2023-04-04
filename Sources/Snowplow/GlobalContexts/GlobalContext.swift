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

/// Block signature for context generators, takes event information and generates a context.
/// - Parameter event: informations about the event to process.
/// - Returns: a user-generated self-describing JSON.
public typealias GeneratorBlock = (InspectableEvent) -> [SelfDescribingJson]
/// Block signature for context filtering, takes event information and decide if the context needs to be generated.
/// - Parameter event: informations about the event to process.
/// - Returns: whether the context has to be generated.
public typealias FilterBlock = (InspectableEvent) -> Bool
// MARK: - SPContextGenerator

// MARK: - SPGlobalContext

@objc(SPGlobalContext)
public class GlobalContext: NSObject {
    private var generator: GeneratorBlock
    private var filter: FilterBlock?
    
    /// Initialize a Global Context generator with a custom SPContextGenerator.
    /// - Parameter generator: Implementation of SPContextGenerator protocol.
    @objc
    public convenience init(contextGenerator generator: ContextGenerator) {
        self.init(generator: { event in
            return generator.generator(from: event) ?? []
        }, filter: { event in
            return generator.filter(from: event)
        })
    }

    /// Initialize a Global Context generator with static contexts.
    /// - Parameter staticContexts: Static contexts added to all the events.
    @objc
    public convenience init(staticContexts: [SelfDescribingJson]) {
        self.init(generator: { event in
            return staticContexts
        })
    }

    /// Initialize a Global Context generator with a generator block.
    /// - Parameter generator: Generator block able to generate multiple contexts.
    @objc
    public convenience init(generator: @escaping GeneratorBlock) {
        self.init(generator: generator, filter: nil)
    }

    /// Initialize a Global Context generator with static contexts and a ruleset filter.
    /// - Parameters:
    ///   - staticContexts: Static contexts added to all the events conforming with `ruleset`.
    ///   - ruleset: Rule set to apply to events to check weather or not the contexts have to be added.
    @objc
    public convenience init(staticContexts: [SelfDescribingJson], ruleset: SchemaRuleset) {
        self.init(generator: { event in
            return staticContexts
        }, filter: ruleset.filterBlock)
    }

    /// Initialize a Global Context generator with static contexts and a ruleset filter.
    /// - Parameters:
    ///   - generator: Generator block able to generate multiple contexts.
    ///   - ruleset: Rule set to apply to events to check weather or not the contexts have to be added.
    @objc
    public convenience init(generator: @escaping GeneratorBlock, ruleset: SchemaRuleset) {
        self.init(generator: generator, filter: ruleset.filterBlock)
    }

    /// Initialize a Global Context generator with static contexts and a ruleset filter.
    /// - Parameters:
    ///   - staticContexts: Static contexts added to all the events conforming with `ruleset`.
    ///   - filter: Filter to apply to events to check weather or not the contexts have to be added.
    @objc
    public convenience init(staticContexts: [SelfDescribingJson], filter: @escaping FilterBlock) {
        self.init(generator: { event in
            return staticContexts
        }, filter: filter)
    }

    /// Initialize a Global Context generator with static contexts and a ruleset filter.
    /// - Parameters:
    ///   - generator: Generator block able to generate multiple contexts.
    ///   - filter: Filter to apply to events to check weather or not the contexts have to be added.
    @objc
    public required init(generator: @escaping GeneratorBlock, filter: FilterBlock?) {
        self.generator = generator
        self.filter = filter
    }

    /// Generate contexts based on event details and internal filter and generator.
    /// - Parameter event: Event details used to filter and generate contexts.
    /// - Returns: Generated contexts.
    @objc
    public func contexts(from event: InspectableEvent) -> [SelfDescribingJson] {
        if let filter = filter {
            if !filter(event) {
                return []
            }
        }
        return generator(event)
    }
}
