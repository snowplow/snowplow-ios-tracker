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

class MediaSchemata {
    private static let schemaPrefix = "iglu:com.snowplowanalytics.snowplow.media/"
    private static let schemaSuffix = "/jsonschema/1-0-0"
    static let playerSchema = "\(schemaPrefix)player\(schemaSuffix)"
    static let sessionSchema = "\(schemaPrefix)session\(schemaSuffix)"
    static let adSchema = "\(schemaPrefix)ad\(schemaSuffix)"
    static let adBreakSchema = "\(schemaPrefix)ad_break\(schemaSuffix)"
    
    static func eventSchema(_ eventName: String) -> String {
        return "\(schemaPrefix)\(eventName)_event\(schemaSuffix)"
    }
}
