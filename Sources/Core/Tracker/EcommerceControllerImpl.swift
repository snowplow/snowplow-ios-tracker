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
    
    func setEcommerceScreen(type: String, language: String? = nil, locale: String? = nil) {
        let plugin = PluginConfiguration(identifier: "ecommercePageTypePluginInternal")
        plugin.entities { _ in
            var data: [String: Any] = ["type": type]
            if let language = language { data["language"] = language }
            if let locale = locale { data["locale"] = locale }
            
            return [SelfDescribingJson(schema: ecommercePageSchema, andData: data)]
        }
        serviceProvider.addPlugin(plugin: plugin)
    }
    
    func setEcommerceUser(id: String, isGuest: Bool? = nil, email: String? = nil) {
        let plugin = PluginConfiguration(identifier: "ecommerceUserPluginInternal")
        plugin.entities { _ in
            var data: [String: Any] = ["id": id]
            if let isGuest = isGuest { data["is_guest"] = isGuest }
            if let email = email { data["email"] = email }
            
            return [SelfDescribingJson(schema: ecommercePageSchema, andData: data)]
        }
        serviceProvider.addPlugin(plugin: plugin)
    }
    
    func removeEcommerceScreen() {
        serviceProvider.removePlugin(identifier: "ecommercePageTypePluginInternal")
    }

    func removeEcommerceUser() {
        serviceProvider.removePlugin(identifier: "ecommerceUserPluginInternal")
    }
}
