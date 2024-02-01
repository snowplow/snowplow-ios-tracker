// Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

/// Event tracking the view of an item in a list.
/// If screen engagement tracking is enabled, the list item view events will be aggregated into a `screen_summary` entity.
///
/// Schema: `iglu:com.snowplowanalytics.mobile/list_item_view/jsonschema/1-0-0`
@objc(SPListItemView)
public class ListItemView: SelfDescribingAbstract {
    /// Index of the item in the list
    @objc
    public var index: Int
    /// Total number of items in the list
    public var itemsCount: Int?

    /// - Parameters:
    ///   - index: Index of the item in the list
    @objc
    public init(index: Int) {
        self.index = index
    }
    
    /// - Parameters:
    ///   - index: Index of the item in the list
    ///   - totalItems: Total number of items in the list
    @objc
    public init(index: Int, totalItems: Int) {
        self.index = index
        self.itemsCount = totalItems
    }

    override var schema: String {
        return kSPListItemViewSchema
    }

    override var payload: [String : Any] {
        var data = [
            "index": index
        ]
        if let itemsCount = itemsCount {
            data["items_count"] = itemsCount
        }
        return data
    }
}
