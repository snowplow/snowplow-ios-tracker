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

/** Event for a SwiftUI window group being opened. */
public class OpenWindowEvent: SelfDescribingAbstract {
    
    /// A string that uniquely identifies the window group. Identifiers must be unique among the window groups in your app.
    public var id: String
    
    /// UUID for the current window within the group.
    public var windowId: UUID?
    
    /// A localized string key to use for the window's title in system menus and in the window's title bar. Provide a title that describes the purpose of the window.
    public var titleKey: String?

    /// A specification for the appearance and interaction of a window.
    public var windowStyle: WindowStyle?
    
    override var schema: String {
        return swiftuiOpenWindowSchema
    }
    
    override var payload: [String : Any] {
        return [:]
    }
    
    override internal var entitiesForProcessing: [SelfDescribingJson]? {
        get {
            var entities = [SelfDescribingJson]()
            let windowGroup = WindowGroupEntity(
                id: self.id,
                windowId: self.windowId,
                titleKey: self.titleKey,
                windowStyle: self.windowStyle
            )
            entities.append(windowGroup)
            return entities
        }
    }
    
    /// - Parameter id: A string that uniquely identifies the window group.
    /// - Parameter windowId: UUID for the current window within the group.
    /// - Parameter titleKey: A localized string key to use for the window's title in system menus and in the window's title bar.
    /// - Parameter windowStyle: A specification for the appearance and interaction of a window.
    public init(
        id: String,
        windowId: UUID? = nil,
        titleKey: String? = nil,
        windowStyle: WindowStyle? = nil
    ) {
        self.id = id
        self.windowId = windowId
        self.titleKey = titleKey
        self.windowStyle = windowStyle
    }
}
