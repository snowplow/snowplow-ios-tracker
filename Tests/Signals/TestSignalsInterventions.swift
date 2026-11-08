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
import Mocker
#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif
@testable import SnowplowTracker

class TestSignalsInterventions: XCTestCase {
    let endpoint = "https://fake-signals.io"
    let interventionJson = #"{"intervention_id":"5f0c7a52-9d27-4c55-8a6d-3d0f7f4d2a10","name":"offer_discount","version":2,"attributes":{"page_views":"3"},"target_attribute_key":{"name":"client_session_user_id","id":"8c8a4d7e-2b1f-4c55-9d27-5f0c7a523d0f"}}"#

    override func tearDown() {
        Snowplow.removeAllTrackers()
        super.tearDown()
    }

    // MARK: - Event stream parsing

    func testParsesMessagesSplitAcrossChunks() {
        let parser = EventStreamParser()

        let first = parser.append("event: message\nda".data(using: .utf8)!)
        let second = parser.append("ta: {\"a\":1}\n\n".data(using: .utf8)!)

        XCTAssertEqual([], first)
        XCTAssertEqual([EventStreamMessage(event: "message", data: "{\"a\":1}")], second)
    }

    func testIgnoresHeartbeatCommentsAndUnknownFields() {
        let parser = EventStreamParser()

        let messages = parser.append(":heartbeat\n\nid: 1\nretry: 100\ndata:x\n\n".data(using: .utf8)!)

        XCTAssertEqual([EventStreamMessage(event: "message", data: "x")], messages)
    }

    func testSupportsCrAndCrlfLineEndingsAndMultilineData() {
        let parser = EventStreamParser()

        let crlf = parser.append("event: error\r\ndata: a\r\ndata: b\r".data(using: .utf8)!)
        let rest = parser.append("\n\r\ndata: c\r\r".data(using: .utf8)!)

        XCTAssertEqual([], crlf)
        XCTAssertEqual([EventStreamMessage(event: "error", data: "a\nb"),
                        EventStreamMessage(event: "message", data: "c")], rest)
    }

    func testResetDiscardsPartialMessages() {
        let parser = EventStreamParser()
        _ = parser.append("data: partial\n".data(using: .utf8)!)

        parser.reset()
        let messages = parser.append("\ndata: next\n\n".data(using: .utf8)!)

        XCTAssertEqual([EventStreamMessage(event: "message", data: "next")], messages)
    }

    // MARK: - Intervention model

    func testParsesInterventionJsonAndBuildsEntityData() {
        let json = try! JSONSerialization.jsonObject(with: interventionJson.data(using: .utf8)!) as! [String: Any]

        let intervention = SignalsIntervention(json: json)

        XCTAssertEqual("5f0c7a52-9d27-4c55-8a6d-3d0f7f4d2a10", intervention?.interventionId)
        XCTAssertEqual("offer_discount", intervention?.name)
        XCTAssertEqual(2, intervention?.version)
        XCTAssertEqual("3", intervention?.attributes["page_views"] as? String)
        XCTAssertEqual("client_session_user_id", intervention?.targetAttributeKey?.name)
        let entity = intervention?.entityData
        XCTAssertEqual("offer_discount", entity?["name"] as? String)
        XCTAssertEqual(["name": "client_session_user_id", "id": "8c8a4d7e-2b1f-4c55-9d27-5f0c7a523d0f"],
                       entity?["attributeKey"] as? [String: String])
        let attributes = entity?["attributes"] as? [[String: Any]]
        XCTAssertEqual("page_views", attributes?.first?["attribute"] as? String)
        XCTAssertEqual("3", attributes?.first?["value"] as? String)
    }

    func testRejectsInterventionJsonWithoutName() {
        XCTAssertNil(SignalsIntervention(json: ["version": 1]))
    }

    // MARK: - Configuration

    func testDoesNotSubscribeWithoutSignalsConfiguration() {
        let serviceProvider = ServiceProvider(namespace: "testSignals" + UUID().uuidString,
                                              network: NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200)),
                                              configurations: [])

        InternalQueue.sync {
            serviceProvider.signalsController.addInterventionHandler(id: "handler") { _ in }
        }

        XCTAssertNil(serviceProvider.signalsController.interventions)
    }

