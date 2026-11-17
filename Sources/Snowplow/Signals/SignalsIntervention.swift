//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

/// An intervention delivered by Signals when its criteria matched for the current user or session.
@objc(SPSignalsIntervention)
public class SignalsIntervention: NSObject {
    /// Unique ID of this delivery of the intervention.
    @objc
    public let interventionId: String
    /// Name of the intervention definition.
    @objc
    public let name: String
    /// Version of the intervention definition.
    @objc
    public let version: Int
    /// Attribute values attached to the intervention, by name.
    @objc
    public let attributes: [String: Any]
    /// The attribute key and identifier the intervention was triggered for.
    @objc
    public let targetAttributeKey: SignalsTargetAttributeKey?

    /// Creates an intervention, e.g. to test intervention handlers.
    @objc
    public init(interventionId: String,
                name: String,
                version: Int,
                attributes: [String: Any] = [:],
                targetAttributeKey: SignalsTargetAttributeKey? = nil) {
        self.interventionId = interventionId
        self.name = name
        self.version = version
        self.attributes = attributes
        self.targetAttributeKey = targetAttributeKey
        super.init()
    }

    /// Parses an intervention from the JSON of an interventions stream message.
    convenience init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
              let version = json["version"] as? Int else {
            return nil
        }
        var targetAttributeKey: SignalsTargetAttributeKey?
        if let key = json["target_attribute_key"] as? [String: Any],
           let keyName = key["name"] as? String,
           let keyId = key["id"] as? String {
            targetAttributeKey = SignalsTargetAttributeKey(name: keyName, id: keyId)
        }
        self.init(interventionId: json["intervention_id"] as? String ?? "",
                  name: name,
                  version: version,
                  attributes: json["attributes"] as? [String: Any] ?? [:],
                  targetAttributeKey: targetAttributeKey)
    }

    /// Data of the intervention_instance entity attached to the intervention measurement events.
    var entityData: [String: Any] {
        var data: [String: Any] = [
            "intervention_id": interventionId,
            "name": name,
            "version": version,
            "attributes": attributes
                .sorted { $0.key < $1.key }
                .map { ["attribute": $0.key, "value": $0.value] }
        ]
        if let key = targetAttributeKey {
            data["attributeKey"] = ["name": key.name, "id": key.id]
        }
        return data
    }
}

/// An attribute key and the identifier an intervention was triggered for.
@objc(SPSignalsTargetAttributeKey)
public class SignalsTargetAttributeKey: NSObject {
    /// Name of the attribute key, e.g. `client_session_user_id`.
    @objc
    public let name: String
    /// Identifier (value) of the attribute key.
    @objc(identifier)
    public let id: String

    /// Creates a target attribute key.
    @objc
    public init(name: String, id: String) {
        self.name = name
        self.id = id
        super.init()
    }
}
