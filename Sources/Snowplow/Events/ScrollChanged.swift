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
    @objc
    public var yOffset: Int
    /// The height of the scroll view content in pixels
    public var contentHeight: Int

    /// - Parameters:
    ///   - yOffset: Vertical scroll offset in pixels
    ///   - contentHeight: The height of the scroll view content in pixels
    @objc
    public init(yOffset: Int, contentHeight: Int) {
        self.yOffset = yOffset
        self.contentHeight = contentHeight
    }
    
    override var schema: String {
        return kSPScrollChangedSchema
    }

    override var payload: [String : Any] {
        return [
            "y_offset": yOffset,
            "content_height": contentHeight
        ]
    }
}
