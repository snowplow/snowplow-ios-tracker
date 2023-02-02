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

class MockDiagnosticLogger: NSObject {
    var callback: ((_ tag: String?, _ message: String?, _ error: Error?, _ exception: NSException?) -> Void)?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(logDiagnosticError(_:)), name: NSNotification.Name("SPTrackerDiagnostic"), object: nil)
    }

    @objc func logDiagnosticError(_ notification: Notification?) {
        let userInfo = notification?.userInfo
        let tag = userInfo?["tag"] as? String
        let message = userInfo?["message"] as? String
        let error = userInfo?["error"] as? Error
        let exception = userInfo?["exception"] as? NSException
        callback?(tag, message, error, exception)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class TestLogger: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDiagnosticTracking() {
        let expectation = XCTestExpectation()
        let diagnostic = MockDiagnosticLogger()
        diagnostic.callback = { tag, message, error, exception in
            XCTAssertEqual(tag, String(describing: TestLogger.self))
            let expectedMessage = "Error test \(1) \(NSNumber(value: 12.3))"
            XCTAssertEqual(message, expectedMessage)
            expectation.fulfill()
        }

        Logger.diagnostic(String(describing: TestLogger.self), message: String(format: "Error test %d %@", 1, NSNumber(value: 12.3)), errorOrException: nil)
        wait(for: [expectation], timeout: 10)
    }

    func testDiagnosticTrackingWithError() {
        let expectation = XCTestExpectation()
        let raisedError = NSError(domain: NSURLErrorDomain, code: 400, userInfo: nil)

        let diagnostic = MockDiagnosticLogger()
        diagnostic.callback = { tag, message, error, exception in
            XCTAssertEqual(tag, String(describing: TestLogger.self))
            XCTAssertEqual(message, "Error test")
            XCTAssert(error as? NSError == raisedError)
            expectation.fulfill()
        }

        Logger.diagnostic(String(describing: TestLogger.self), message: "Error test", errorOrException: raisedError)
        wait(for: [expectation], timeout: 10)
    }

    func testDiagnosticTrackingWithException() {
        let expectation = XCTestExpectation()
        let raisedException = NSException(name: .invalidArgumentException, reason: nil, userInfo: nil)

        let diagnostic = MockDiagnosticLogger()
        diagnostic.callback = { tag, message, error, exception in
            XCTAssertEqual(tag, String(describing: TestLogger.self))
            XCTAssertEqual(message, "Exception test")
            XCTAssertEqual(exception, raisedException)
            expectation.fulfill()
        }

        Logger.diagnostic(String(describing: TestLogger.self), message: "Exception test", errorOrException: raisedException)
        wait(for: [expectation], timeout: 10)
    }
}
