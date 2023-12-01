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

class GlobalContextsControllerIQWrapper: GlobalContextsController {
    
    private let controller: GlobalContextsController
    
    init(controller: GlobalContextsController) {
        self.controller = controller
    }

    var contextGenerators: [String : GlobalContext] {
        get { InternalQueue.sync { controller.contextGenerators } }
        set { InternalQueue.sync { controller.contextGenerators = newValue } }
    }

    func add(tag: String, contextGenerator generator: GlobalContext) -> Bool {
        return InternalQueue.sync { controller.add(tag: tag, contextGenerator: generator) }
    }

    func remove(tag: String) -> GlobalContext? {
        return InternalQueue.sync { controller.remove(tag: tag) }
    }

    var tags: [String] {
        return InternalQueue.sync { controller.tags }
    }

}
