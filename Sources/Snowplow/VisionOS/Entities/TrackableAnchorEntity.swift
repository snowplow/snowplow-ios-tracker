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
import ARKit

/// The type of TrackableAnchor.
@objc(SPTrackableAnchorType)
public enum TrackableAnchorType: Int {
    /// A DeviceAnchor.
    case device
    /// A WorldAnchor.
    case world
    /// A HandAnchor.
    case hand
    /// An ImageAnchor.
    case image
}

extension TrackableAnchorType {
    var value: String {
        switch self {
        case .device:
            return "device"
        case .world:
            return "world"
        case .hand:
            return "hand"
        case .image:
            return "image"
        }
    }
}

/**
 Properties for the ARKit trackable anchor entity.
 Entity schema: `iglu:com.apple.arkit/trackable_anchor/jsonschema/1-0-0`
 */
@objc(SPTrackableAnchorEntity)
public class TrackableAnchorEntity: NSObject {
    
    /// A globally unique ID for a device anchor.
    public var id: UUID
    /// Type of the anchor.
    public var type: TrackableAnchorType?
    /// Textual description of the anchor.
    public var anchorDescription: String?
    /// Whether ARKit is tracking the anchor.
    public var isTracked: Bool
    /// The reference image that this ImageAnchor tracks.
    public var referenceImage: ARReferenceImage?
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "id": id.uuidString
        ]
        if let type = type { data["type"] = type }
        if let anchorDescription = anchorDescription { data["description"] = anchorDescription }
        data["is_tracked"] = isTracked
        if let referenceImage = referenceImage {
            var imageData: [String : Any] = [
                "physical_size": "\(referenceImage.physicalSize.width)x\(referenceImage.physicalSize.height)",
                "description": referenceImage.description
            ]
            if let name = referenceImage.name { data["name"] = name }
            data["reference_image"] = imageData
        }

        return SelfDescribingJson(schema: visionOsTrackableAnchor, andData: data)
    }
    
    /// - Parameter id: A globally unique ID for a device anchor.
    /// - Parameter type: Type of the anchor.
    /// - Parameter anchorDescription: Textual description of the anchor.
    /// - Parameter isTracked: Whether ARKit is tracking the anchor.
    /// - Parameter referenceImage: The reference image that this ImageAnchor tracks.
    public init(
        id: UUID = UUID(),
        type: TrackableAnchorType? = nil,
        anchorDescription: String? = nil,
        isTracked: Bool,
        referenceImage: ARReferenceImage? = nil
    ) {
        self.id = id
        self.type = type
        self.anchorDescription = anchorDescription
        self.isTracked = isTracked
        self.referenceImage = referenceImage
    }
    
    /// - Parameter id: A globally unique ID for a device anchor.
    /// - Parameter anchorDescription: Textual description of the anchor.
    /// - Parameter isTracked: Whether ARKit is tracking the anchor.
    /// - Parameter referenceImage: The reference image that this image anchor tracks.
    @objc
    public init(
        id: UUID = UUID(),
        anchorDescription: String? = nil,
        isTracked: Bool,
        referenceImage: ARReferenceImage? = nil
    ) {
        self.id = id
        self.anchorDescription = anchorDescription
        self.isTracked = isTracked
        self.referenceImage = referenceImage
    }
}
