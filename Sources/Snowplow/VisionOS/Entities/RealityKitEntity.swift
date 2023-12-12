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

/**
 Properties for the Snowplow entity that represents a RealityKit Entity.
 Entity schema: `iglu:com.apple.realitykit/entity/jsonschema/1-0-0`
 */
@objc(SPRealityKitEntity)
public class RealityKitEntity: NSObject {
    
    /// The stable identity of the entity.
    var id: UUID
    /// The name of the entity.
    var name: String?
    /// The parent entity identity.
    var parentEntityId: UUID?
    /// The identity of the nearest ancestor entity that can act as an anchor.
    var anchorId: UUID?
    /// The stable identity of the scene that owns the entity.
    var sceneId: UUID?
    /// The name of the scene that owns the entity.
    var sceneName: String?
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "id": id.uuidString
        ]
        if let name = name { data["name"] = name }
        if let parentEntityId = parentEntityId { data["parent_entity_id"] = parentEntityId.uuidString }
        if let anchorId = anchorId { data["anchor_id"] = anchorId.uuidString }
        if let sceneId = sceneId { data["scene_id"] = sceneId.uuidString }
        if let sceneName = sceneName { data["scene_name"] = sceneName }
        
        return SelfDescribingJson(schema: visionOsRealityKitEntity, andData: data)
    }
    
    /// - Parameter id: The stable identity of the entity.
    /// - Parameter name: The name of the entity.
    /// - Parameter parentEntityID: The parent entity identity.
    /// - Parameter anchorID: The identity of the nearest ancestor entity that can act as an anchor.
    /// - Parameter sceneID: The stable identity of the scene that owns the entity.
    /// - Parameter sceneName: The name of the scene that owns the entity.
    @objc
    public init(
        id: UUID = UUID(),
        name: String? = nil,
        parentEntityID: UUID? = nil,
        anchorID: UUID? = nil,
        sceneID: UUID? = nil,
        sceneName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.parentEntityId = parentEntityID
        self.anchorId = anchorID
        self.sceneId = sceneID
        self.sceneName = sceneName
    }
}
