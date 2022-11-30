//
//  SPGlobalContextsControllerImpl.swift
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

class GlobalContextsControllerImpl: Controller, GlobalContextsController {

    var contextGenerators: [String : GlobalContext] {
        get {
            return tracker.globalContextGenerators
        }
        set {
            tracker.globalContextGenerators = newValue
        }
    }

    func add(tag: String, contextGenerator generator: GlobalContext) -> Bool {
        return tracker.add(generator, tag: tag)
    }

    func remove(tag: String) -> GlobalContext? {
        return tracker.removeGlobalContext(tag)
    }

    var tags: [String] {
        return tracker.globalContextTags
    }

    // MARK: - Private methods

    private var tracker: Tracker {
        return serviceProvider.tracker
    }
}
