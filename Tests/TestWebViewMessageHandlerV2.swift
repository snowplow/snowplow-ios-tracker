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

#if os(iOS) || os(macOS) || os(visionOS)
import XCTest
@testable import SnowplowTracker

class TestWebViewMessageHandlerV2: XCTestCase {
    var webViewMessageHandler: WebViewMessageHandlerV2?

    override func setUp() {
        webViewMessageHandler = WebViewMessageHandlerV2()
    }

    override func tearDown() {
        Snowplow.removeAllTrackers()
    }
    
    func testTracksEventWithAllProperties() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let networkConfig = NetworkConfiguration(networkConnection: networkConnection)
        let trackerConfig = TrackerConfiguration().base64Encoding(false)

        Snowplow.removeAllTrackers()
        _ = Snowplow.createTracker(
            namespace: UUID().uuidString,
            network: networkConfig,
            configurations: [trackerConfig]
        )
        
        let data = "{\"schema\":\"iglu:etc\",\"data\":{\"key\":\"val\"}}"
        let atomic = "{\"eventName\":\"pv\",\"trackerVersion\":\"webview\"," +
                "\"useragent\":\"Chrome\",\"pageUrl\":\"http://snowplow.com\"," +
                "\"pageTitle\":\"Snowplow\",\"referrer\":\"http://google.com\"," +
                "\"pingXOffsetMin\":10,\"pingXOffsetMax\":20,\"pingYOffsetMin\":30," +
                "\"pingYOffsetMax\":40,\"category\":\"cat\",\"action\":\"act\"," +
                "\"property\":\"prop\",\"label\":\"lbl\",\"value\":10.0}"
        
        let message = MockWKScriptMessage(
            body: [
                "atomicProperties": atomic,
                "selfDescribingEventData": data,
            ])
        webViewMessageHandler?.receivedMessage(message)

        waitForEventsToBeTracked()

        XCTAssertEqual(1, networkConnection.sendingCount)
        XCTAssertEqual(1, (networkConnection.previousRequests)[0].count)
        
        let request = (networkConnection.previousRequests)[0][0]
        let payload = (request.payload?["data"] as? [[String: Any]])?[0]
        
        XCTAssert(payload?[kSPEvent] as? String == "pv")
        XCTAssert(payload?[kSPTrackerVersion] as? String == "webview")
        XCTAssert(payload?[kSPUseragent] as? String == "Chrome")
        XCTAssert(payload?[kSPPageUrl] as? String == "http://snowplow.com")
        XCTAssert(payload?[kSPPageTitle] as? String == "Snowplow")
        XCTAssert(payload?[kSPPageRefr] as? String == "http://google.com")
        XCTAssert(payload?[kSPPingXOffsetMin] as? Int == 10)
        XCTAssert(payload?[kSPPingXOffsetMax] as? Int == 20)
        XCTAssert(payload?[kSPPingYOffsetMin] as? Int == 30)
        XCTAssert(payload?[kSPPingYOffsetMax] as? Int == 40)
        XCTAssert(payload?[kSPStuctCategory] as? String == "cat")
        XCTAssert(payload?[kSPStuctAction] as? String == "act")
        XCTAssert(payload?[kSPStuctProperty] as? String == "prop")
        XCTAssert(payload?[kSPStuctLabel] as? String == "lbl")
        XCTAssert(payload?[kSPStuctValue] as? Double == 10.0)
        
        XCTAssertTrue(payload?[kSPUnstructured] != nil)
        
