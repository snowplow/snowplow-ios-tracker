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

#if os(iOS) || os(macOS) || os(visionOS)
import XCTest
@testable import SnowplowTracker

class TestWebViewMessageHandler: XCTestCase {
    var webViewMessageHandler: WebViewMessageHandler?
    var networkConnection: MockNetworkConnection?

    override func setUp() {
        webViewMessageHandler = WebViewMessageHandler()
        networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)

        let networkConfig = NetworkConfiguration(networkConnection: networkConnection)
        let trackerConfig = TrackerConfiguration()
        trackerConfig.base64Encoding = false
        trackerConfig.sessionContext = false
        trackerConfig.platformContext = false

        Snowplow.removeAllTrackers()
        _ = Snowplow.createTracker(namespace: UUID().uuidString, network: networkConfig, configurations: [trackerConfig])
    }

    override func tearDown() {
        Snowplow.removeAllTrackers()
    }

    func testTracksStructuredEventWithAllProperties() {
        let message = MockWKScriptMessage(
            body: [
                "command": "trackStructEvent",
                "event": [
                "category": "cat",
                "action": "act",
                "label": "lbl",
                "property": "prop",
                "value": NSNumber(value: 10.0)
            ]
            ])
        webViewMessageHandler?.receivedMesssage(message)

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 0.5)
        }

        XCTAssertEqual(1, networkConnection?.sendingCount)
        XCTAssertEqual(1, (networkConnection?.previousRequests)?[0].count)
        let request = (networkConnection?.previousRequests)?[0][0]
        let payload = (request?.payload?["data"] as? [[String: Any]])?[0]
        XCTAssert((payload?["se_ca"] as? String == "cat"))
        XCTAssert((payload?["se_ac"] as? String == "act"))
        XCTAssert((payload?["se_pr"] as? String == "prop"))
        XCTAssert((payload?["se_la"] as? String == "lbl"))
        XCTAssert((payload?["se_va"] as? String == "10"))
    }

    func testTracksEventWithCorrectTracker() {
        // create the second tracker
        let networkConnection2 = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let networkConfig = NetworkConfiguration(networkConnection: networkConnection2)
        _ = Snowplow.createTracker(namespace: "ns2", network: networkConfig, configurations: [])

        // track an event using the second tracker
        let message = MockWKScriptMessage(
            body: [
                "command": "trackPageView",
                "event": [
                    "url": "http://localhost"
                ],
                "trackers": ["ns2"]
            ])
        webViewMessageHandler?.receivedMesssage(message)

        // wait and check for the event
        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 0.5)
        }

        XCTAssertEqual(0, networkConnection?.sendingCount)
        XCTAssertEqual(1, networkConnection2.sendingCount)
        XCTAssertEqual(1, networkConnection2.previousRequests[0].count)
    }

    func testTracksEventWithContext() {
        let message = MockWKScriptMessage(
            body: [
                "command": "trackSelfDescribingEvent",
                "event": [
                    "schema": "http://schema.com",
                    "data": [
                        "key": "val"
                    ]
                ],
                "context": [
                    [
                        "schema": "http://context-schema.com",
                        "data": [
                            "a": "b"
                        ]
                    ]
                ]
            ])
        webViewMessageHandler?.receivedMesssage(message)

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 0.5)
        }

        XCTAssertEqual(1, networkConnection?.sendingCount)
        XCTAssertEqual(1, (networkConnection?.previousRequests)?[0].count)
        let request = (networkConnection?.previousRequests)?[0][0]
        let payload = (request?.payload?["data"] as? [[String : Any]])?[0]

        let context = payload?["co"] as? String
        XCTAssert(context?.contains("{\"a\":\"b\"}") ?? false)
    }
}
#endif
