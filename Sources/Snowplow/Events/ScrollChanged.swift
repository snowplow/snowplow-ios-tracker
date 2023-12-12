// Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
//
// This program is licensed to you under the Apache License Version 2.0,
// and you may not use this file except in compliance with the Apache License
// Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
// http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the Apache License Version 2.0 is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the Apache License Version 2.0 for the specific
// language governing permissions and limitations there under.

import Foundation

/// Event tracked when a scroll view's scroll position changes.
/// If screen engagement tracking is enabled, the scroll changed events will be aggregated into a `screen_summary` entity.
///
/// Schema: `iglu:com.snowplowanalytics.mobile/scroll_changed/jsonschema/1-0-0`
@objc(SPScrollChanged)
public class ScrollChanged: SelfDescribingAbstract {
    /// Vertical scroll offset in pixels
    public var yOffset: Int?
    /// Horizontal scroll offset in pixels
    public var xOffset: Int?
    /// The height of the scroll view content in pixels
    public var contentHeight: Int?
    /// The width of the scroll view content in pixels
    public var contentWidth: Int?

    /// - Parameters:
    ///   - yOffset: Vertical scroll offset in pixels
    ///   - contentHeight: The height of the scroll view content in pixels
    public init(xOffset: Int? = nil, yOffset: Int? = nil, contentWidth: Int? = nil, contentHeight: Int? = nil) {
        self.yOffset = yOffset
        self.xOffset = xOffset
        self.contentHeight = contentHeight
        self.contentWidth = contentWidth
    }
    
    /// Vertical scroll offset in pixels
    @objc
    public func yOffset(_ yOffset: Int) -> Self {
        self.yOffset = yOffset
        return self
    }
    
    /// Horizontal scroll offset in pixels
    @objc
    public func xOffset(_ xOffset: Int) -> Self {
        self.xOffset = xOffset
        return self
    }
    
    /// The height of the scroll view content in pixels
    @objc
    public func contentHeight(_ contentHeight: Int) -> Self {
        self.contentHeight = contentHeight
        return self
    }
    
    /// The width of the scroll view content in pixels
    @objc
    public func contentWidth(_ contentWidth: Int) -> Self {
        self.contentWidth = contentWidth
        return self
    }
    
    override var schema: String {
        return kSPScrollChangedSchema
    }

    override var payload: [String : Any] {
        var data: [String: Any] = [:]
        if let xOffset = xOffset { data["x_offset"] = xOffset }
        if let yOffset = yOffset { data["y_offset"] = yOffset }
        if let contentWidth = contentWidth { data["content_width"] = contentWidth }
        if let contentHeight = contentHeight { data["content_height"] = contentHeight }
        return data
    }
}
