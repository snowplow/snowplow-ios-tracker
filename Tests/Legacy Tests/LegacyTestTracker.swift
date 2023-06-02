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

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"

import XCTest
@testable import SnowplowTracker

let TEST_SERVER_TRACKER = "http://www.notarealurl.com"

class LegacyTestTracker: XCTestCase {
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
        let emitter = Emitter(urlEndpoint: TEST_SERVER_TRACKER) { emitter in}

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
        XCTAssertNil(tracker.track(Structured(category: "c", action: "a")))
        tracker.resumeEventTracking()
        XCTAssertEqual(tracker.isTracking, true)

        // Test setting variables to new values

        tracker.appId = "newAppId"
        XCTAssertEqual(tracker.appId, "newAppId")
        tracker.trackerNamespace = "newNamespace"
        XCTAssertEqual(tracker.trackerNamespace, "newNamespace")
        tracker.base64Encoded = true
        XCTAssertEqual(tracker.base64Encoded, true)
        tracker.devicePlatform = .general
        XCTAssertEqual(tracker.devicePlatform, .general)

        let subject2 = Subject(platformContext: true, geoLocationContext: true)
        tracker.subject = subject2
        XCTAssertNotEqual(tracker.subject, subject)
        XCTAssertEqual(tracker.subject, subject2)

        let emitter2 = Emitter(urlEndpoint: TEST_SERVER_TRACKER) { emitter in}
        tracker.emitter = emitter2
        XCTAssertNotEqual(tracker.emitter, emitter)
        XCTAssertEqual(tracker.emitter, emitter2)

        // Test Session Switch on/off

        let oldSessionManager = tracker.session
        tracker.sessionContext = false
        XCTAssertNil(tracker.session)

        tracker.sessionContext = true
        XCTAssertNotNil(tracker.session)
        XCTAssertFalse(oldSessionManager === tracker.session)
    }

    func testTrackerPayload() {
        let emitter = Emitter(urlEndpoint: TEST_SERVER_TRACKER) { emitter in}

        let subject = Subject(platformContext: true, geoLocationContext: true)

        let tracker = Tracker(trackerNamespace: "aNamespace", appId: "anAppId", emitter: emitter) { tracker in
            tracker.subject = subject
            tracker.devicePlatform = .general
            tracker.appId = "anAppId"
            tracker.base64Encoded = false
            tracker.sessionContext = true
            tracker.foregroundTimeout = 300
            tracker.backgroundTimeout = 150
        }

        let event = Structured(category: "Category", action: "Action")
        let trackerEvent = TrackerEvent(event: event, state: nil)
        var payload = tracker.payload(with: trackerEvent)
        var payloadDict = payload!.dictionary

        XCTAssertEqual(payloadDict[kSPPlatform] as? String, devicePlatformToString(.general))
        XCTAssertEqual(payloadDict[kSPAppId] as? String, "anAppId")
        XCTAssertEqual(payloadDict[kSPNamespace] as? String, "aNamespace")

        // Test setting variables to new values

        tracker.devicePlatform = .desktop
        tracker.appId = "newAppId"
        tracker.trackerNamespace = "newNamespace"

        payload = tracker.payload(with: trackerEvent)
        payloadDict = payload!.dictionary

        XCTAssertEqual(payloadDict[kSPPlatform] as? String, "pc")
        XCTAssertEqual(payloadDict[kSPAppId] as? String, "newAppId")
        XCTAssertEqual(payloadDict[kSPNamespace] as? String, "newNamespace")
    }

    func testEventIdNotDuplicated() {
        let event = Structured(category: "Category", action: "Action")
        let eventId = TrackerEvent(event: event, state: nil).eventId
        XCTAssertNotNil(eventId)
        let newEventId = TrackerEvent(event: event, state: nil).eventId
        XCTAssertNotNil(newEventId)
        XCTAssertNotEqual(eventId, newEventId)
    }
}
//#pragma clang diagnostic pop
