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

// MARK: - Mocks

// MARK: - Tests

class TestRequest: XCTestCase, RequestCallback {
    private var successCount = 0
    private var failureCount = 0

    override func setUp() {
        super.setUp()
        successCount = 0
        failureCount = 0
    }

    override func tearDown() {
        super.tearDown()
    }

    // Tests

    func testRequestSendWithPost() {
        let mockStore = MockEventStore()
        let tracker = getTrackerWithRequestType(.post, resultCode: 200, eventStore: mockStore)
        let sentEventsCount = sendAll(tracker)
        forceFlushes(5, emitter: tracker.emitter)

        XCTAssertEqual(successCount, sentEventsCount)
        XCTAssertEqual(tracker.emitter.dbCount, 0, String(format: "Error on mockStore db: %@", [mockStore.db]))
    }

    func testRequestSendWithGet() {
        let mockStore = MockEventStore()
        let tracker = getTrackerWithRequestType(.get, resultCode: 200, eventStore: mockStore)
        let sentEventsCount = sendAll(tracker)
        forceFlushes(5, emitter: tracker.emitter)
        XCTAssertEqual(successCount, sentEventsCount)
        XCTAssertEqual(tracker.emitter.dbCount, 0, String(format: "Error on mockStore db: %@", [mockStore.db]))
    }

    func testRequestSendWithBadUrl() {
        let mockConnection = MockNetworkConnection(requestOption: .post, statusCode: 404)
        let mockStore = MockEventStore()

        // Send all events with a bad URL
        let tracker = getTrackerWith(mockConnection, eventStore: mockStore)
        let sentEventsCount = sendAll(tracker)
        forceFlushes(5, emitter: tracker.emitter)
        XCTAssertGreaterThan(failureCount, 0)
        XCTAssertEqual(successCount, 0)
        XCTAssertEqual(tracker.emitter.dbCount, sentEventsCount, String(format: "Error on mockStore db: %@", [mockStore.db]))

        // Update the URL and flush
        tracker.pauseEventTracking()
        Thread.sleep(forTimeInterval: 5)
        mockConnection.statusCode = 200
        tracker.resumeEventTracking()

        forceFlushes(5, emitter: tracker.emitter)
        XCTAssertEqual(successCount, 7)
        XCTAssertEqual(tracker.emitter.dbCount, 0, String(format: "Error on mockStore db: %@", [mockStore.db]))
    }

    func testRequestSendWithoutSubject() {
        let mockStore = MockEventStore()
        let tracker = getTrackerWithRequestType(.get, resultCode: 200, eventStore: mockStore)
        tracker.subject = nil
        let sentEventsCount = sendAll(tracker)
        forceFlushes(5, emitter: tracker.emitter)
        XCTAssertEqual(successCount, sentEventsCount)
        XCTAssertEqual(tracker.emitter.dbCount, 0, String(format: "Error on mockStore db: %@", [mockStore.db]))
    }

    func testRequestSendWithCollectionOff() {
        let mockStore = MockEventStore()
        let tracker = getTrackerWithRequestType(.post, resultCode: 200, eventStore: mockStore)
        tracker.pauseEventTracking()
        _ = sendAll(tracker)
        forceFlushes(5, emitter: tracker.emitter)
        XCTAssertEqual(failureCount, 0)
        XCTAssertEqual(successCount, 0)
        XCTAssertEqual(tracker.emitter.dbCount, 0, String(format: "Error on mockStore db: %@", mockStore.db))
    }

    // Helpers

    func getTrackerWith(_ mockNetworkConnection: NetworkConnection, eventStore mockEventStore: EventStore) -> Tracker {
        let networkConfig = NetworkConfiguration(networkConnection: mockNetworkConnection)
        let trackerConfig = TrackerConfiguration(appId: "anAppId")
        trackerConfig.platformContext = true
        trackerConfig.geoLocationContext = true
        trackerConfig.base64Encoding = false
        trackerConfig.sessionContext = true
        let emitterConfig = EmitterConfiguration()
        emitterConfig.requestCallback = self
        emitterConfig.eventStore = mockEventStore
        let serviceProvider = ServiceProvider(namespace: "aNamespace", network: networkConfig, configurations: [trackerConfig, emitterConfig])
        return serviceProvider.tracker
    }