#if !os(watchOS) && !os(macOS) && !os(tvOS) // Mocker seems not to currently work on watchOS, macOS and tvOS

    // MARK: - Subscription

    private var defaultRetryDelay: TimeInterval = 0

    override func setUp() {
        super.setUp()
        Mocker.removeAll()
        SignalsNetworking.protocolClasses = [MockingURLProtocol.self]
        // Mocker ends the stream after the body; don't reconnect within a test
        defaultRetryDelay = InterventionsSubscription.initialRetryDelay
        InterventionsSubscription.initialRetryDelay = 60
    }

    override class func tearDown() {
        Mocker.removeAll()
        SignalsNetworking.protocolClasses = nil
        super.tearDown()
    }

    override func tearDownWithError() throws {
        InterventionsSubscription.initialRetryDelay = defaultRetryDelay
    }

    func testSubscribesWithSessionIdentifiersAndDispatchesToHandlers() {
        let capture = EventCapture()
        let tracker = createTracker(capture: capture)
        var request: URLRequest?
        mockInterventions(body: "event: message\ndata: \(interventionJson)\n\n") { request = $0 }
        let handled = expectation(description: "Intervention handled")
        var received: SignalsIntervention?

        tracker.signals.addInterventionHandler(id: "banner") { intervention in
            XCTAssertTrue(Thread.isMainThread)
            received = intervention
            handled.fulfill()
        }
        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [handled], timeout: 5)

        XCTAssertEqual("offer_discount", received?.name)
        let session = tracker.session!
        XCTAssertEqual("/api/v1/interventions", request?.url?.path)
        XCTAssertEqual("client_session_user_id=\(session.userId!)&client_session_session_id=\(session.sessionId!)",
                       request?.url?.query)
        XCTAssertEqual("text/event-stream", request?.value(forHTTPHeaderField: "Accept"))

        let events = capture.wait(for: [kSPSignalsInterventionReceiveSchema, kSPSignalsInterventionHandleSchema], testCase: self)
        XCTAssertEqual(["banner"], events[kSPSignalsInterventionReceiveSchema]?.payload["handlers"] as? [String])
        let handle = events[kSPSignalsInterventionHandleSchema]
        XCTAssertEqual("banner", handle?.payload["handler"] as? String)
        let entity = handle?.entities.first { $0.schema == kSPSignalsInterventionInstanceSchema }
        XCTAssertEqual("5f0c7a52-9d27-4c55-8a6d-3d0f7f4d2a10", entity?.data["intervention_id"] as? String)
    }

    func testTracksHandleErrorWhenTheHandlerThrows() {
        struct HandlerError: Error {}
        let capture = EventCapture()
        let tracker = createTracker(capture: capture)
        mockInterventions(body: "event: message\ndata: \(interventionJson)\n\n")

        tracker.signals.addInterventionHandler(id: "nudge") { _ in throw HandlerError() }
        _ = tracker.track(Structured(category: "cat", action: "act"))

        let events = capture.wait(for: [kSPSignalsInterventionHandleErrorSchema], testCase: self)
        let payload = events[kSPSignalsInterventionHandleErrorSchema]?.payload
        XCTAssertEqual("nudge", payload?["handler"] as? String)
        XCTAssertTrue((payload?["error"] as? String)?.contains("HandlerError") ?? false)
        XCTAssertNil(capture.event(schema: kSPSignalsInterventionHandleSchema))
    }

    func testDoesNotSubscribeWhenUserAnonymisationIsEnabled() {
        let tracker = createTracker()
        tracker.userAnonymisation = true
        let requested = expectation(description: "Subscription requested")
        requested.isInverted = true
        mockInterventions(body: "") { _ in requested.fulfill() }

        tracker.signals.addInterventionHandler(id: "banner") { _ in }
        _ = tracker.track(Structured(category: "cat", action: "act"))

        wait(for: [requested], timeout: 1)
    }

    func testDoesNotSubscribeWithoutHandlers() {
        let tracker = createTracker()
        let requested = expectation(description: "Subscription requested")
        requested.isInverted = true
        mockInterventions(body: "") { _ in requested.fulfill() }

        tracker.signals.addInterventionHandler(id: "banner") { _ in }
        tracker.signals.removeInterventionHandler(id: "banner")
        _ = tracker.track(Structured(category: "cat", action: "act"))

        wait(for: [requested], timeout: 1)
    }

    func testReconnectsWhenTheSessionChanges() {
        let tracker = createTracker()
        var queries: [String] = []
        var requested = expectation(description: "First subscription")
        mockInterventions(body: ":heartbeat\n\n") { request in
            queries.append(request.url?.query ?? "")
            requested.fulfill()
        }
        tracker.signals.addInterventionHandler(id: "banner") { _ in }
        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [requested], timeout: 5)
        let firstSessionId = tracker.session!.sessionId!

        requested = expectation(description: "Second subscription")
        tracker.session!.startNewSession()
        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [requested], timeout: 5)

        let secondSessionId = tracker.session!.sessionId!
        XCTAssertNotEqual(firstSessionId, secondSessionId)
        XCTAssertEqual(2, queries.count)
        XCTAssertTrue(queries.last?.contains(secondSessionId) ?? false)
    }

    func testDoesNotRetryRejectedSubscriptionsUntilIdentifiersChange() {
        let tracker = createTracker()
        var requests = 0
        let rejected = expectation(description: "Subscription rejected")
        mockInterventions(statusCode: 400, body: #"{"error": "invalid identifier"}"#) { _ in
            requests += 1
            rejected.fulfill()
        }
        InterventionsSubscription.initialRetryDelay = 0.1
        tracker.signals.addInterventionHandler(id: "banner") { _ in }
        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [rejected], timeout: 5)

        _ = tracker.track(Structured(category: "cat", action: "act"))
        let settle = expectation(description: "No retries")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { settle.fulfill() }
        wait(for: [settle], timeout: 1)

        XCTAssertEqual(1, requests)
    }

    func testClosesInTheBackgroundAndReconnectsInTheForeground() {
        let tracker = createTracker()
        var requested = expectation(description: "First subscription")
        mockInterventions(body: ":heartbeat\n\n") { _ in requested.fulfill() }
        tracker.signals.addInterventionHandler(id: "banner") { _ in }
        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [requested], timeout: 5)

        requested = expectation(description: "No subscription in the background")
        requested.isInverted = true
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        tracker.session!.startNewSession()
        _ = tracker.track(Structured(category: "cat", action: "act"))
        wait(for: [requested], timeout: 1)

        requested = expectation(description: "Subscription in the foreground")
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        wait(for: [requested], timeout: 5)
    }

    private func mockInterventions(statusCode: Int = 200, body: String, onRequest: ((URLRequest) -> Void)? = nil) {
        var mock = Mock(url: URL(string: "\(endpoint)/api/v1/interventions")!,
                        ignoreQuery: true,
                        dataType: .json,
                        statusCode: statusCode,
                        data: [.get: body.data(using: .utf8)!])
        mock.onRequest = { request, _ in
            DispatchQueue.main.async { onRequest?(request) }
        }
        mock.register()
    }

