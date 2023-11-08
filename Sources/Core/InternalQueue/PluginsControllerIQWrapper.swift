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

class PluginsControllerIQWrapper: PluginsController {
    
    private let controller: PluginsController
    
    init(controller: PluginsController) {
        self.controller = controller
    }
    
    var identifiers: [String] {
        return InternalQueue.sync { controller.identifiers }
    }
    
    func add(plugin: PluginIdentifiable) {
        InternalQueue.sync { controller.add(plugin: plugin) }
    }

    func remove(identifier: String) {
        InternalQueue.sync { controller.remove(identifier: identifier) }
    }
}
