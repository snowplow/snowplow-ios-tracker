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

/// A specification for the appearance and interaction of a window.
@objc(SPWindowStyle)
public enum WindowStyle: Int {
    /// Default window style.
    case automatic
    /// Hides both the window’s title and the backing of the titlebar area.
    case hiddenTitleBar
    /// Plain window style.
    case plain
    /// Displays the title bar section of the window.
    case titleBar
    /// Creates a 3D volumetric window.
    case volumetric
}

extension WindowStyle {
    var value: String {
        switch self {
        case .automatic:
            return "automatic"
        case .hiddenTitleBar:
            return "hiddenTitleBar"
        case .plain:
            return "plain"
        case .titleBar:
            return "titleBar"
        case .volumetric:
            return "volumetric"
        }
    }
}
