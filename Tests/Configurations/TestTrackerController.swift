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

class TestTrackerController: XCTestCase {
    func testSessionAccessibilityWhenEnabledAndDisabled() {
        let tracker = Snowplow.createTracker(namespace: "namespace", endpoint: "https://fake-url", method: .post)
        XCTAssertNotNil(tracker?.session)

        tracker?.sessionContext = false
        XCTAssertNil(tracker?.session)
    }

    func testSubjectUserIdCanBeUpdated() {
        let tracker = Snowplow.createTracker(namespace: "namespace", endpoint: "https://fake-url", method: .post)
        XCTAssertNotNil(tracker?.subject)
        XCTAssertNil(tracker?.subject?.userId)
        tracker?.subject?.userId = "fakeUserId"
        XCTAssertEqual("fakeUserId", tracker?.subject?.userId)
        tracker?.subject?.userId = nil
        XCTAssertNil(tracker?.subject?.userId)
    }

    func testSubjectGeoLocationCanBeUpdated() {
        let tracker = Snowplow.createTracker(namespace: "namespace", endpoint: "https://fake-url", method: .post)
        XCTAssertNotNil(tracker?.subject)
        XCTAssertNil(tracker?.subject?.geoLatitude)
        tracker?.subject?.geoLatitude = NSNumber(value: 12.3456)
        XCTAssertEqual(NSNumber(value: 12.3456), tracker?.subject?.geoLatitude)
        tracker?.subject?.geoLatitude = nil
        // TODO: On version 3 setting to nil should get back nil.
        // Here it should be nil rather than 0 but it's the way the beneith SPSubject works.
        XCTAssertNil(tracker?.subject?.geoLatitude)
    }

    func testStartsNewSessionWhenChangingAnonymousTracking() {
        let tracker = Snowplow.createTracker(namespace: "n2", endpoint: "https://fake-url", method: .post)
        tracker?.emitter?.pause()

        _ = tracker?.track(Structured(category: "c", action: "a"))
        let sessionIdBefore = tracker?.session?.sessionId

        tracker?.userAnonymisation = true
        _ = tracker?.track(Structured(category: "c", action: "a"))
        let sessionIdAnonymous = tracker?.session?.sessionId

        XCTAssertFalse((sessionIdBefore == sessionIdAnonymous))

        tracker?.userAnonymisation = false
        _ = tracker?.track(Structured(category: "c", action: "a"))
        let sessionIdNotAnonymous = tracker?.session?.sessionId

        XCTAssertFalse((sessionIdAnonymous == sessionIdNotAnonymous))
    }
}
