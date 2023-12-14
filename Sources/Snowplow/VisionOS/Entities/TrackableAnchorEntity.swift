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

/// The details of a ReferenceImage used for an ImageAnchor.
@objc(SPImageAnchorDetails)
public protocol ImageAnchorDetails {
    var widthDetails: Double { get }
    var heightDetails: Double { get }
    var descriptionDetails: String { get }
    var nameDetails: String? { get }
}

extension ARReferenceImage: ImageAnchorDetails {
    public var widthDetails: Double { return self.physicalSize.width }
    public var heightDetails: Double { return self.physicalSize.height }
    public var descriptionDetails: String { return self.description }
    public var nameDetails: String? { return self.name }
}

/**
 Properties for the ARKit trackable anchor entity.
 Entity schema: `iglu:com.apple.arkit/trackable_anchor/jsonschema/1-0-0`
 */
@objc(SPTrackableAnchorEntity)
public class TrackableAnchorEntity: SelfDescribingJson {
    
    /// A globally unique ID for a TrackableAnchor that distinguishes this anchor from all other anchors.
    @objc
    public var id: UUID
    
    /// Type of the anchor.
    public var type: TrackableAnchorType?
    
    /// Textual description of the anchor.
    @objc
    public var anchorDescription: String?
    
    /// Whether ARKit is tracking the anchor.
    @objc
    public var isTracked: Bool
    
    /// For ImageAnchors, the reference image tracked.
    public var referenceImage: ImageAnchorDetails?
    
    @objc
    override public var data: [String : Any] {
        get {
            var data: [String : Any] = [
                "id": id.uuidString
            ]
            if let type = type { data["type"] = type.value }
            if let anchorDescription = anchorDescription { data["description"] = anchorDescription }
            data["is_tracked"] = isTracked
            if let referenceImage = referenceImage {
                let imageData: [String : Any] = [
                    "physical_size": "\(referenceImage.widthDetails)x\(referenceImage.heightDetails)",
                    "description": referenceImage.descriptionDetails
                ]
                if let name = referenceImage.nameDetails { data["name"] = name }
                data["reference_image"] = imageData
            }
            return data
        }
        set {}
    }
    
    /// - Parameter id: A globally unique ID for a device anchor that distinguishes this anchor from all other anchors.
    /// - Parameter type: Type of the anchor.
    /// - Parameter anchorDescription: Textual description of the anchor.
    /// - Parameter isTracked: Whether ARKit is tracking the anchor.
    /// - Parameter referenceImage: For ImageAnchors, the reference image tracked
    public init(
        id: UUID = UUID(),
        type: TrackableAnchorType? = nil,
        anchorDescription: String? = nil,
        isTracked: Bool,
        referenceImage: ImageAnchorDetails? = nil
    ) {
        self.id = id
        self.type = type
        self.anchorDescription = anchorDescription
        self.isTracked = isTracked
        self.referenceImage = referenceImage
        super.init(schema: visionOsTrackableAnchor, andData: [:])
    }
    
    /// - Parameter id: A globally unique ID for a device anchor that distinguishes this anchor from all other anchors.
    /// - Parameter anchorDescription: Textual description of the anchor.
    /// - Parameter isTracked: Whether ARKit is tracking the anchor.
    @objc
    public init(
        id: UUID = UUID(),
        anchorDescription: String? = nil,
        isTracked: Bool
    ) {
        self.id = id
        self.anchorDescription = anchorDescription
        self.isTracked = isTracked
        super.init(schema: visionOsTrackableAnchor, andData: [:])
    }
    
    /// Type of the anchor.
    @objc
    public func type(_ type: TrackableAnchorType) -> Self {
        self.type = type
        return self
    }
    
    /// For ImageAnchors, the reference image tracked.
    @objc
    public func referenceImage(_ referenceImage: ImageAnchorDetails) -> Self {
        self.referenceImage = referenceImage
        return self
    }
}
