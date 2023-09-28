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
import SnowplowTracker

class TestTrackEventsToMicro: XCTestCase {
    var tracker: TrackerController?
    
    override func setUp() {
        super.setUp()
        
        let trackerConfig = TrackerConfiguration()
            .logLevel(.debug)

        tracker = Snowplow.createTracker(namespace: "testMicro-" + UUID().uuidString,
                                         network: NetworkConfiguration(endpoint: Micro.endpoint),
                                         configurations: [trackerConfig])!

        wait(for: [Micro.reset()], timeout: Micro.timeout)
    }
    
    func testTrackStructuredEvent() {
        let event = Structured(category: "shop", action: "add-to-basket")
        event.label = "Add To Basket"
        event.property = "pcs"
        event.value = 2.0
        track(event)
        
        wait(for: [
            Micro.expectCounts(good: 1),
            Micro.expectPrimitiveEvent() { actual in
                XCTAssertEqual("shop", actual.se_category)
                XCTAssertEqual("add-to-basket", actual.se_action)
                XCTAssertEqual("Add To Basket", actual.se_label)
                XCTAssertEqual("pcs", actual.se_property)
                XCTAssertEqual(2.0, actual.se_value)
            }
        ], timeout: Micro.timeout)
    }
    
    func testTrackSelfDescribing() {
        let event = SelfDescribing(
            schema: "iglu:com.snowplowanalytics.snowplow/screen_view/jsonschema/1-0-0",
            payload: [
                "name": "test", "id": "something else"
            ]
        )
        track(event)
        
        wait(for: [
            Micro.expectCounts(good: 1),
            Micro.expectSelfDescribingEvent() { (actual: ScreenViewExpected) in
                XCTAssertEqual("test", actual.name)
                XCTAssertEqual("something else", actual.id)
            }
        ], timeout: Micro.timeout)
    }
    
    func testTrackScreenViews() {
        // track the first screen view
        track(ScreenView(name: "screen1", screenId: UUID()))
        wait(for: [Micro.expectCounts(good: 1)], timeout: Micro.timeout)
        wait(for: [Micro.reset()], timeout: Micro.timeout)
        
        // track the second screen view and check reference to previous
        track(ScreenView(name: "screen2", screenId: UUID()))
        wait(for: [
            Micro.expectCounts(good: 1),
            Micro.expectSelfDescribingEvent() { (actual: ScreenViewExpected) in
                XCTAssertEqual("screen2", actual.name)
                XCTAssertEqual("screen1", actual.previousName)
            }
        ], timeout: Micro.timeout)
        wait(for: [Micro.reset()], timeout: Micro.timeout)
        
        // track another event and check screen context
        track(Timing(category: "cat", variable: "var", timing: 10))
        wait(for: [
            Micro.expectEventContext(
                schema: "iglu:com.snowplowanalytics.mobile/screen/jsonschema/1-0-0"
            ) { (actual: ScreenContextExpected) in
                XCTAssertEqual("screen2", actual.name)
            }
        ], timeout: Micro.timeout)
    }
    
    func testTrackDeepLink() {
        // track the deep link received event
        let deepLink = DeepLinkReceived(url: "https://snowplow.io")
        deepLink.referrer = "https://plowsnow.io"
        track(deepLink)
        wait(for: [
            Micro.expectSelfDescribingEvent() { (actual: DeepLinkExpected) in
                XCTAssertEqual("https://snowplow.io", actual.url)
                XCTAssertEqual("https://plowsnow.io", actual.referrer)
            }
        ], timeout: Micro.timeout)
        wait(for: [Micro.reset()], timeout: Micro.timeout)
        
        // track a screen view and check references to the deep link
        track(ScreenView(name: "screen", screenId: UUID()))
        wait(for: [
            // deep link info in payload
            Micro.expectPrimitiveEvent() { actual in
                XCTAssertEqual("https://snowplow.io", actual.page_url)
                XCTAssertEqual("https://plowsnow.io", actual.page_referrer)
            },
            // deep link info in context entity
            Micro.expectEventContext(
                schema: "iglu:com.snowplowanalytics.mobile/deep_link/jsonschema/1-0-0"
            ) { (actual: DeepLinkExpected) in
                XCTAssertEqual("https://snowplow.io", actual.url)
                XCTAssertEqual("https://plowsnow.io", actual.referrer)
            }
        ], timeout: Micro.timeout)
    }
    
    func testSessionTracking() {
        // track the first event
        track(Structured(category: "cat", action: "act"))
        var userId: String?, sessionId: String?
        wait(for: [
            Micro.expectEventContext(
                schema: "iglu:com.snowplowanalytics.snowplow/client_session/jsonschema/1-0-2"
            ) { (actual: SessionExpected) in
                userId = actual.userId
                sessionId = actual.sessionId
            }
        ], timeout: Micro.timeout)
        wait(for: [Micro.reset()], timeout: Micro.timeout)
        
        // track the second event in the same session
        track(Structured(category: "cat", action: "act"))
        wait(for: [
            Micro.expectEventContext(
                schema: "iglu:com.snowplowanalytics.snowplow/client_session/jsonschema/1-0-2"
            ) { (actual: SessionExpected) in
                XCTAssertEqual(userId, actual.userId)
                XCTAssertEqual(sessionId, actual.sessionId)
            }
        ], timeout: Micro.timeout)
        wait(for: [Micro.reset()], timeout: Micro.timeout)
        
        // start a new session and track event
        tracker!.session!.startNewSession()
        track(Structured(category: "cat", action: "act"))
        wait(for: [
            Micro.expectEventContext(
                schema: "iglu:com.snowplowanalytics.snowplow/client_session/jsonschema/1-0-2"
            ) { (actual: SessionExpected) in
                XCTAssertEqual(userId, actual.userId)
                XCTAssertNotEqual(sessionId, actual.sessionId)
            }
        ], timeout: Micro.timeout)
    }
    
    private func track(_ event: Event) {
        _ = tracker!.track(event)
        tracker!.emitter!.flush()
    }
}

private struct ScreenViewExpected: Codable {
    let name: String
    let id: String
    let type: String?
    let previousName: String?
    let previousId: String?
    let previousType: String?
    let transitionType: String?
}

private struct ScreenContextExpected: Codable {
    let name: String
    let id: String
}

private struct DeepLinkExpected: Codable {
    let url: String
    let referrer: String?
}

private struct SessionExpected: Codable {
    let sessionId: String
    let userId: String
}
