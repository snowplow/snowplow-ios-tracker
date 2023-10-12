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

let TEST_SERVER_TRACKER = "http://www.notarealurl.com"

class TestTracker: XCTestCase {
    func testTrackerSetup() {
        let emitter = Emitter(urlEndpoint: "not-real.com") { emitter in }

        let subject = Subject(platformContext: true, geoLocationContext: true)

        _ = Tracker(trackerNamespace: "aNamespace", appId: "anAppId", emitter: emitter) { tracker in
            tracker.subject = subject
            tracker.base64Encoded = false
            tracker.sessionContext = true
        }
    }

    func testTrackerBuilderAndOptions() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let emitter = Emitter(networkConnection: networkConnection) { emitter in}

        let subject = Subject(platformContext: true, geoLocationContext: true)

        let tracker = Tracker(trackerNamespace: "aNamespace", appId: "anAppId", emitter: emitter) { tracker in
            tracker.subject = subject
            tracker.base64Encoded = false
            tracker.sessionContext = true
            tracker.foregroundTimeout = 300
            tracker.backgroundTimeout = 150
        }

        // Test builder setting properly

        XCTAssertNotNil(tracker.emitter)
        XCTAssertEqual(tracker.emitter, emitter)
        XCTAssertNotNil(tracker.subject)
        XCTAssertEqual(tracker.subject, subject)
        XCTAssertEqual(tracker.devicePlatform, Utilities.platform)
        XCTAssertEqual(tracker.appId, "anAppId")
        XCTAssertEqual(tracker.trackerNamespace, "aNamespace")
        XCTAssertEqual(tracker.base64Encoded, false)
        XCTAssertEqual(tracker.inBackground, false)
        XCTAssertEqual(tracker.isTracking, true)

        // Test Pause/Resume logic

        tracker.pauseEventTracking()
        XCTAssertEqual(tracker.isTracking, false)
        _ = tracker.track(Structured(category: "c", action: "a"))
        tracker.resumeEventTracking()
        XCTAssertEqual(tracker.isTracking, true)
        
        // check that no events were tracked
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertEqual(networkConnection.previousRequests.count, 0)
        
        // tracks event after tracking resumed
        _ = tracker.track(Structured(category: "c", action: "a"))
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertEqual(networkConnection.previousRequests.count, 1)

        // Test setting variables to new values

        tracker.appId = "newAppId"
        XCTAssertEqual(tracker.appId, "newAppId")
        tracker.base64Encoded = true
        XCTAssertEqual(tracker.base64Encoded, true)
        tracker.devicePlatform = .general
        XCTAssertEqual(tracker.devicePlatform, .general)

        let subject2 = Subject(platformContext: true, geoLocationContext: true)
        tracker.subject = subject2
        XCTAssertNotEqual(tracker.subject, subject)
        XCTAssertEqual(tracker.subject, subject2)

        // Test Session Switch on/off

        let oldSessionManager = tracker.session
        tracker.sessionContext = false
        XCTAssertNil(tracker.session)

        tracker.sessionContext = true
        XCTAssertNotNil(tracker.session)
        XCTAssertFalse(oldSessionManager === tracker.session)
    }

}
