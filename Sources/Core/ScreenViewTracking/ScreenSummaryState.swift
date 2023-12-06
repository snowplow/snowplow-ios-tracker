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

class ScreenSummaryState: State {
    
    static var dateGenerator: () -> TimeInterval = { Date().timeIntervalSince1970 }
    
    private var lastUpdateTimestamp: TimeInterval = ScreenSummaryState.dateGenerator()
    var foregroundSeconds: TimeInterval = 0
    var backgroundSeconds: TimeInterval = 0
    var lastItemIndex: Int?
    var itemsCount: Int?
    
    var data: [String: Any] {
        var data: [String: Any] = [
            "foreground_sec": foregroundSeconds,
            "background_sec": backgroundSeconds
        ]
        if let lastItemIndex = lastItemIndex { data["last_item_index"] = lastItemIndex }
        if let itemsCount = itemsCount { data["items_count"] = itemsCount }
        return data
    }
    
    func updateTransitionToForeground() {
        let currentTimestamp = ScreenSummaryState.dateGenerator()
        
        backgroundSeconds += currentTimestamp - lastUpdateTimestamp
        lastUpdateTimestamp = currentTimestamp
    }
    
    func updateTransitionToBackground() {
        let currentTimestamp = ScreenSummaryState.dateGenerator()
        
        foregroundSeconds += currentTimestamp - lastUpdateTimestamp
        lastUpdateTimestamp = currentTimestamp
    }
    
    func updateForScreenEnd() {
        let currentTimestamp = ScreenSummaryState.dateGenerator()
        
        foregroundSeconds += currentTimestamp - lastUpdateTimestamp
        lastUpdateTimestamp = currentTimestamp
    }
    
    func updateWithListItemView(_ event: ListItemView) {
        lastItemIndex = max(event.index, lastItemIndex ?? 0)
        if let totalItems = event.itemsCount {
            self.itemsCount = max(totalItems, self.itemsCount ?? 0)
        }
    }

}
