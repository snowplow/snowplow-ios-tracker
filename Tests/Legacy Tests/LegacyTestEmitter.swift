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

//class BrokenNetworkConnection: NetworkConnection {
//    func sendRequests(_ requests: [Request]) -> [RequestResult] {
//        NSException.raise("BrokenNetworkConnection", format: "Fake exception on network connection.")
//        return nil
//    }
//
//    var urlEndpoint: URL? {
//        NSException.raise("BrokenNetworkConnection", format: "Fake exception on network connection.")
//        return nil
//    }
//
//    var httpMethod: HttpMethodOptions {
//        NSException.raise("BrokenNetworkConnection", format: "Fake exception on network connection.")
//        return .get
//    }
//}

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"

let TEST_SERVER_EMITTER = "www.notarealurl.com"

class LegacyTestEmitter: XCTestCase {
    override func setUp() {
        super.setUp()
        Logger.logLevel = .verbose
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmitterBuilderAndOptions() {
        let `protocol` = "https"

        let emitter = Emitter(
            namespace: "ns1",
            urlEndpoint: TEST_SERVER_EMITTER,
            method: .post,
            protocol: .https
        ) { emitter in
            emitter.byteLimitGet = 30000
            emitter.byteLimitPost = 35000
            emitter.emitRange = 500
            emitter.emitThreadPoolSize = 30
        }

        var url = "\(`protocol`)://\(TEST_SERVER_EMITTER)/com.snowplowanalytics.snowplow/tp2"

        // Test builder setting properly

        XCTAssertNil(emitter.callback)
        XCTAssertTrue((emitter.urlEndpoint == url))
        XCTAssertEqual(emitter.method, .post)
        XCTAssertEqual(emitter.emitRange, 500)
        XCTAssertEqual(emitter.emitThreadPoolSize, 30)
        XCTAssertEqual(emitter.byteLimitGet, 30000)
        XCTAssertEqual(emitter.byteLimitPost, 35000)
        XCTAssertEqual(emitter.protocol, .https)

        let customPathEmitter = Emitter(
            namespace: "ns2",
            urlEndpoint: TEST_SERVER_EMITTER,
            method: .post,
            protocol: .https,
            customPostPath: "/com.acme.company/tpx"
        ) { emitter in
            emitter.byteLimitGet = 30000
            emitter.byteLimitPost = 35000
            emitter.emitRange = 500
        }

        let customUrl = "\(`protocol`)://\(TEST_SERVER_EMITTER)/com.acme.company/tpx"
        XCTAssertTrue((customPathEmitter.urlEndpoint == customUrl))

        // Test setting variables to new values

        emitter.urlEndpoint = "www.test.com"
        url = "\(`protocol`)://www.test.com/com.snowplowanalytics.snowplow/tp2"
        XCTAssertTrue((emitter.urlEndpoint == url))
        emitter.method = .get
        XCTAssertEqual(emitter.method, .get)
        url = "\(`protocol`)://www.test.com/i"
        XCTAssertTrue((emitter.urlEndpoint == url))
        emitter.emitRange = 1000
        XCTAssertEqual(emitter.emitRange, 1000)
        emitter.emitThreadPoolSize = 50
        XCTAssertEqual(emitter.emitThreadPoolSize, 50)
        emitter.byteLimitGet = 1000
        XCTAssertEqual(emitter.byteLimitGet, 1000)
        emitter.byteLimitPost = 50
        XCTAssertEqual(emitter.byteLimitPost, 50)

        // Test extra functions
        XCTAssertFalse(emitter.isSending)
        XCTAssertTrue(dbCount(emitter) >= 0)

        // Allow timer to be set
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        emitter.resumeTimer()
        
        flush(emitter)
    }

    // MARK: - Emitting tests

//    func testEmitEventWithBrokenNetworkConnectionDoesntFreezeStatus() {
//        let networkConnection = SPBrokenNetworkConnection()
//        let emitter = self.emitter(with: networkConnection, bufferOption: SPBufferOptionSingle)
//        emitter?.addPayload(toBuffer: generatePayloads(1)?.first)
//
//        Thread.sleep(forTimeInterval: 1)
//
//        XCTAssertFalse(emitter?.getSendingStatus())
//
//        emitter?.flush()
//    }

    func testEmitSingleGetEventWithSuccess() {
        let networkConnection = MockNetworkConnection(requestOption: .get, statusCode: 200)
        let emitter = self.emitter(with: networkConnection, bufferOption: .single)
        addPayload(generatePayloads(1).first!, emitter)

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(1, networkConnection.previousResults.count)
        XCTAssertEqual(1, networkConnection.previousResults.first!.count)
        XCTAssertTrue(networkConnection.previousResults.first!.first!.isSuccessful)
        XCTAssertEqual(0, dbCount(emitter))

        flush(emitter)
    }

    func testEmitSingleGetEventWithNoSuccess() {
        let networkConnection = MockNetworkConnection(requestOption: .get, statusCode: 500)
        let emitter = self.emitter(with: networkConnection, bufferOption: .single)
        addPayload(generatePayloads(1).first!, emitter)

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(1, networkConnection.previousResults.count)
        XCTAssertEqual(1, networkConnection.previousResults.first!.count)
        XCTAssertFalse(networkConnection.previousResults.first!.first!.isSuccessful)
        XCTAssertEqual(1, dbCount(emitter))

        flush(emitter)
    }

    func testEmitTwoGetEventsWithSuccess() {
        let networkConnection = MockNetworkConnection(requestOption: .get, statusCode: 200)
        let emitter = self.emitter(with: networkConnection, bufferOption: .single)

        for payload in generatePayloads(2) {
            addPayload(payload, emitter)
        }

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(0, dbCount(emitter))
        var totEvents = 0
        for results in networkConnection.previousResults {
            for result in results {
                XCTAssertTrue(result.isSuccessful)
                totEvents += result.storeIds?.count ?? 0
            }
        }
        XCTAssertEqual(2, totEvents)

        flush(emitter)
    }

    func testEmitTwoGetEventsWithNoSuccess() {
        let networkConnection = MockNetworkConnection(requestOption: .get, statusCode: 500)
        let emitter = self.emitter(with: networkConnection, bufferOption: .single)

        for payload in generatePayloads(2) {
            addPayload(payload, emitter)
        }

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(2, dbCount(emitter))
        for results in networkConnection.previousResults {
            for result in results {
                XCTAssertFalse(result.isSuccessful)
            }
        }

        flush(emitter)
    }

    func testEmitSinglePostEventWithSuccess() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 200)
        let emitter = self.emitter(with: networkConnection, bufferOption: .single)