#endif

    // MARK: - Helpers

    private func createTracker(capture: EventCapture? = nil) -> TrackerController {
        let connection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let networkConfig = NetworkConfiguration(networkConnection: connection)
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.diagnosticAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        var configurations: [ConfigurationProtocol] = [trackerConfig, SignalsConfiguration(endpoint: endpoint)]
        if let capture = capture {
            configurations.append(capture.plugin)
        }
        return Snowplow.createTracker(namespace: "testSignals" + UUID().uuidString,
                                      network: networkConfig,
                                      configurations: configurations)
    }
}

/// Captures tracked self-describing events through an afterTrack plugin, which unlike a filter keeps them tracked.
private class EventCapture {
    struct CapturedEvent {
        let payload: [String: Any]
        let entities: [SelfDescribingJson]
    }

    private let lock = NSLock()
    private var events: [String: CapturedEvent] = [:]

    lazy var plugin: PluginConfiguration = {
        let plugin = PluginConfiguration(identifier: "signalsEventCapture")
        return plugin.afterTrack { [weak self] event in
            guard let self = self, let schema = event.schema else { return }
            self.lock.lock()
            self.events[schema] = CapturedEvent(payload: event.payload, entities: event.entities)
            self.lock.unlock()
        }
    }()

    func event(schema: String) -> CapturedEvent? {
        lock.lock()
        defer { lock.unlock() }
        return events[schema]
    }

    /// Waits until events with all the schemas were tracked.
    func wait(for schemas: [String], testCase: XCTestCase, timeout: TimeInterval = 5) -> [String: CapturedEvent] {
        let predicate = NSPredicate { _, _ in schemas.allSatisfy { self.event(schema: $0) != nil } }
        let tracked = testCase.expectation(for: predicate, evaluatedWith: nil)
        testCase.wait(for: [tracked], timeout: timeout)
        var result: [String: CapturedEvent] = [:]
        for schema in schemas {
            result[schema] = event(schema: schema)
        }
        return result
    }
}
