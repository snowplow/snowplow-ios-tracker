//
//  TestScreenViewModifier.swift
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Jonathan Almeida
//  License: Apache License Version 2.0
//

import Foundation
import XCTest
@testable import SnowplowTracker

#if canImport(SwiftUI)
#if os(iOS) || os(tvOS) || os(macOS)

class TestScreenViewModifier: XCTestCase {
    var tracker: TrackerController?
    
    override func setUp() {
        super.setUp()
        
        tracker = Snowplow.createTracker(namespace: "ns",
                                         network: NetworkConfiguration(endpoint: Micro.endpoint))!
        
        Micro.setUpMockerIgnores()
        wait(for: [Micro.reset()], timeout: Micro.timeout)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTracksScreenViewWithContextEntity() {
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *) {
            let modifier = ScreenViewModifier(
                name: "screen-1",
                contexts: [
                    (
                        schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0",
                        data: [
                            "works": true
                        ]
                    )
                ],
                trackerNamespace: "ns"
            )
            modifier.trackScreenView()
            
            wait(for: [
                Micro.expectSelfDescribingEvent() { (actual: ScreenViewExpected) in
                    XCTAssertEqual("screen-1", actual.name)
                },
                Micro.expectEventContext(schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0") { (actual: AnythingEntityExpected) in
                    XCTAssertTrue(actual.works)
                }
            ], timeout: Micro.timeout)
        }
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
