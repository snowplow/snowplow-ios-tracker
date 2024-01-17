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
public class ImmersiveSpaceEntity: SelfDescribingJson {
    
    /// The identifier of the immersive space to present.
    public var id: String
    
    /// UUID for the view of the immersive space.
    public var uuid: UUID?
    
    /// The style of an immersive space.
    public var immersionStyle: ImmersionStyle?
    
    /// Preferred visibility of the user's upper limbs, while an immersive space scene is presented.
    public var upperLimbVisibility: UpperLimbVisibility?
    
    override public var data: [String : Any] {
        get {
            var data: [String : Any] = [
                "id": id
            ]
            if let uuid = uuid { data["uuid"] = uuid.uuidString }
            if let immersionStyle = immersionStyle { data["immersion_style"] = immersionStyle.value }
            if let upperLimbVisibility = upperLimbVisibility { data["upper_limb_visibility"] = upperLimbVisibility.value }
            return data
        }
        set {}
    }
    
    /// - Parameter id: A localized string key to use for the window's title in system menus and in the window's title bar.
    /// - Parameter uuid: UUID for the view of the immersive space.
    /// - Parameter immersionStyle: A specification for the appearance and interaction of a window.
    /// - Parameter upperLimbVisibility: A specification for the appearance and interaction of a window.
    public init(
        id: String,
        uuid: UUID? = nil,
        immersionStyle: ImmersionStyle? = nil,
        upperLimbVisibility: UpperLimbVisibility? =  nil
    ) {
        self.id = id
        self.uuid = uuid
        self.immersionStyle = immersionStyle
        self.upperLimbVisibility = upperLimbVisibility
        super.init(schema: swiftuiImmersiveSpaceSchema, andData: [:])
    }
}
