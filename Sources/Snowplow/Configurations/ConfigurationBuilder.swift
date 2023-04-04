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

#if swift(>=5.4)
/// Result builder used to build a list of configuration objects when creating a new tracker
@resultBuilder
public struct ConfigurationBuilder {
    public static func buildExpression(_ expression: [ConfigurationProtocol]) -> [ConfigurationProtocol] {
        return expression
    }
    
    public static func buildExpression(_ expression: ConfigurationProtocol) -> [ConfigurationProtocol] {
        return [expression]
    }
    
    public static func buildBlock() -> [ConfigurationProtocol] {
        return []
    }
    
    public static func buildBlock(_ configurations: ConfigurationProtocol...) -> [ConfigurationProtocol] {
        return configurations.map { $0 }
    }
    
    public static func buildBlock(_ configurations: [ConfigurationProtocol]...) -> [ConfigurationProtocol] {
        return configurations.flatMap { $0 }
    }
    
    public static func buildArray(_ configurations: [[ConfigurationProtocol]]) -> [ConfigurationProtocol] {
        return configurations.flatMap { $0 }
    }
    
    public static func buildArray(_ configurations: [ConfigurationProtocol]) -> [ConfigurationProtocol] {
        return configurations
    }
    
    public static func buildEither(first configurations: [ConfigurationProtocol]) -> [ConfigurationProtocol] {
        return configurations
    }
    
    public static func buildEither(first configuration: ConfigurationProtocol) -> [ConfigurationProtocol] {
        return [configuration]
    }
    
    public static func buildEither(second configuration: [ConfigurationProtocol]) -> [ConfigurationProtocol] {
        return configuration
    }
    
    public static func buildEither(second configuration: ConfigurationProtocol) -> [ConfigurationProtocol] {
        return [configuration]
    }
    
    public static func buildOptional(_ configurations: [ConfigurationProtocol]?) -> [ConfigurationProtocol] {
        return configurations ?? []
    }
}
#endif
