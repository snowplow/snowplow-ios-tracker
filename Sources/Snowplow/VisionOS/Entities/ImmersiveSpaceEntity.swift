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

/// The style of a VisionOS immersive space.
@objc(SPImmersionStyle)
public enum ImmersionStyle: Int {
    /// Default immersion style.
    case automatic
    /// Displays unbounded content that obscures pass-through video.
    case full
    /// Displays unbounded content intermixed with other app content.
    case mixed
    /// Content displays with no clipping boundaries applied.
    case progressive
}

extension ImmersionStyle {
    var value: String {
        switch self {
        case .automatic:
            return "automatic"
        case .full:
            return "full"
        case .mixed:
            return "mixed"
        case .progressive:
            return "progressive"
        }
    }
}

/// The visibility of the user's upper limbs in a VisionOS immersive space.
@objc(SPUpperLimbVisibility)
public enum UpperLimbVisibility: Int {
    /// Limbs may be visible or hidden depending on the policies of the component accepting the visibility configuration.
    case automatic
    /// Limbs may be visible.
    case visible
    /// Limbs may be hidden.
    case hidden
}

extension UpperLimbVisibility {
    var value: String {
        switch self {
        case .automatic:
            return "automatic"
        case .visible:
            return "visible"
        case .hidden:
            return "hidden"
        }
    }
}

/**
 Properties for the VisionOS immersive space entity.
 Entity schema: `iglu:com.apple.swiftui/immersive_space/jsonschema/1-0-0`
 */
@objc(SPImmersiveSpaceEntity)
public class ImmersiveSpaceEntity: SelfDescribingJson {
    
    /// Randomly generated ID for the view of the immersive space. Generated by the tracker if not provided by the user.
    @objc
    public var id: UUID
    
    /// The identifier of the immersive space to present.
    @objc
    public var immersiveSpaceId: String?
    
    /// The style of an immersive space.
    public var immersionStyle: ImmersionStyle?
    
    /// Preferred visibility of the user's upper limbs, while an immersive space scene is presented.
    public var upperLimbVisibility: UpperLimbVisibility?
    
    @objc
    override public var data: [String : Any] {
        get {
            var data: [String : Any] = [
                "id": id.uuidString
            ]
            if let immersiveSpaceId = immersiveSpaceId { data["immersive_space_id"] = immersiveSpaceId }
            if let immersionStyle = immersionStyle { data["immersion_style"] = immersionStyle.value }
            if let upperLimbVisibility = upperLimbVisibility { data["upper_limb_visibility"] = upperLimbVisibility.value }
            return data
        }
        set {}
    }
    
    /// - Parameter id: Randomly generated ID for the view of the immersive space by the tracker.
    /// - Parameter immersiveSpaceId: A localized string key to use for the window's title in system menus and in the window's title bar.
    /// - Parameter immersionStyle: A specification for the appearance and interaction of a window.
    /// - Parameter upperLimbVisibility: A specification for the appearance and interaction of a window.
    public init(
        id: UUID = UUID(),
        immersiveSpaceId: String? = nil,
        immersionStyle: ImmersionStyle? = nil,
        upperLimbVisibility: UpperLimbVisibility? =  nil
    ) {
        self.id = id
        self.immersiveSpaceId = immersiveSpaceId
        self.immersionStyle = immersionStyle
        self.upperLimbVisibility = upperLimbVisibility
        super.init(schema: swiftuiImmersiveSpaceSchema, andData: [:])
    }
    
    /// - Parameter id: Randomly generated ID for the view of the immersive space. Generated by the tracker if not provided by the user.
    /// - Parameter immersiveSpaceId: A localized string key to use for the window's title in system menus and in the window's title bar.
    public init(
        id: UUID = UUID(),
        immersiveSpaceId: String? = nil
    ) {
        self.id = id
        self.immersiveSpaceId = immersiveSpaceId
        super.init(schema: swiftuiImmersiveSpaceSchema, andData: [:])
    }
    
    /// The style of an immersive space.
    @objc
    public func immersionStyle(_ immersionStyle: ImmersionStyle) -> Self {
        self.immersionStyle = immersionStyle
        return self
    }
    
    /// Preferred visibility of the user's upper limbs, while an immersive space scene is presented.
    @objc
    public func upperLimbVisibility(_ upperLimbVisibility: UpperLimbVisibility) -> Self {
        self.upperLimbVisibility = upperLimbVisibility
        return self
    }
}
