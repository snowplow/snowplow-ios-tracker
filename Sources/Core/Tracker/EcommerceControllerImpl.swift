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

class EcommerceControllerImpl: Controller, EcommerceController {
    
    func setEcommerceScreen(_ screen: EcommerceScreenEntity) {
        let plugin = PluginConfiguration(identifier: "ecommercePageTypePluginInternal")
        _ = plugin.entities { _ in [screen.entity] }
        serviceProvider.addPlugin(plugin: plugin)
    }
    
    func setEcommerceUser(_ user: EcommerceUserEntity) {
        let plugin = PluginConfiguration(identifier: "ecommerceUserPluginInternal")
        _ = plugin.entities { _ in [user.entity] }
        serviceProvider.addPlugin(plugin: plugin)
    }
    
    func removeEcommerceScreen() {
        serviceProvider.removePlugin(identifier: "ecommercePageTypePluginInternal")
    }

    func removeEcommerceUser() {
        serviceProvider.removePlugin(identifier: "ecommerceUserPluginInternal")
    }
}