        addPayload(generatePayloads(1).first!, emitter)

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(1, networkConnection.previousResults.count)
        XCTAssertEqual(1, networkConnection.previousResults.first?.count)
        XCTAssertTrue(networkConnection.previousResults.first!.first!.isSuccessful)
        XCTAssertEqual(0, dbCount(emitter))

        flush(emitter)
    }

    func testEmitEventsPostAsGroup() {
        let payloads = generatePayloads(15)
        
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 500)
        let emitter = self.emitter(with: networkConnection, bufferOption: .defaultGroup)
        
        for i in 0..<14 {
            addPayload(payloads[i], emitter)
        }

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(14, dbCount(emitter))
        networkConnection.statusCode = 200
        let prevSendingCount = networkConnection.sendingCount
        addPayload(payloads[14], emitter)

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(0, dbCount(emitter))
        var totEvents = 0
        var areGrouped = false
        let prevResults = networkConnection.previousResults[prevSendingCount..<networkConnection.previousResults.count]
        for results in prevResults {
            for result in results {
                XCTAssertTrue(result.isSuccessful)
                let ids = result.storeIds?.count ?? 0
                totEvents += ids
                areGrouped = areGrouped || ids > 1
            }
        }
        XCTAssertEqual(15, totEvents)
        XCTAssertTrue(areGrouped)

        flush(emitter)
    }

    func testEmitOversizeEventsPostAsGroup() {
        let networkConnection = MockNetworkConnection(requestOption: .post, statusCode: 500)
        let emitter = self.emitter(with: networkConnection, bufferOption: .defaultGroup)
        emitter.byteLimitPost = 5

        let payloads = generatePayloads(15)
        for i in 0..<14 {
            addPayload(payloads[i], emitter)
        }

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(0, dbCount(emitter))
        networkConnection.statusCode = 200
        _ = networkConnection.sendingCount
        addPayload(payloads[14], emitter)

        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 1)
        }

        XCTAssertEqual(0, dbCount(emitter))

        flush(emitter)
    }

    func testRemovesEventsFromQueueOnNoRetryStatus() {
        let networkConnection = MockNetworkConnection(requestOption: .get, statusCode: 403)
        let emitter = self.emitter(with: networkConnection, bufferOption: .single)

        addPayload(generatePayloads(1).first!, emitter)

        Thread.sleep(forTimeInterval: 1)

        XCTAssertEqual(0, dbCount(emitter))
        for results in networkConnection.previousResults {
            for result in results {
                XCTAssertFalse(result.isSuccessful)
            }
        }

        flush(emitter)
    }

    func testFollowCustomRetryRules() {
        let networkConnection = MockNetworkConnection(requestOption: .get, statusCode: 500)
        let emitter = self.emitter(with: networkConnection, bufferOption: .single)

        var customRules: [Int : Bool] = [:]
        customRules[403] = true
        customRules[500] = false
        emitter.customRetryForStatusCodes = customRules

        addPayload(generatePayloads(1).first!, emitter)

        Thread.sleep(forTimeInterval: 1)

        // no events in queue since they were dropped because retrying is disabled for 500
        XCTAssertEqual(0, dbCount(emitter))

        networkConnection.statusCode = 403

        addPayload(generatePayloads(1).first!, emitter)

        Thread.sleep(forTimeInterval: 1)

        // event still in queue because retrying is enabled for 403
        XCTAssertEqual(1, dbCount(emitter))

        flush(emitter)
    }
    
    func testDoesNotRetryFailedRequestsIfDisabled() {
        let networkConnection = MockNetworkConnection(requestOption: .get, statusCode: 500)
        let emitter = self.emitter(with: networkConnection, bufferOption: .single)
        emitter.retryFailedRequests = false

        addPayload(generatePayloads(1).first!, emitter)

        Thread.sleep(forTimeInterval: 1)

        // no events in queue since they were dropped because retrying is disabled
        XCTAssertEqual(0, dbCount(emitter))

        emitter.retryFailedRequests = true

        addPayload(generatePayloads(1).first!, emitter)

        Thread.sleep(forTimeInterval: 1)

        // event still in queue because retrying is enabled
        XCTAssertEqual(1, dbCount(emitter))

        flush(emitter)
    }

    // MARK: - Emitter builder

    func emitter(with networkConnection: NetworkConnection, bufferOption: BufferOption = .single) -> Emitter {
        let emitter = Emitter(networkConnection: networkConnection, namespace: "ns1", eventStore: MockEventStore()) { emitter in
            emitter.bufferOption = bufferOption
            emitter.emitRange = 200
            emitter.byteLimitGet = 20000
            emitter.byteLimitPost = 25000
        }
        return emitter
    }

    // MARK: - Service methods

    func generatePayloads(_ count: Int) -> [Payload] {
        var payloads: [Payload] = []
        for i in 0..<count {
            let payload = Payload()
            payload.addValueToPayload(NSNumber(value: i).description, forKey: "a")
            payloads.append(payload)
        }
        return payloads
    }
    
    private func addPayload(_ eventPayload: Payload, _ emitter: Emitter) {
        InternalQueue.sync {
            emitter.addPayload(toBuffer: eventPayload)
        }
    }
    
    private func flush(_ emitter: Emitter) {
        InternalQueue.sync {
            emitter.flush()
        }
    }
    
    private func dbCount(_ emitter: Emitter) -> Int {
        return InternalQueue.sync {
            emitter.dbCount
        }
    }
}
//#pragma clang diagnostic pop
