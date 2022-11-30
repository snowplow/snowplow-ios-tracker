//
//  TestNetworkConnection.swift
//  Snowplow-iOSTests
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

import Nocilla
import XCTest
@testable import SnowplowTracker

let TEST_URL_ENDPOINT = "acme.test.url.com"

class TestNetworkConnection: XCTestCase {
    override func setUp() {
        super.setUp()
        if LSNocilla.sharedInstance().isStarted {
            LSNocilla.sharedInstance().stop()
        }
        LSNocilla.sharedInstance().start()
    }

    override func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }

    func testGetRequestWithSuccess() {
        let regex = try? NSRegularExpression(pattern: "^\("https")://\(TEST_URL_ENDPOINT)/i?(.*?)")
        _ = stubRequest("GET", regex).andReturn(200)
        
        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .get)

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(NSNumber(value: 1), result.storeIds?[0])
    }

    func testGetRequestWithNoSuccess() {
        let regex = try? NSRegularExpression(pattern: "^\("https")://\(TEST_URL_ENDPOINT)/i?(.*?)")
        _ = stubRequest("GET", regex).andReturn(404)

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .get)
        
        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check unsuccessful result
        let result = results[0]
        XCTAssertFalse(result.isSuccessful)
        XCTAssertEqual(NSNumber(value: 1), (result.storeIds)?[0])
    }

    func testPostRequestWithSuccess() {
        let regex = try? NSRegularExpression(pattern: "^\("https")://\(TEST_URL_ENDPOINT)/i?(.*?)")
        _ = stubRequest("POST", regex).andReturn(200)

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .post)
        
        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(NSNumber(value: 1), (result.storeIds)?[0])
    }

    func testPostRequestWithNoSuccess() {
        let regex = try? NSRegularExpression(pattern: "^\("https")://\(TEST_URL_ENDPOINT)/i?(.*?)")
        _ = stubRequest("POST", regex).andReturn(404)

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .post)

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check unsuccessful result
        let result = results[0]
        XCTAssertFalse(result.isSuccessful)
        XCTAssertEqual(NSNumber(value: 1), (result.storeIds)?[0])
    }

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

    func testDoesntAddHeaderWithoutServerAnonymisation() {
        let regex = try? NSRegularExpression(pattern: "^\("https")://\(TEST_URL_ENDPOINT)/i?(.*?)")
        _ = stubRequest("POST", regex).withHeader(
            "SP-Anonymous",
            "*")?.andReturn(
            500)
        _ = stubRequest("POST", regex).andReturn(
            200)

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .post)
        connection.serverAnonymisation = false

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(NSNumber(value: 1), result.storeIds?[0])
    }

    func testAddsHeaderForServerAnonymisationForPostRequest() {
        let regex = try? NSRegularExpression(pattern: "^\("https")://\(TEST_URL_ENDPOINT)/i?(.*?)")
        _ = stubRequest("POST", regex).withHeader(
            "SP-Anonymous",
            "*")?.andReturn(
            200)

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .post)
        connection.serverAnonymisation = true

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(NSNumber(value: 1), result.storeIds?[0])
    }

    func testAddsHeaderForServerAnonymisationForGetRequest() {
        let regex = try? NSRegularExpression(pattern: "^\("https")://\(TEST_URL_ENDPOINT)/i?(.*?)")
       _ = stubRequest("GET", regex).withHeader(
            "SP-Anonymous",
            "*")?.andReturn(
            200)

        let connection = DefaultNetworkConnection(urlString: TEST_URL_ENDPOINT, httpMethod: .get)
        connection.serverAnonymisation = true

        let payload = Payload()
        payload.addValueToPayload("value", forKey: "key")
        let request = Request(payload: payload, emitterEventId: 1)
        let results = connection.sendRequests([request])

        // Check successful result
        let result = results[0]
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(NSNumber(value: 1), result.storeIds?[0])
    }
}
