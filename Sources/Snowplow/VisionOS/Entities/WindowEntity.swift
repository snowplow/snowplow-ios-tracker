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
public class WindowEntity: SelfDescribingJson {
    
    /// A unique string identifier that you can use to open the window.
    @objc
    public var id: String?
    
    /// A string to use for the window's title in system menus and in the window's title bar. Provide a title that describes the purpose of the window.
    @objc
    public var title: String?
    
    /// A specification for the appearance and interaction of a window.
    public var windowStyle: WindowStyle?
    
    @objc
    override public var data: [String : Any] {
        get {
            var data: [String : Any] = [:]
            if let id = id { data["id"] = id }
            if let title = title { data["title"] = title }
            if let style = windowStyle { data["window_style"] = style.value }
            return data
        }
        set {}
    }
    
    /// - Parameter id: A unique string identifier that you can use to open the window.
    /// - Parameter title: A string to use for the window's title in system menus and in the window's title bar.
    /// - Parameter windowStyle: A specification for the appearance and interaction of a window.
    public init(
        id: String? = nil,
        title: String? = nil,
        windowStyle: WindowStyle? = nil
    ) {
        self.id = id
        self.title = title
        self.windowStyle = windowStyle
        super.init(schema: visionOsWindow, andData: [:])
    }
    
    /// - Parameter id: A unique string identifier that you can use to open the window.
    /// - Parameter title: A string to use for the window's title in system menus and in the window's title bar.
    @objc
    public init(
        id: String? = nil,
        title: String? = nil
    ) {
        self.id = id
        self.title = title
        super.init(schema: visionOsWindow, andData: [:])
    }
    
    /// A specification for the appearance and interaction of a window.
    @objc
    public func windowStyle(_ windowStyle: WindowStyle) -> Self {
        self.windowStyle = windowStyle
        return self
    }
}
