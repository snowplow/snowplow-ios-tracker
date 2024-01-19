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

/** Event for a visionOS immersive space being opened. */
public class OpenImmersiveSpaceEvent: SelfDescribingAbstract {
    
    /// The identifier of the immersive space to present.
    public var id: String
    
    /// UUID for the view of the immersive space.
    public var viewId: UUID?
    
    /// The style of an immersive space.
    public var immersionStyle: ImmersionStyle?
    
    /// Preferred visibility of the user's upper limbs, while an immersive space scene is presented.
    public var upperLimbVisibility: UpperLimbVisibility?
    
    override var schema: String {
        return swiftuiOpenImmersiveSpaceSchema
    }
    
    override var payload: [String : Any] {
        return [:]
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get {
            var entities = [SelfDescribingJson]()
            let space = ImmersiveSpaceEntity(
                id: self.id,
                viewId: self.viewId,
                immersionStyle: self.immersionStyle,
                upperLimbVisibility: self.upperLimbVisibility
            )
            entities.append(space)
            return entities
        }
    }
    
    /// - Parameter id: A localized string key to use for the window's title in system menus and in the window's title bar.
    /// - Parameter viewId: UUID for the view of the immersive space.
    /// - Parameter immersionStyle: A specification for the appearance and interaction of a window.
    /// - Parameter upperLimbVisibility: A specification for the appearance and interaction of a window.
    public init(
        id: String,
        viewId: UUID? = nil,
        immersionStyle: ImmersionStyle? = nil,
        upperLimbVisibility: UpperLimbVisibility? =  nil
    ) {
        self.id = id
        self.viewId = viewId
        self.immersionStyle = immersionStyle
        self.upperLimbVisibility = upperLimbVisibility
    }
}