        if let unstructuredJson = payload?[kSPUnstructured] as? String,
           let jsonData = unstructuredJson.data(using: .utf8),
           let selfDescJson = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            XCTAssert(selfDescJson["schema"] as? String == kSPUnstructSchema)
            XCTAssert(selfDescJson["data"] as? String == data)
        }
    }
    
    func testAddsDefaultPropertiesIfNotProvided() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let networkConfig = NetworkConfiguration(networkConnection: networkConnection)
        let trackerConfig = TrackerConfiguration().base64Encoding(false)

        Snowplow.removeAllTrackers()
        _ = Snowplow.createTracker(
            namespace: UUID().uuidString,
            network: networkConfig,
            configurations: [trackerConfig]
        )
        
        let message = MockWKScriptMessage(body: ["atomicProperties": "{}"])
        webViewMessageHandler?.receivedMessage(message)

        waitForEventsToBeTracked()

        XCTAssertEqual(1, (networkConnection.previousRequests)[0].count)
        
        let request = (networkConnection.previousRequests)[0][0]
        let payload = (request.payload?["data"] as? [[String: Any]])?[0]
        
        XCTAssert(payload?[kSPEvent] as? String == "ue")
        XCTAssertTrue((payload?[kSPTrackerVersion] as? String)?.starts(with: "ios") ?? false)
    }

    func testTracksEventWithCorrectTracker() {
        let eventSink1 = EventSink()
        let eventSink2 = EventSink()

        _ = createTracker("ns1", eventSink1)
        _ = createTracker("ns2", eventSink2)
        Thread.sleep(forTimeInterval: 0.2)
        
        // track an event using the second tracker
        let message = MockWKScriptMessage(
            body: [
                "atomicProperties": "{}",
                "trackers": ["ns2"]
            ])
        webViewMessageHandler?.receivedMessage(message)
        waitForEventsToBeTracked()

        XCTAssertEqual(0, eventSink1.trackedEvents.count)
        XCTAssertEqual(1, eventSink2.trackedEvents.count)
        
        // tracks using default tracker if not specified
        let message2 = MockWKScriptMessage(body: ["atomicProperties": "{}"])
        webViewMessageHandler?.receivedMessage(message2)
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, eventSink1.trackedEvents.count)
        XCTAssertEqual(1, eventSink2.trackedEvents.count)
    }

    func testTracksEventWithEntity() {
        let eventSink = EventSink()
        _ = createTracker("ns" + String(describing: Int.random(in: 0..<100)), eventSink)
        Thread.sleep(forTimeInterval: 0.2)
        
        let message = MockWKScriptMessage(
            body: [
                "atomicProperties": "{}",
                "entities": "[{\"schema\":\"iglu:com.example/etc\",\"data\":{\"key\":\"val\"}}]"
            ])
        webViewMessageHandler?.receivedMessage(message)
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, eventSink.trackedEvents.count)
        let relevantEntities = eventSink.trackedEvents[0].entities.filter { $0.data["schema"] as? String == "iglu:com.example/etc" }
        
        XCTAssertEqual(1, relevantEntities.count)
        
        let entityData = relevantEntities[0].data["data"] as? [String : Any]
        XCTAssertEqual("val", entityData?["key"] as? String)
    }
    
    func testAddsEventNameAndSchemaForInspection() {
        let eventSink = EventSink()
        _ = createTracker("ns" + String(describing: Int.random(in: 0..<100)), eventSink)
        Thread.sleep(forTimeInterval: 0.2)
        
        let message = MockWKScriptMessage(
            body: [
                "atomicProperties": "{\"eventName\":\"se\"}",
                "selfDescribingEventData": "{\"schema\":\"iglu:etc\",\"data\":{\"key\":\"val\"}}"
            ])
        webViewMessageHandler?.receivedMessage(message)
        waitForEventsToBeTracked()
        
        let events = eventSink.trackedEvents
        
        XCTAssertEqual(1, events.count)
        XCTAssertEqual("se", events[0].eventName)
        XCTAssertEqual("iglu:etc", events[0].schema)
    }
    
    func testHandlesNonJSONSerializableDataInEvent() {
        let message = MockWKScriptMessage(
            body: [
                "atomicProperties": "{\"eventName\":\"se\"}",
                "selfDescribingEventData": Double.nan
            ])
        webViewMessageHandler?.receivedMessage(message) // shouldn't crash
    }
        
    private func waitForEventsToBeTracked() {
        let expect = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () -> Void in
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }
    
    private func createTracker(_ namespace: String, _ eventSink: EventSink) -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration().base64Encoding(false)
        
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, eventSink])
    }
}
#endif
