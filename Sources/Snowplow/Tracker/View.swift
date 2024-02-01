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

#if canImport(SwiftUI)
import SwiftUI
import Foundation

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
@available(watchOS, unavailable)
public extension View {
    /// Sets up screen view tracking to track events when this screen appears.
    /// - Parameter name: Name of the screen
    /// - Parameter contexts: Context entities to attach to the event
    /// - Returns: View with the attached modifier to track screen views
    func snowplowScreen(name: String,
                        entities: [(schema: String, data: [String : Any])] = [],
                        trackerNamespace: String? = nil) -> some View {
        return modifier(ScreenViewModifier(name: name,
                                           entities: entities,
                                           trackerNamespace: trackerNamespace))
    }
    
    /// Sets up tracking of list item views that will be aggregated into the `screen_summary` entity if screen engagement tracking is enabled.
    /// - Parameter index: Index of the item in the list
    /// - Parameter itemsCount: Total number of items in the list
    /// - Returns: View with the attached modifier to track list item views
    func snowplowListItem(index: Int, itemsCount: Int?, trackerNamespace: String? = nil) -> some View {
        return modifier(ListItemViewModifier(index: index,
                                             itemsCount: itemsCount,
                                             trackerNamespace: trackerNamespace))
    }
}

#endif
