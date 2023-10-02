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

class TestRequestResult: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSuccessfulRequest() {
        var emitterEventIds: [Int64]? = []
        emitterEventIds?.append(1)
        let result = RequestResult(statusCode: 200, oversize: false, storeIds: emitterEventIds)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.isSuccessful, true)
        XCTAssertEqual(result.shouldRetry([:], retryAllowed: true), false)
        XCTAssertEqual(result.storeIds, emitterEventIds)
    }

    func testFailedRequest() {
        var emitterEventIds: [Int64]? = []
        emitterEventIds?.append(1)
        let result = RequestResult(statusCode: 500, oversize: false, storeIds: emitterEventIds)
        XCTAssertEqual(result.isSuccessful, false)
        XCTAssertEqual(result.shouldRetry([:], retryAllowed: true), true)
    }

    func testDefaultResult() {
        let result = RequestResult()

        XCTAssertNotNil(result)
        XCTAssertEqual(result.isSuccessful, false)
        XCTAssertEqual(result.storeIds?.count, 0)
    }

    func testOversizedFailedRequest() {
        let result = RequestResult(statusCode: 500, oversize: true, storeIds: [])
        XCTAssertEqual(result.isSuccessful, false)
        XCTAssertEqual(result.shouldRetry([:], retryAllowed: true), false)
    }

    func testFailedRequestWithNoRetryStatus() {
        let result = RequestResult(statusCode: 403, oversize: false, storeIds: [])
        XCTAssertEqual(result.isSuccessful, false)
        XCTAssertEqual(result.shouldRetry([:], retryAllowed: true), false)
    }

    func testFailedRequestWithCustomNoRetryStatus() {
        var customRetryRules: [Int : Bool] = [:]
        customRetryRules[403] = true
        customRetryRules[500] = false

        var result = RequestResult(statusCode: 403, oversize: false, storeIds: [])
        XCTAssertEqual(result.shouldRetry(customRetryRules, retryAllowed: true), true)

        result = RequestResult(statusCode: 500, oversize: false, storeIds: [])
        XCTAssertEqual(result.shouldRetry(customRetryRules, retryAllowed: true), false)
    }
    
    func testFailedRequestWithDisabledRetry() {
        let result = RequestResult(statusCode: 500, oversize: false, storeIds: [])
        XCTAssertFalse(result.isSuccessful)
        XCTAssertFalse(result.shouldRetry(nil, retryAllowed: false))
    }
}
