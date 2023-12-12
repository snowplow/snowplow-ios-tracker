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
 Properties for the VisionOS window scene entity.
 Entity schema: `iglu:com.apple.swiftui/window/jsonschema/1-0-0`
 */
@objc(SPWindowEntity)
public class WindowEntity: NSObject {
    
    /// A unique string identifier that you can use to open the window.
    public var id: UUID?
    /// A localized string key to use for the window's title in system menus and in the window's title bar. Provide a title that describes the purpose of the window.
    public var titleKey: String?
    /// A specification for the appearance and interaction of a window.
    public var windowStyle: WindowStyle
    
    internal var entity: SelfDescribingJson {
        var data: [String : Any] = [
            "window_style": windowStyle.value
        ]
        if let id = id { data["id"] = id.uuidString }
        if let titleKey = titleKey { data["title_key"] = titleKey }

        return SelfDescribingJson(schema: visionOsWindow, andData: data)
    }
    
    /// - Parameter windowStyle: A specification for the appearance and interaction of a window.
    /// - Parameter id: A unique string identifier that you can use to open the window.
    /// - Parameter titleKey: A localized string key to use for the window's title in system menus and in the window's title bar.
    @objc
    public init(
        windowStyle: WindowStyle,
        id: UUID? = nil,
        titleKey: String? = nil
    ) {
        self.id = id
        self.titleKey = titleKey
        self.windowStyle = windowStyle
    }
}
