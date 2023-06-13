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

class RemoteConfigurationBundle: SerializableConfiguration {
    var schema: String
    var configurationVersion: Int
    var configurationBundle: [ConfigurationBundle] = []
    
    init(schema: String, configurationVersion: Int) {
        self.schema = schema
        self.configurationVersion = configurationVersion
    }
    
    init?(dictionary: [String : Any]) {
        guard let schema = dictionary["$schema"] as? String else {
            logDebug(message: "Error assigning: schema")
            return nil
        }
        self.schema = schema
        guard let configurationVersion = dictionary["configurationVersion"] as? Int else {
            logDebug(message: "Error assigning: configurationVersion")
            return nil
        }
        self.configurationVersion = configurationVersion
        guard let bundles = dictionary["configurationBundle"] as? [[String : Any]] else {
            logDebug(message: "Error assigning: configurationBundle")
            return nil
        }
        self.configurationBundle = bundles.map { ConfigurationBundle(dictionary: $0) }.filter { $0 != nil }.map { $0! }
    }
    
    func updateSourceConfig(_ sourceRemoteBundle: RemoteConfigurationBundle) {
        for bundle in configurationBundle {
            if let sourceBundle = sourceRemoteBundle.configurationBundle.first(where: { $0.namespace == bundle.namespace }) {
                bundle.updateSourceConfig(sourceBundle)
            }
        }
    }

    // MARK: - NSCopying

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy: RemoteConfigurationBundle? = nil
        copy?.schema = schema
        copy?.configurationVersion = configurationVersion
        copy?.configurationBundle = configurationBundle.map { $0.copy(with: zone) as! ConfigurationBundle }
        return copy!
    }

    // MARK: - NSSecureCoding
    
    override class var supportsSecureCoding: Bool { return true }

    override func encode(with coder: NSCoder) {
        coder.encode(schema, forKey: "schema")
        coder.encode(configurationVersion, forKey: "configurationVersion")
        coder.encode(configurationBundle, forKey: "configurationBundle")
    }

    required init?(coder: NSCoder) {
        schema = coder.decodeObject(forKey: "schema") as? String ?? ""
        configurationVersion = coder.decodeInteger(forKey: "configurationVersion")
        if let decodeObject = coder.decodeObject(forKey: "configurationBundle") as? [ConfigurationBundle] {
            configurationBundle = decodeObject
        }
    }
}
