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

class TestTrackerConfiguration: XCTestCase {
    func testNetworkConfiguration_EmptyEndpoint_Fails() {
        let networkConfig = NetworkConfiguration(endpoint: "", method: .post)
        XCTAssertEqual("https://", networkConfig.endpoint)
        XCTAssertEqual(.https, networkConfig.protocol)
        XCTAssertEqual(.post, networkConfig.method)

        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "appid"
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])
        XCTAssertNotNil(tracker)
    }

    func testNetworkConfiguration_EndpointWithoutProtocol_SuccessWithHttps() {
        let networkConfig = NetworkConfiguration(endpoint: "fake-url.com", method: .get)
        XCTAssertEqual("https://fake-url.com", networkConfig.endpoint)
        XCTAssertEqual(.https, networkConfig.protocol)
        XCTAssertEqual(.get, networkConfig.method)

        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "appid"
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])
        XCTAssertNotNil(tracker)
    }

    func testNetworkConfiguration_EndpointWithHttpsProtocol_SuccessWithHttps() {
        let networkConfig = NetworkConfiguration(endpoint: "https://fake-url.com", method: .get)
        XCTAssertEqual("https://fake-url.com", networkConfig.endpoint)
        XCTAssertEqual(.https, networkConfig.protocol)
        XCTAssertEqual(.get, networkConfig.method)

        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "appid"
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])
        XCTAssertNotNil(tracker)
    }

    func testNetworkConfiguration_EndpointWithHttpProtocol_SuccessWithHttps() {
        let networkConfig = NetworkConfiguration(endpoint: "http://fake-url.com", method: .get)
        XCTAssertEqual("http://fake-url.com", networkConfig.endpoint)
        XCTAssertEqual(.http, networkConfig.protocol)
        XCTAssertEqual(.get, networkConfig.method)

        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "appid"
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])
        XCTAssertNotNil(tracker)
    }

    func testNetworkConfiguration_EndpointWithWrongProtocol_UseItAsEndpoint() {
        let networkConfig = NetworkConfiguration(endpoint: "wrong://fake-url.com", method: .get)
        XCTAssertEqual("https://wrong://fake-url.com", networkConfig.endpoint)
        XCTAssertEqual(.https, networkConfig.protocol)
        XCTAssertEqual(.get, networkConfig.method)

        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "appid"
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])
        XCTAssertNotNil(tracker)
    }

    func testNetworkConfiguration_EndpointWithOnlyProtocol_UseItAsEndpoint() {
        let networkConfig = NetworkConfiguration(endpoint: "http://", method: .get)
        XCTAssertEqual("http://", networkConfig.endpoint)
        XCTAssertEqual(.http, networkConfig.protocol)
        XCTAssertEqual(.get, networkConfig.method)

        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "appid"
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])
        XCTAssertNotNil(tracker)
    }

    func testBasicInitialization() {
        let networkConfig = NetworkConfiguration(endpoint: "https://fake-url", method: .post)
        let trackerConfig = TrackerConfiguration(appId: "appid")
        trackerConfig.platformContext = true
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])

        XCTAssertNotNil(tracker)
        XCTAssertNotNil(tracker?.emitter)
        let url = URL(string: tracker?.network?.endpoint ?? "")
        XCTAssertNotNil(url)
        let host = url?.host
        let scheme = url?.scheme
        let derivedEndpoint = "\(scheme ?? "")://\(host ?? "")"

        let `protocol`: String? = networkConfig.protocol == .http ? "http" : networkConfig.protocol == .https ? "https" : nil

        XCTAssertEqual(networkConfig.endpoint, derivedEndpoint)
        XCTAssertEqual(`protocol`, scheme)

        XCTAssertEqual(trackerConfig.appId, tracker?.appId)
        XCTAssertEqual("namespace", tracker?.namespace)
    }

    func testSessionInitialization() {
        let expectedForeground = 42
        let expectedBackground = 24
        let networkConfig = NetworkConfiguration(endpoint: "https://fake-url", method: .post)
        let trackerConfig = TrackerConfiguration(appId: "appid")
        let sessionConfig = SessionConfiguration(
            foregroundTimeoutInSeconds: expectedForeground,
            backgroundTimeoutInSeconds: expectedBackground)
        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig, sessionConfig])

        let foreground = tracker?.session?.foregroundTimeoutInSeconds ?? 0
        let background = tracker?.session?.backgroundTimeoutInSeconds ?? 0
        XCTAssertEqual(expectedForeground, foreground)
        XCTAssertEqual(expectedBackground, background)

        let foregroundMeasure = (tracker?.session)?.foregroundTimeout
        let backgroundMeasure = (tracker?.session)?.backgroundTimeout
        XCTAssertEqual(Measurement(value: Double(expectedForeground), unit: UnitDuration.seconds), foregroundMeasure)
        XCTAssertEqual(Measurement(value: Double(expectedBackground), unit: UnitDuration.seconds), backgroundMeasure)
    }

    func testSessionControllerUnavailableWhenContextTurnedOff() {
        let networkConfig = NetworkConfiguration(endpoint: "https://fake-url", method: .post)
        let trackerConfig = TrackerConfiguration(appId: "appid")
        trackerConfig.sessionContext = true
        var tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])
        XCTAssertNotNil(tracker?.session)

        trackerConfig.sessionContext = false
        tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig])
        XCTAssertNil(tracker?.session)
    }

    func testSessionConfigurationCallback() {
        _ = DataPersistence.remove(withNamespace: "namespace")
        let expectation = XCTestExpectation()

        let networkConfig = NetworkConfiguration(endpoint: "https://fake-url", method: .post)
        let trackerConfig = TrackerConfiguration(appId: "appid")
        let sessionConfig = SessionConfiguration(foregroundTimeoutInSeconds: 100, backgroundTimeoutInSeconds: 100)

        sessionConfig.onSessionStateUpdate = { sessionState in
            XCTAssertEqual(1, sessionState.sessionIndex)
            XCTAssertNil(sessionState.previousSessionId)
            expectation.fulfill()
        }

        guard let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig, sessionConfig]) else { return XCTFail() }

        _ = tracker.track(Timing(category: "cat", variable: "var", timing: 123))

        wait(for: [expectation], timeout: 10)
    }

    func testSessionConfigurationCallbackAfterNewSession() {
        _ = DataPersistence.remove(withNamespace: "namespace")
        let expectation = XCTestExpectation()

        let networkConfig = NetworkConfiguration(endpoint: "https://fake-url", method: .post)
        let trackerConfig = TrackerConfiguration(appId: "appid")
        let sessionConfig = SessionConfiguration(foregroundTimeoutInSeconds: 100, backgroundTimeoutInSeconds: 100)
        var sessionId: String?
        sessionConfig.onSessionStateUpdate = { sessionState in
            if sessionState.sessionIndex == 1 {
                XCTAssertNil(sessionState.previousSessionId)
                sessionId = sessionState.sessionId
            } else {
                XCTAssertEqual(2, sessionState.sessionIndex)
                XCTAssertEqual(sessionId, sessionState.previousSessionId)
                expectation.fulfill()
            }
        }

        let tracker = Snowplow.createTracker(namespace: "namespace", network: networkConfig, configurations: [trackerConfig, sessionConfig])

        _ = tracker?.track(Timing(category: "cat", variable: "var", timing: 123))
        tracker?.session?.startNewSession()
        _ = tracker?.track(Timing(category: "cat", variable: "var", timing: 123))

        wait(for: [expectation], timeout: 10)
    }

    func testTrackerVersionSuffix() {
        let trackerConfiguration = TrackerConfiguration()
        trackerConfiguration.trackerVersionSuffix = "test With Space 1-2-3"

        // Setup tracker
        trackerConfiguration.base64Encoding = false
        let eventStore = MockEventStore()
        let networkConfiguration = NetworkConfiguration(endpoint: "fake-url", method: .post)
        let emitterConfiguration = EmitterConfiguration()
        emitterConfiguration.eventStore = eventStore
        emitterConfiguration.threadPoolSize = 10
        let trackerController = Snowplow.createTracker(namespace: "namespace", network: networkConfiguration, configurations: [trackerConfiguration, emitterConfiguration])

        // Track fake event
        let event = Structured(category: "category", action: "action")
        _ = trackerController?.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        let events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        let payload = events.first?.payload

        // Check v_tracker field
        let versionTracker = payload?["tv"] as? String
        let expected = "\(kSPVersion) testWithSpace1-2-3"
        XCTAssertEqual(expected, versionTracker)
    }

    func testGDPRConfiguration() {
        let eventStore = MockEventStore()
        let networkConfiguration = NetworkConfiguration(endpoint: "fake-url", method: .post)
        let trackerConfiguration = TrackerConfiguration(appId: "appid")
        trackerConfiguration.base64Encoding = false
        let emitterConfiguration = EmitterConfiguration()
        emitterConfiguration.eventStore = eventStore
        emitterConfiguration.threadPoolSize = 10
        let gdprConfiguration = GDPRConfiguration(basis: .consent, documentId: "id", documentVersion: "ver", documentDescription: "desc")
        let trackerController = Snowplow.createTracker(namespace: "namespace", network: networkConfiguration, configurations: [trackerConfiguration, gdprConfiguration, emitterConfiguration])
        let gdprController = trackerController?.gdpr

        // Check gdpr settings
        XCTAssertEqual(.consent, gdprController?.basisForProcessing)
        XCTAssertEqual("id", gdprController?.documentId)

        // Check gdpr settings reset
        gdprController?.reset(basis: .contract, documentId: "id1", documentVersion: "ver1", documentDescription: "desc1")
        XCTAssertEqual(.contract, gdprController?.basisForProcessing)
        XCTAssertEqual("id1", gdprController?.documentId)
        XCTAssertTrue(gdprController?.isEnabled ?? false)

        // Check gdpr context added
        var event = Structured(category: "category", action: "action")
        _ = trackerController?.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        var events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        var payload = events.first?.payload
        var contexts = payload?["co"] as? String
        XCTAssertTrue(contexts?.contains("\"basisForProcessing\":\"contract\"") ?? false)
        XCTAssertTrue(contexts?.contains("\"documentId\":\"id1\"") ?? false)

        // Check gdpr disabled
        gdprController?.disable()
        XCTAssertFalse(gdprController?.isEnabled ?? false)
        XCTAssertEqual(.contract, gdprController?.basisForProcessing)
        XCTAssertEqual("id1", gdprController?.documentId)

        // Check gdpr context not added
        event = Structured(category: "category", action: "action")
        _ = trackerController?.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        payload = events.first?.payload
        contexts = payload?["co"] as? String
        XCTAssertFalse(contexts?.contains("\"basisForProcessing\":\"contract\"") ?? false)
        XCTAssertFalse(contexts?.contains("\"documentId\":\"id1\"") ?? false)

        // Check gdpr enabled again
        _ = gdprController?.enable()
        XCTAssertTrue(gdprController?.isEnabled ?? false)
    }

    func testWithoutGDPRConfiguration() {
        let eventStore = MockEventStore()
        let networkConfiguration = NetworkConfiguration(endpoint: "fake-url", method: .post)
        let trackerConfiguration = TrackerConfiguration(appId: "appid")
        trackerConfiguration.base64Encoding = false
        let emitterConfiguration = EmitterConfiguration()
        emitterConfiguration.eventStore = eventStore
        emitterConfiguration.threadPoolSize = 10
        let trackerController = Snowplow.createTracker(namespace: "namespace", network: networkConfiguration, configurations: [trackerConfiguration, emitterConfiguration])
        let gdprController = trackerController?.gdpr

        // Check gdpr settings
        XCTAssertFalse(gdprController?.isEnabled ?? false)

        // Check gdpr context not added
        var event = Structured(category: "category", action: "action")
        _ = trackerController?.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        var events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        var payload = events.first?.payload
        var contexts = payload?["co"] as? String
        XCTAssertFalse(contexts?.contains("\"basisForProcessing\"") ?? true)

        // Check gdpr can be enabled again
        gdprController?.reset(basis: .contract, documentId: "id1", documentVersion: "ver1", documentDescription: "desc1")
        XCTAssertEqual(.contract, gdprController?.basisForProcessing)
        XCTAssertEqual("id1", gdprController?.documentId)
        XCTAssertTrue(gdprController?.isEnabled ?? false)

        // Check gdpr context added
        event = Structured(category: "category", action: "action")
        _ = trackerController?.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        payload = events.first?.payload
        contexts = payload?["co"] as? String
        XCTAssertTrue(contexts?.contains("\"basisForProcessing\":\"contract\"") ?? false)
        XCTAssertTrue(contexts?.contains("\"documentId\":\"id1\"") ?? false)
    }

    func testAnonymisesUserIdentifiersIfAnonymousUserTracking() {
        // Initialize a tracker with anonymous user tracking
        let eventStore = MockEventStore()
        let networkConfiguration = NetworkConfiguration(endpoint: "fake-url", method: .post)
        let trackerConfiguration = TrackerConfiguration(appId: "appid")
        trackerConfiguration.base64Encoding = false
        trackerConfiguration.userAnonymisation = true
        trackerConfiguration.sessionContext = true
        trackerConfiguration.platformContext = true
        let emitterConfiguration = EmitterConfiguration()
        emitterConfiguration.eventStore = eventStore
        emitterConfiguration.threadPoolSize = 10
        let trackerController = Snowplow.createTracker(namespace: "namespace", network: networkConfiguration, configurations: [trackerConfiguration, emitterConfiguration])

        // Track an event and retrieve tracked context JSON from event store
        let event = Structured(category: "category", action: "action")
        _ = trackerController?.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        let events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        guard let payload = events.first?.payload,
              let contexts = payload["co"] as? String else { return XCTFail() }

        // Check empty userId in session context
        XCTAssertTrue(contexts.contains("\"userId\":\"00000000-0000-0000-0000-000000000000\""))
        // Check no user identifiers in platform context
        XCTAssertFalse(contexts.contains("\"appleIdfa\":\""))
        XCTAssertFalse(contexts.contains("\"appleIdfv\":\""))
    }

    func testTrackerReturnsTrackedEventId() {
        // Setup tracker
        let trackerConfiguration = TrackerConfiguration()
        let eventStore = MockEventStore()
        let networkConfiguration = NetworkConfiguration(endpoint: "fake-url", method: .post)
        let emitterConfiguration = EmitterConfiguration()
        emitterConfiguration.eventStore = eventStore
        emitterConfiguration.threadPoolSize = 10
        let trackerController = Snowplow.createTracker(namespace: "namespace", network: networkConfiguration, configurations: [trackerConfiguration, emitterConfiguration])

        // Track fake event
        let event = Structured(category: "category", action: "action")
        let eventId = trackerController?.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        let events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        let payload = events.first?.payload

        // Check eid field
        let trackedEventId = payload?["eid"] as? String
        XCTAssertTrue((eventId?.uuidString == trackedEventId))
    }
}
