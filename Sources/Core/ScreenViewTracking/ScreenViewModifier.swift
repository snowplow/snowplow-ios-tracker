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
internal struct ScreenViewModifier: ViewModifier {
    let name: String
    let entities: [(schema: String, data: [String: Any])]
    let trackerNamespace: String?
    
    /// Transform the context entity definitions to self-describing objects
    private var processedEntities: [SelfDescribingJson] {
        return entities.map({ entity in
            return SelfDescribingJson(schema: entity.schema, andDictionary: entity.data)
        })
    }
    
    /// Get tracker by namespace if configured, otherwise return the default tracker
    private var tracker: TrackerController? {
        if let namespace = trackerNamespace {
            return Snowplow.tracker(namespace: namespace)
        } else {
            return Snowplow.defaultTracker()
        }
    }

    /// Modifies the view to track the screen view when it appears
    func body(content: Content) -> some View {
        content.onAppear {
            trackScreenView()
        }
    }

    func trackScreenView() {
        let event = ScreenView(name: name)
        event.entities = processedEntities

        if let tracker = tracker {
            _ = tracker.track(event)
        } else {
            logError(message: "Screen view not tracked – tracker not initialized.")
        }
    }
}

#endif
