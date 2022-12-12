//
// SwiftUITracking.swift
// Snowplow
//
// Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
// License: Apache License Version 2.0
//

#if canImport(SwiftUI)

import SwiftUI
import Foundation

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
@available(watchOS, unavailable)
internal struct ScreenViewModifier: ViewModifier {
    let name: String
    let contexts: [(schema: String, data: [String: Any])]
    let trackerNamespace: String?
    
    func body(content: Content) -> some View {
        content.onAppear {
            let event = ScreenView(name: name)
            event.contexts = contexts.map({ entity in
                if let data = entity.data as? [String : NSObject] {
                    return SelfDescribingJson(schema: entity.schema, andDictionary: data)
                } else {
                    logError(message: "Failed to process context entity for screen view.")
                }
                return nil
            }).filter({ $0 != nil }).map({ $0! })
            
            var tracker: TrackerController?
            if let namespace = trackerNamespace {
                tracker = Snowplow.tracker(namespace: namespace)
            } else {
                tracker = Snowplow.defaultTracker()
            }
            
            if let tracker = tracker {
                _ = tracker.track(event)
            } else {
                logError(message: "Screen view not tracked – tracker not initialized.")
            }
        }
    }
}

#endif
