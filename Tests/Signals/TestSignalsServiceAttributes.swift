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
@testable import SnowplowTracker

class TestSignalsServiceAttributes: XCTestCase {
    let endpoint = "https://fake-signals.io"

    override func tearDown() {
        Snowplow.removeAllTrackers()
        super.tearDown()
    }

    // MARK: - Refusals (no request is made)

    func testFailsWithoutSignalsConfiguration() {
        let tracker = createTracker(signals: nil)

        let error = readError(tracker, service: "profile")

        XCTAssertEqual(0, error?.status)
        XCTAssertTrue(error?.message.contains("SignalsConfiguration") ?? false)
    }

    func testRefusesWhenUserAnonymisationIsEnabled() {
        let tracker = createTracker()
        tracker.userAnonymisation = true

        let error = readError(tracker, service: "profile", identifier: "4b4a5e8c-6c4f-4b8a-9a3b-5a1d2c3e4f5a")

        XCTAssertEqual(0, error?.status)
        XCTAssertTrue(error?.message.contains("anonymisation") ?? false)
    }

    func testRefusesWhenSessionIsDisabled() {
        let trackerConfig = TrackerConfiguration().sessionContext(false)
        let tracker = createTracker(trackerConfig: trackerConfig)

        let error = readError(tracker, service: "profile")

        XCTAssertEqual(0, error?.status)
        XCTAssertTrue(error?.message.contains("sessionContext") ?? false)
    }

    func testRefusesSessionIdBeforeTheFirstEvent() {
        let tracker = createTracker()

        let error = readError(tracker, service: "profile", attributeKey: "client_session_session_id")

        XCTAssertEqual(0, error?.status)
        XCTAssertTrue(error?.message.contains("first tracked event") ?? false)
    }

    func testRequiresAnIdentifierForOtherAttributeKeys() {
        let tracker = createTracker()

        let error = readError(tracker, service: "profile", attributeKey: "user_id")

        XCTAssertEqual(0, error?.status)
        XCTAssertTrue(error?.message.contains("user_id") ?? false)
    }

    // MARK: - URL building and response parsing

    func testBuildsServiceUrlWithEncodedComponents() {
        let url = SignalsNetworking.serviceUrl(baseUrl: SignalsConfiguration(endpoint: "signals.example.com/").baseUrl,
                                               service: "my service",
                                               attributeKey: "user_id",
                                               identifier: "a+b&c=d")

        XCTAssertEqual("https://signals.example.com/api/v1/services/my%20service?user_id=a%2Bb%26c%3Dd", url?.absoluteString)
    }

    func testKeepsTheEndpointSchemeAndPath() {
        XCTAssertEqual("http://localhost:8080/signals", SignalsConfiguration(endpoint: "http://localhost:8080/signals/").baseUrl)
    }

    func testParsesAttributesFromSuccessfulResponse() {
        let data = #"{"attributes": {"page_views": 3, "last_page": null}}"#.data(using: .utf8)

        let result = SignalsControllerImpl.parseServiceResponse(data: data, response: httpResponse(200), error: nil)

        let attributes = try? result.get()
        XCTAssertEqual(3, attributes?["page_views"] as? Int)
        XCTAssertTrue(attributes?["last_page"] is NSNull)
    }

    func testParsesErrorMessageFromFailedResponse() {
        let data = #"{"error": "service not found"}"#.data(using: .utf8)

        let result = SignalsControllerImpl.parseServiceResponse(data: data, response: httpResponse(404), error: nil)

        guard case .failure(let error) = result else { return XCTFail("Expected a failure") }
        XCTAssertEqual(404, error.status)
        XCTAssertEqual("service not found", error.message)
    }

    func testFailsWithStatusZeroWithoutResponse() {
        let networkError = URLError(.notConnectedToInternet)

        let result = SignalsControllerImpl.parseServiceResponse(data: nil, response: nil, error: networkError)

        guard case .failure(let error) = result else { return XCTFail("Expected a failure") }
        XCTAssertEqual(0, error.status)
    }

    func testFailsOnResponseWithoutAttributes() {
        let data = #"{"unexpected": true}"#.data(using: .utf8)

        let result = SignalsControllerImpl.parseServiceResponse(data: data, response: httpResponse(200), error: nil)

        guard case .failure(let error) = result else { return XCTFail("Expected a failure") }
        XCTAssertEqual(200, error.status)
    }

#if !os(watchOS) && !os(macOS) && !os(tvOS) // Mocker seems not to currently work on watchOS, macOS and tvOS

    // MARK: - Requests

    override func setUp() {
        super.setUp()
        Mocker.removeAll()
        SignalsNetworking.protocolClasses = [MockingURLProtocol.self]
    }

    override class func tearDown() {
        Mocker.removeAll()
        SignalsNetworking.protocolClasses = nil
        super.tearDown()
    }

