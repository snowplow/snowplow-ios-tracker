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

#if canImport(SwiftUI)

import SwiftUI
import Foundation

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
@available(watchOS, unavailable)
internal struct ListItemViewModifier: ViewModifier {
    let index: Int
    let itemsCount: Int?
    let trackerNamespace: String?
    
    /// Get tracker by namespace if configured, otherwise return the default tracker
    private var tracker: TrackerController? {
        if let namespace = trackerNamespace {
            return Snowplow.tracker(namespace: namespace)
        } else {
            return Snowplow.defaultTracker()
        }
    }

    /// Modifies the view to track the list item view when it appears
    func body(content: Content) -> some View {
        content.onAppear {
            trackListItemView()
        }
    }

    func trackListItemView() {
        let event = ListItemView(index: index)
        event.itemsCount = itemsCount
        
        if let tracker = tracker {
            _ = tracker.track(event)
        } else {
            logError(message: "List item view not tracked – tracker not initialized.")
        }
    }
}

#endif
