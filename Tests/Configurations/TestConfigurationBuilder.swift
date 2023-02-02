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

import XCTest
@testable import SnowplowTracker

class TestConfigurationBuilder: XCTestCase {
#if swift(>=5.4)
    func testCreateTrackerUsingBuilder() {
        let pluginName: String? = "plugin"
        let tracker = Snowplow.createTracker(namespace: "ns",
                                             endpoint: "https://snowplow.io") {
            TrackerConfiguration()
                .installAutotracking(false)
                .exceptionAutotracking(false)
                .appId("app_id")
            
            SubjectConfiguration()
                .domainUserId("xxx")
            
            EmitterConfiguration()
                .threadPoolSize(33)
            
            if let pluginName = pluginName {
                PluginConfiguration(identifier: pluginName)
                    .afterTrack { event in }
            }
        }
        
        XCTAssertEqual("ns", tracker?.namespace)
        XCTAssertEqual("app_id", tracker?.appId)
        XCTAssertTrue(tracker?.network?.endpoint?.starts(with: "https://snowplow.io") ?? false)
        XCTAssertEqual(.post, tracker?.network?.method)
        XCTAssertFalse(tracker!.installAutotracking)
        XCTAssertFalse(tracker!.exceptionAutotracking)
        XCTAssertEqual("xxx", tracker?.subject?.domainUserId)
        XCTAssertEqual(33, tracker?.emitter?.threadPoolSize)
        XCTAssertEqual(["plugin"], tracker?.plugins.identifiers)
    }
#endif
}
