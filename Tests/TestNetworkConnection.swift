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

import Mocker
import XCTest
@testable import SnowplowTracker

let TEST_URL_ENDPOINT = "acme.test.url.com"

class TestNetworkConnection: XCTestCase {
    override func tearDown() {
        super.tearDown()
        Mocker.removeAll()
    }

#if !os(watchOS) // Mocker seems not to currently work on watchOS
    func testGetRequestWithSuccess() {
        let endpoint = "https://\(TEST_URL_ENDPOINT)/i"
        Mock(url: URL(string: endpoint)!, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get: Data()]).register()
        
        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .get)

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(1, result.storeIds?[0])
    }
    
    func testGetRequestWithNoSuccess() {
        let endpoint = "https://\(TEST_URL_ENDPOINT)/i"
        Mock(url: URL(string: endpoint)!, ignoreQuery: true, dataType: .json, statusCode: 404, data: [.get: Data()]).register()

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .get)
        
        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check unsuccessful result
        let result = results[0]
        XCTAssertFalse(result.isSuccessful)
        XCTAssertEqual(1, (result.storeIds)?[0])
    }
    
    func testPostRequestWithSuccess() {
        let endpoint = "https://\(TEST_URL_ENDPOINT)/com.snowplowanalytics.snowplow/tp2"
        Mock(url: URL(string: endpoint)!, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.post: Data()]).register()

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .post)
        
        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(1, (result.storeIds)?[0])
    }
    
    func testPostRequestWithNoSuccess() {
        let endpoint = "https://\(TEST_URL_ENDPOINT)/com.snowplowanalytics.snowplow/tp2"
        Mock(url: URL(string: endpoint)!, ignoreQuery: true, dataType: .json, statusCode: 404, data: [.post: Data()]).register()

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .post)

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check unsuccessful result
        let result = results[0]
        XCTAssertFalse(result.isSuccessful)
        XCTAssertEqual(1, (result.storeIds)?[0])
    }
#endif
    
    func testFreeEndpoint_GetHttpsUrl() {
        let connection = DefaultNetworkConnection(urlString: "acme.test.url.com", httpMethod: .post)
        XCTAssertTrue(connection.urlEndpoint!.absoluteString.hasPrefix("https://acme.test.url.com"))
    }

    func testHttpsEndpoint_GetHttpsUrl() {
        let connection = DefaultNetworkConnection(urlString: "https://acme.test.url.com", httpMethod: .post)
        XCTAssertTrue(connection.urlEndpoint!.absoluteString.hasPrefix("https://acme.test.url.com"))
    }

    func testHttpEndpoint_GetHttpUrl() {
        let connection = DefaultNetworkConnection(urlString: "http://acme.test.url.com", httpMethod: .post)
        XCTAssertTrue(connection.urlEndpoint!.absoluteString.hasPrefix("http://acme.test.url.com"))
    }

    func testStripsTrailingSlashInEndpoint() {
        let connection = DefaultNetworkConnection(urlString: "http://acme.test.url.com/", httpMethod: .get)
        XCTAssertTrue((connection.urlEndpoint?.absoluteString == "http://acme.test.url.com/i"))
    }

#if !os(watchOS) // Mocker seems not to currently work on watchOS
    func testDoesntAddHeaderWithoutServerAnonymisation() {
        let endpoint = "https://\(TEST_URL_ENDPOINT)/com.snowplowanalytics.snowplow/tp2"
        var mock = Mock(url: URL(string: endpoint)!, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.post: Data()])
        let requestExpectation = expectation(description: "Checked the request")
        mock.onRequest = { request, postBodyArguments in
            XCTAssertNil(request.value(forHTTPHeaderField: "SP-Anonymous"))
            requestExpectation.fulfill()
        }
        mock.register()
        
        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .post)
        connection.serverAnonymisation = false

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(1, result.storeIds?[0])
        wait(for: [requestExpectation], timeout: 2.0)
    }

    func testAddsHeaderForServerAnonymisationForPostRequest() {
        let endpoint = "https://\(TEST_URL_ENDPOINT)/com.snowplowanalytics.snowplow/tp2"
        var mock = Mock(url: URL(string: endpoint)!, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.post: Data()])
        let requestExpectation = expectation(description: "Checked the request")
        mock.onRequest = { request, postBodyArguments in
            XCTAssertEqual("*", request.value(forHTTPHeaderField: "SP-Anonymous"))
            requestExpectation.fulfill()
        }
        mock.register()
        
        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .post)
        connection.serverAnonymisation = true

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(1, result.storeIds?[0])
        wait(for: [requestExpectation], timeout: 2.0)
    }

    func testAddsHeaderForServerAnonymisationForGetRequest() {
        let endpoint = "https://\(TEST_URL_ENDPOINT)/i"
        var mock = Mock(url: URL(string: endpoint)!, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get: Data()])
        let requestExpectation = expectation(description: "Checked the request")
        mock.onRequest = { request, postBodyArguments in
            XCTAssertEqual("*", request.value(forHTTPHeaderField: "SP-Anonymous"))
            requestExpectation.fulfill()
        }
        mock.register()
        
        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .get)
        connection.serverAnonymisation = true

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(1, result.storeIds?[0])
        wait(for: [requestExpectation], timeout: 2.0)
    }
#endif
}
