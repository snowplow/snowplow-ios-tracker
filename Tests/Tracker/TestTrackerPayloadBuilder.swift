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

import XCTest
@testable import SnowplowTracker

class TestTrackerPayloadBuilder: XCTestCase {

    func testTrackerPayload() {
        let subject = Subject(platformContext: true, geoLocationContext: true)
        
        let trackerData = TrackerData(appId: "anAppId", trackerNamespace: "aNamespace")
        trackerData.subject = subject
        trackerData.devicePlatform = .general
        trackerData.base64Encoded = false
        trackerData.sessionContext = true
        trackerData.foregroundTimeout = 300
        trackerData.backgroundTimeout = 150
        
        let event = Structured(category: "Category", action: "Action")
        let trackerEvent = TrackerEvent(event: event, state: nil)
        let stateManager = StateManager()
        
        let payloadBuilder = TrackerPayloadBuilder()
        var payload = payloadBuilder.payload(event: trackerEvent, tracker: trackerData, stateManager: stateManager)

        var payloadDict = payload!.dictionary

        XCTAssertEqual(payloadDict[kSPPlatform] as? String, devicePlatformToString(.general))
        XCTAssertEqual(payloadDict[kSPAppId] as? String, "anAppId")
        XCTAssertEqual(payloadDict[kSPNamespace] as? String, "aNamespace")

        // Test setting variables to new values

        trackerData.devicePlatform = .desktop
        trackerData.appId = "newAppId"
        trackerData.trackerNamespace = "newNamespace"

        payload = payloadBuilder.payload(event: trackerEvent, tracker: trackerData, stateManager: stateManager)
        payloadDict = payload!.dictionary

        XCTAssertEqual(payloadDict[kSPPlatform] as? String, "pc")
        XCTAssertEqual(payloadDict[kSPAppId] as? String, "newAppId")
        XCTAssertEqual(payloadDict[kSPNamespace] as? String, "newNamespace")
    }
}
//#pragma clang diagnostic pop
