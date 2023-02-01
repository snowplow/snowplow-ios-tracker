//
//  GlobalContextPluginConfiguration.swift
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

class GlobalContextPluginConfiguration: NSObject, ConfigurationProtocol, PluginConfigurationProtocol {
    private(set) var identifier: String
    private(set) var globalContext: GlobalContext
    private(set) var afterTrackConfiguration: PluginAfterTrackConfiguration? = nil
    private(set) var entitiesConfiguration: PluginEntitiesConfiguration?

    init(identifier: String, globalContext: GlobalContext) {
        self.identifier = identifier
        self.globalContext = globalContext
        self.entitiesConfiguration = PluginEntitiesConfiguration(closure: globalContext.contexts)
    }
}
