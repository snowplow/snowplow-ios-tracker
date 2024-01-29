//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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
import XCTest
@testable import SnowplowTracker

#if canImport(SwiftUI)
#if os(iOS) || os(tvOS) || os(macOS)

class TestListItemViewModifier: XCTestCase {
    func testTracksListItemViewEvent() {
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *) {
            let expect = expectation(description: "Event received")
            createTracker { event in
                XCTAssertEqual(1, event.payload["index"] as? Int)
                XCTAssertEqual(5, event.payload["items_count"] as? Int)
                XCTAssertEqual(kSPListItemViewSchema, event.schema)
                expect.fulfill()
            }

            let modifier = ListItemViewModifier(
                index: 1,
                itemsCount: 5,
                trackerNamespace: "listItemViewTracker"
            )
            modifier.trackListItemView()

            wait(for: [expect], timeout: 1)
        }
    }
    
    private func createTracker(afterTrack: @escaping (InspectableEvent) -> ()) {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        
        _ = Snowplow.createTracker(
            namespace: "listItemViewTracker",
            network: networkConfig,
            configurations: [
                EventSink(callback: afterTrack),
                TrackerConfiguration()
                    .installAutotracking(false)
                    .lifecycleAutotracking(false)
                    .screenEngagementAutotracking(false)
            ])
    }
}

private struct ScreenViewExpected: Codable {
    let name: String
}

private struct AnythingEntityExpected: Codable {
    let works: Bool
}

#endif
#endif
