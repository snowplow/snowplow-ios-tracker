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

class GlobalContextsControllerImpl: Controller, GlobalContextsController {

    var contextGenerators: [String : GlobalContext] {
        get {
            var contexts: [String : GlobalContext] = [:]
            for configuration in pluginConfigurations {
                contexts[configuration.identifier] = configuration.globalContext
            }
            return contexts
        }
        set {
            for configuration in pluginConfigurations {
                serviceProvider.pluginsController.remove(identifier: configuration.identifier)
            }
            for (identifier, globalContext) in newValue {
                let plugin = GlobalContextPluginConfiguration(identifier: identifier,
                                                              globalContext: globalContext)
                serviceProvider.pluginsController.add(plugin: plugin)
            }
        }
    }

    func add(tag: String, contextGenerator generator: GlobalContext) -> Bool {
        if tags.contains(tag) {
            return false
        }
        let plugin = GlobalContextPluginConfiguration(identifier: tag,
                                                      globalContext: generator)
        serviceProvider.pluginsController.add(plugin: plugin)
        return true
    }

    func remove(tag: String) -> GlobalContext? {
        let configuration = pluginConfigurations.first { configuration in
            configuration.identifier == tag
        }
        serviceProvider.pluginsController.remove(identifier: tag)
        return configuration?.globalContext
    }

    var tags: [String] {
        return pluginConfigurations.map { $0.identifier }
    }

    // MARK: - Private methods

    private var pluginConfigurations: [GlobalContextPluginConfiguration] {
        return serviceProvider.pluginConfigurations.filter { configuration in
            configuration is GlobalContextPluginConfiguration
        }.map { configuration in
            configuration as! GlobalContextPluginConfiguration
        }
    }
}
