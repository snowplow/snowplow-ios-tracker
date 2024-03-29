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

import XCTest
@testable import SnowplowTracker

let TEST_SERVER_TRACKER = "http://www.notarealurl.com"

class TestTracker: XCTestCase {
    func testTrackerSetup() {
        let emitter = Emitter(namespace: "aNamespace", urlEndpoint: "not-real.com")

        let subject = Subject(platformContext: true, geoLocationContext: true)

        _ = Tracker(trackerNamespace: "aNamespace", appId: "anAppId", emitter: emitter) { tracker in
            tracker.subject = subject
            tracker.base64Encoded = false
            tracker.sessionContext = true
        }
    }
    
    func testTrackerPayload() {
        let subject = Subject(platformContext: true, geoLocationContext: true)
        let emitter = Emitter(namespace: "aNamespace", urlEndpoint: "not-real.com")
        
        let tracker = Tracker(trackerNamespace: "aNamespace", appId: "anAppId", emitter: emitter) { tracker in
            tracker.subject = subject
            tracker.devicePlatform = .general
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

        payload = tracker.payload(with: trackerEvent)
        payloadDict = payload!.dictionary

        XCTAssertEqual(payloadDict[kSPPlatform] as? String, "pc")
        XCTAssertEqual(payloadDict[kSPAppId] as? String, "newAppId")
    }

    func testTrackerBuilderAndOptions() {
        let eventSink = EventSink()
        let emitter = Emitter(namespace: "aNamespace", urlEndpoint: "http://localhost")

        let subject = Subject(platformContext: true, geoLocationContext: true)

        let tracker = Tracker(trackerNamespace: "aNamespace", appId: "anAppId", emitter: emitter) { tracker in
            tracker.subject = subject
            tracker.base64Encoded = false
            tracker.sessionContext = true
            tracker.foregroundTimeout = 300
            tracker.backgroundTimeout = 150
        }
        tracker.addOrReplace(stateMachine: eventSink.toStateMachine())

        // Test builder setting properly

        XCTAssertNotNil(tracker.emitter)
        XCTAssertEqual(tracker.emitter.namespace, tracker.trackerNamespace)
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
        track(Structured(category: "c", action: "a"), tracker)
        tracker.resumeEventTracking()
        XCTAssertEqual(tracker.isTracking, true)
        
        // check that no events were tracked
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertEqual(eventSink.trackedEvents.count, 0)
        
        // tracks event after tracking resumed
        track(Structured(category: "c", action: "a"), tracker)
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertEqual(eventSink.trackedEvents.count, 1)

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
    
    private func track(_ event: Event, _ tracker: Tracker) {
        InternalQueue.sync {
            _ = tracker.track(event)
        }
    }

}