    func testReadsAttributesForTheSessionUserId() {
        let tracker = createTracker()
        var requestUrl: URL?
        var requestHeaders: [String: String]?
        mockService("profile", statusCode: 200, body: #"{"attributes": {"page_views": 3, "last_page": null}}"#) { request in
            requestUrl = request.url
            requestHeaders = request.allHTTPHeaderFields
        }

        let (attributes, error) = read(tracker, service: "profile")

        XCTAssertNil(error)
        XCTAssertEqual(3, attributes?["page_views"] as? Int)
        XCTAssertTrue(attributes?["last_page"] is NSNull)
        let userId = tracker.session!.userId!
        XCTAssertEqual("/api/v1/services/profile", requestUrl?.path)
        XCTAssertEqual("client_session_user_id=\(userId)", requestUrl?.query)
        XCTAssertNil(requestHeaders?["Cookie"])
        XCTAssertNil(requestHeaders?["Authorization"])
    }

    func testReadsAttributesForTheSessionIdAfterTheFirstEvent() {
        let tracker = createTracker()
        _ = tracker.track(Structured(category: "cat", action: "act"))
        var requestUrl: URL?
        mockService("profile", statusCode: 200, body: #"{"attributes": {}}"#) { request in
            requestUrl = request.url
        }

        let (attributes, error) = read(tracker, service: "profile", attributeKey: "client_session_session_id")

        XCTAssertNil(error)
        XCTAssertNotNil(attributes)
        let sessionId = tracker.session!.sessionId!
        XCTAssertEqual("client_session_session_id=\(sessionId)", requestUrl?.query)
    }

    func testReadsAttributesForAnExplicitIdentifier() {
        let tracker = createTracker()
        var requestUrl: URL?
        mockService("profile", statusCode: 200, body: #"{"attributes": {"plan": "pro"}}"#) { request in
            requestUrl = request.url
        }

        let (attributes, _) = read(tracker, service: "profile", attributeKey: "user_id", identifier: "user@example.com")

        XCTAssertEqual("pro", attributes?["plan"] as? String)
        XCTAssertEqual("user_id=user%40example.com", requestUrl?.query)
    }

    func testSurfacesTheStatusAndMessageOfFailedReads() {
        let tracker = createTracker()
        mockService("private_profile", statusCode: 404, body: #"{"error": "service not found"}"#)

        let (attributes, error) = read(tracker, service: "private_profile")

        XCTAssertNil(attributes)
        XCTAssertEqual(404, error?.status)
        XCTAssertEqual("service not found", error?.message)
    }

    func testAsyncReadReturnsAttributes() async throws {
        let tracker = createTracker()
        mockService("profile", statusCode: 200, body: #"{"attributes": {"page_views": 3}}"#)

        let attributes = try await tracker.signals.getServiceAttributes(service: "profile")

        XCTAssertEqual(3, attributes["page_views"] as? Int)
    }

    func testAsyncReadThrowsSignalsError() async {
        let tracker = createTracker()
        mockService("profile", statusCode: 400, body: #"{"error": "invalid identifier"}"#)

        do {
            _ = try await tracker.signals.getServiceAttributes(service: "profile")
            XCTFail("Expected an error")
        } catch let error as SignalsError {
            XCTAssertEqual(400, error.status)
            XCTAssertEqual("invalid identifier", error.message)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func mockService(_ service: String, statusCode: Int, body: String, onRequest: ((URLRequest) -> Void)? = nil) {
        var mock = Mock(url: URL(string: "\(endpoint)/api/v1/services/\(service)")!,
                        ignoreQuery: true,
                        dataType: .json,
                        statusCode: statusCode,
                        data: [.get: body.data(using: .utf8)!])
        mock.onRequest = { request, _ in onRequest?(request) }
        mock.register()
    }

#endif

    // MARK: - Helpers

    private func read(_ tracker: TrackerController,
                      service: String,
                      attributeKey: String? = nil,
                      identifier: String? = nil) -> ([String: Any]?, SignalsError?) {
        let done = expectation(description: "Read completed")
        var result: ([String: Any]?, SignalsError?) = (nil, nil)
        tracker.signals.getServiceAttributes(service: service, attributeKey: attributeKey, identifier: identifier) { attributes, error in
            XCTAssertTrue(Thread.isMainThread)
            result = (attributes, error)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        return result
    }

    private func readError(_ tracker: TrackerController,
                           service: String,
                           attributeKey: String? = nil,
                           identifier: String? = nil) -> SignalsError? {
        let (attributes, error) = read(tracker, service: service, attributeKey: attributeKey, identifier: identifier)
        XCTAssertNil(attributes)
        return error
    }

    private func httpResponse(_ statusCode: Int) -> HTTPURLResponse? {
        return HTTPURLResponse(url: URL(string: endpoint)!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }

    private func createTracker(signals: SignalsConfiguration? = SignalsConfiguration(endpoint: "https://fake-signals.io"),
                               trackerConfig: TrackerConfiguration = TrackerConfiguration()) -> TrackerController {
        let connection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let networkConfig = NetworkConfiguration(networkConnection: connection)
        trackerConfig.installAutotracking = false
        trackerConfig.diagnosticAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        var configurations: [ConfigurationProtocol] = [trackerConfig]
        if let signals = signals {
            configurations.append(signals)
        }
        return Snowplow.createTracker(namespace: "testSignals" + UUID().uuidString,
                                      network: networkConfig,
                                      configurations: configurations)
    }
}