    func getTrackerWithRequestType(_ type: HttpMethodOptions, resultCode: Int, eventStore mockEventStore: EventStore) -> Tracker {
        let mockConnection = MockNetworkConnection(requestOption: type, statusCode: resultCode)
        return getTrackerWith(mockConnection, eventStore: mockEventStore)
    }

    func forceFlushes(_ count: Int, emitter: Emitter?) {
        Thread.sleep(forTimeInterval: 3)
        for _ in 0..<count {
            if emitter?.dbCount == 0 {
                break
            }
            InternalQueue.sync {
                emitter?.flush()
            }
            Thread.sleep(forTimeInterval: 5)
        }
        Thread.sleep(forTimeInterval: 3)
    }

    // Callback

    func onSuccess(withCount successCount: Int) {
        self.successCount += successCount
    }

    func onFailure(withCount failureCount: Int, successCount: Int) {
        self.successCount += successCount
        self.failureCount += failureCount
    }

    // Pre-Built Events for sending!

    func sendAll(_ tracker: Tracker) -> Int {
        return trackStructuredEvent(with: tracker) + trackUnstructuredEvent(with: tracker) + trackPageView(with: tracker) + trackScreenView(with: tracker) + trackTimingWithCategory(with: tracker) + trackEcommerceTransaction(with: tracker)
    }

    func trackStructuredEvent(with tracker_: Tracker) -> Int {
        let event = Structured(category: "DemoCategory", action: "DemoAction")
        event.label = "DemoLabel"
        event.property = "DemoProperty"
        event.value = NSNumber(value: 5)
        event.entities = customContext()
        track(event, tracker_)
        return 1
    }

    func trackUnstructuredEvent(with tracker_: Tracker) -> Int {
        var data: [String : NSObject] = [:]
        data["level"] = NSNumber(value: 23)
        data["score"] = NSNumber(value: 56473)
        let sdj = SelfDescribingJson(
            schema: "iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0",
            andDictionary: data)
        let event = SelfDescribing(eventData: sdj)
        event.entities = customContext()
        track(event, tracker_)
        return 1
    }

    func trackPageView(with tracker_: Tracker) -> Int {
        let event = PageView(pageUrl: "DemoPageUrl")
        event.pageTitle = "DemoPageTitle"
        event.referrer = "DemoPageReferrer"
        event.entities = customContext()
        track(event, tracker_)
        return 1
    }

    func trackScreenView(with tracker_: Tracker) -> Int {
        let event = ScreenView(name: "DemoScreenName", screenId: nil)
        event.entities = customContext()
        track(event, tracker_)
        return 1
    }

    func trackTimingWithCategory(with tracker_: Tracker) -> Int {
        let event = Timing(category: "DemoTimingCategory", variable: "DemoTimingVariable", timing: 5)
        event.label = "DemoTimingLabel"
        event.entities = customContext()
        track(event, tracker_)
        return 1
    }

    func trackEcommerceTransaction(with tracker_: Tracker) -> Int {
        let transactionID = "6a8078be"

        let item = EcommerceItem(sku: "DemoItemSku", price: 0.75, quantity: 1)
        item.name = "DemoItemName"
        item.category = "DemoItemCategory"
        item.currency = "USD"
        item.entities = customContext()

        let event = Ecommerce(orderId: transactionID, totalValue: 350, items: [item])
        event.affiliation = "DemoTranAffiliation"
        event.taxValue = 10;
        event.shipping = 15;
        event.city = "Boston"
        event.state = "Massachusetts"
        event.country = "USA"
        event.currency = "USD"
        event.entities = customContext()
        track(event, tracker_)
        return 2
    }

    func customContext() -> [SelfDescribingJson] {
        let data = [
            "snowplow": "demo-tracker"
        ]
        let context = SelfDescribingJson(
            schema: "iglu:com.acme_company/demo_ios/jsonschema/1-0-0",
            andDictionary: data)
        return [context]
    }
    
    private func track(_ event: Event, _ tracker: Tracker) {
        InternalQueue.sync {
            _ = tracker.track(event)
        }
    }
}
