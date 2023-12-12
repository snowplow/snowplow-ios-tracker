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
 Properties for the VisionOS window group entity.
 Entity schema: `iglu:com.apple.swiftui/window_group/jsonschema/1-0-0`
 */
@objc(SPWindowGroupEntity)
public class WindowGroupEntity: NSObject {
    
    /// Randomly generated ID for the current window within the group.
    public var id: UUID
    /// A localized string key to use for the window's title in system menus and in the window's title bar. Provide a title that describes the purpose of the window.
    public var titleKey: String?
    /// A string that uniquely identifies the window group. Identifiers must be unique among the window groups in your app.
    public var windowGroupId: String?
    /// A specification for the appearance and interaction of a window.
    public var windowStyle: WindowStyle
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "id": id.uuidString
        ]
        if let titleKey = titleKey { data["title_key"] = titleKey }
        if let windowGroupId = windowGroupId { data["window_group_id"] = windowGroupId }
        data["window_style"] = windowStyle.value

        return SelfDescribingJson(schema: visionOsWindowGroup, andData: data)
    }
    
    /// - Parameter id: Randomly generated ID for the current window within the group.
    /// - Parameter titleKey: A localized string key to use for the window's title in system menus and in the window's title bar.
    /// - Parameter windowGroupID: A string that uniquely identifies the window group.
    /// - Parameter windowStyle: A specification for the appearance and interaction of a window.
    @objc
    public init(
        id: UUID = UUID(),
        titleKey: String? = nil,
        windowGroupID: String? = nil,
        windowStyle: WindowStyle
    ) {
        self.id = id
        self.titleKey = titleKey
        self.windowGroupId = windowGroupID
        self.windowStyle = windowStyle
    }
}
