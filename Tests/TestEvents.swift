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
@testable import SnowplowTracker

class TestEvents: XCTestCase {
    func testTrueTimestamp() {
        let event = PageView(pageUrl: "DemoPageUrl")
        XCTAssertNil(event.trueTimestamp)

        // Set trueTimestamp
        let testDate = Date()
        event.trueTimestamp = testDate
        XCTAssertEqual(event.trueTimestamp, testDate)
    }

    func testEntities() {
        let event = ScreenView(name: "screen")
        let entity1 = SelfDescribingJson(schema: "schema1", andData: [String:NSObject]())
        let entity2 = SelfDescribingJson(schema: "schema2", andData: [String:NSObject]())
        let entity3 = SelfDescribingJson(schema: "schema3", andData: [String:NSObject]())
        
        event.entities.append(entity1)
        XCTAssertEqual(1, event.entities.count)
        
        _ = event.entities([entity2])
        XCTAssertEqual(2, event.entities.count)

        _ = event.contexts([entity3])
        XCTAssertEqual(3, event.entities.count)
        
        XCTAssertEqual(3, event.contexts.count)
        XCTAssertTrue(event.entities.contains(entity1))
        XCTAssertTrue(event.entities.contains(entity2))
        XCTAssertTrue(event.entities.contains(entity3))
    }

    func testApplicationInstall() {
        // Prepare ApplicationInstall event
        let installEvent = SelfDescribingJson(schema: kSPApplicationInstallSchema, andDictionary: [String:NSObject]())
        let event = SelfDescribing(eventData: installEvent)
        let currentTimestamp = Date(timeIntervalSince1970: 12345)
        event.trueTimestamp = currentTimestamp

        // Setup tracker
        let trackerConfiguration = TrackerConfiguration()
        trackerConfiguration.base64Encoding = false
        trackerConfiguration.installAutotracking = false
        let eventStore = MockEventStore()
        let networkConfiguration = NetworkConfiguration(endpoint: "fake-url", method: .post)
        let emitterConfiguration = EmitterConfiguration()
        emitterConfiguration.eventStore = eventStore
        emitterConfiguration.threadPoolSize = 10
        let trackerController = Snowplow.createTracker(namespace: "namespace", network: networkConfiguration, configurations: [trackerConfiguration, emitterConfiguration])

        // Track event
        _ = trackerController.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        let events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        let payload = events.first?.payload

        // Check v_tracker field
        let deviceTimestamp = payload?["dtm"] as? String
        let expected = String(format: "%lld", Int64(currentTimestamp.timeIntervalSince1970 * 1000))
        XCTAssertEqual(expected, deviceTimestamp)
    }

    func testWorkaroundForCampaignAttributionEnrichment() {
        // Prepare DeepLinkReceived event
        let event = DeepLinkReceived(url: "url")
        event.referrer = "referrer"

        // Setup tracker
        let trackerConfiguration = TrackerConfiguration()
        trackerConfiguration.base64Encoding = false
        trackerConfiguration.installAutotracking = false
        let eventStore = MockEventStore()
        let networkConfiguration = NetworkConfiguration(endpoint: "fake-url", method: .post)
        let emitterConfiguration = EmitterConfiguration()
        emitterConfiguration.eventStore = eventStore
        emitterConfiguration.threadPoolSize = 10
        let trackerController = Snowplow.createTracker(namespace: "namespace", network: networkConfiguration, configurations: [trackerConfiguration, emitterConfiguration])

        // Track event
        _ = trackerController.track(event)
        for _ in 0..<1 {
            Thread.sleep(forTimeInterval: 1)
        }
        let events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(1, events.count)
        let payload = events.first?.payload

        // Check url and referrer fields
        let url = payload?[kSPPageUrl] as? String
        let referrer = payload?[kSPPageRefr] as? String
        XCTAssertEqual(url, "url")
        XCTAssertEqual(referrer, "referrer")
    }

    func testDeepLinkContextAndAtomicPropertiesAddedToScreenView() {
        // Prepare DeepLinkReceived event
        let deepLink = DeepLinkReceived(url: "someappwithaverylongscheme://the_url")
        deepLink.referrer = "someappwithaverylongscheme://the_referrer"

        // Prepare ScreenView event
        let screenView = ScreenView(name: "SV", screenId: UUID())

        // Setup tracker
        let trackerConfiguration = TrackerConfiguration()
        trackerConfiguration.base64Encoding = false
        trackerConfiguration.installAutotracking = false
        let eventStore = MockEventStore()
        let networkConfiguration = NetworkConfiguration(endpoint: "fake-url", method: .post)
        let emitterConfiguration = EmitterConfiguration()
        emitterConfiguration.eventStore = eventStore
        emitterConfiguration.threadPoolSize = 10
        let trackerController = Snowplow.createTracker(namespace: "namespace", network: networkConfiguration, configurations: [trackerConfiguration, emitterConfiguration])

        // Track event
        _ = trackerController.track(deepLink)
        let screenViewId = trackerController.track(screenView)
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 1)
        }
        let events = eventStore.emittableEvents(withQueryLimit: 10)
        _ = eventStore.removeAllEvents()
        XCTAssertEqual(2, events.count)

        var screenViewPayload: Payload? = nil
        for event in events {
            if (event.payload.dictionary["eid"] as? String) == screenViewId.uuidString {
                screenViewPayload = event.payload
            }
        }
        XCTAssertNotNil(screenViewPayload)

        // Check the DeepLink context entity properties
        let screenViewContext = screenViewPayload?["co"] as? String
        XCTAssertTrue(screenViewContext?.contains("\"referrer\":\"someappwithaverylongscheme:\\/\\/the_referrer\"") ?? false)
        XCTAssertTrue(screenViewContext?.contains("\"url\":\"someappwithaverylongscheme:\\/\\/the_url\"") ?? false)

        // Check url and referrer fields for atomic table
        let url = screenViewPayload?[kSPPageUrl] as? String
        let referrer = screenViewPayload?[kSPPageRefr] as? String
        XCTAssertEqual(url, "someappwithavery://the_url")
        XCTAssertEqual(referrer, "someappwithavery://the_referrer")
    }

    func testPageView() {
        let event = PageView(pageUrl: "DemoPageUrl")
        XCTAssertEqual("DemoPageUrl", event.payload["url"] as? String)
    }

    func testStructured() {
        let event = Structured(category: "category", action: "action")
        XCTAssertEqual("category", event.payload["se_ca"] as? String)
        XCTAssertEqual("action", event.payload["se_ac"] as? String)
    }

    func testSelfDescribing() {
        var data: [String : Any] = [:]
        data["level"] = 23
        data["score"] = 56473
        let sdj = SelfDescribingJson(
            schema: "iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0",
            andDictionary: data)
        let event = SelfDescribing(eventData: sdj)
        XCTAssertEqual("iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0", event.schema)
        XCTAssertEqual(23, event.payload["level"] as? Int)
    }

    func testSelfDescribingWithEncodableData() {
        struct Data: Encodable {
            var level: Int
            var score: Int
        }
        
        let data = Data(level: 23, score: 56473)
        let event = try? SelfDescribing(
            schema: "iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0",
            data: data
        )
        XCTAssertNotNil(event)
        XCTAssertEqual("iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0", event?.schema)
        XCTAssertEqual(23, event?.payload["level"] as? Int)
    }
    
    // MARK: - SelfDescribing Encodable Serialization Tests
    
    func testSelfDescribingWithEncodableAndCustomEncoder() {
        struct GameEvent: Encodable {
            var eventType: String
            var timestamp: Date
            var playerId: String
            var metadata: [String: Any]
            
            enum CodingKeys: String, CodingKey {
                case eventType, timestamp, playerId, metadata
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(eventType, forKey: .eventType)
                try container.encode(timestamp, forKey: .timestamp)
                try container.encode(playerId, forKey: .playerId)
                // Convert Any values to encodable types
                let encodableMetadata = metadata.compactMapValues { value -> String? in
                    return String(describing: value)
                }
                try container.encode(encodableMetadata, forKey: .metadata)
            }
        }
        
        let customEncoder = JSONEncoder()
        customEncoder.dateEncodingStrategy = .millisecondsSince1970
        
        let gameEvent = GameEvent(
            eventType: "level_completed",
            timestamp: Date(timeIntervalSince1970: 1640995200), // 2022-01-01T00:00:00Z
            playerId: "player_123",
            metadata: ["level": 5, "score": 1500, "time_taken": 120.5]
        )
        
        let event = try? SelfDescribing(
            schema: "iglu:com.game/level_completion/jsonschema/1-0-0",
            encoder: customEncoder,
            data: gameEvent
        )
        
        XCTAssertNotNil(event)
        XCTAssertEqual("iglu:com.game/level_completion/jsonschema/1-0-0", event?.schema)
        XCTAssertEqual("level_completed", event?.payload["eventType"] as? String)
        XCTAssertEqual("player_123", event?.payload["playerId"] as? String)
        XCTAssertEqual(1640995200000, event?.payload["timestamp"] as? Double) // milliseconds
        
        let metadata = event?.payload["metadata"] as? [String: String]
        XCTAssertNotNil(metadata)
        XCTAssertEqual("5", metadata?["level"])
        XCTAssertEqual("1500", metadata?["score"])
        XCTAssertEqual("120.5", metadata?["time_taken"])
    }
    
    func testSelfDescribingWithComplexNestedEncodableData() {
        struct Purchase: Encodable {
            var orderId: String
            var customerId: String
            var items: [PurchaseItem]
            var paymentInfo: PaymentInfo
            var discounts: [String]?
            var totalAmount: Double
        }
        
        struct PurchaseItem: Encodable {
            var productId: String
            var name: String
            var quantity: Int
            var pricePerUnit: Double
        }
        
        struct PaymentInfo: Encodable {
            var method: String
            var cardLast4: String?
            var transactionId: String
        }
        
        let purchase = Purchase(
            orderId: "ORD-12345",
            customerId: "CUST-67890",
            items: [
                PurchaseItem(productId: "PROD-001", name: "T-Shirt", quantity: 2, pricePerUnit: 25.99),
                PurchaseItem(productId: "PROD-002", name: "Jeans", quantity: 1, pricePerUnit: 89.99)
            ],
            paymentInfo: PaymentInfo(method: "credit_card", cardLast4: "1234", transactionId: "TXN-ABCD"),
            discounts: ["SUMMER10", "LOYALTY5"],
            totalAmount: 131.97
        )
        
        let event = try? SelfDescribing(
            schema: "iglu:com.ecommerce/purchase/jsonschema/1-0-0",
            data: purchase
        )
        
        XCTAssertNotNil(event)
        XCTAssertEqual("iglu:com.ecommerce/purchase/jsonschema/1-0-0", event?.schema)
        XCTAssertEqual("ORD-12345", event?.payload["orderId"] as? String)
        XCTAssertEqual("CUST-67890", event?.payload["customerId"] as? String)
        XCTAssertEqual(131.97, event?.payload["totalAmount"] as? Double)
        
        let items = event?.payload["items"] as? [[String: Any]]
        XCTAssertEqual(2, items?.count)
        XCTAssertEqual("PROD-001", items?[0]["productId"] as? String)
        XCTAssertEqual("T-Shirt", items?[0]["name"] as? String)
        XCTAssertEqual(2, items?[0]["quantity"] as? Int)
        XCTAssertEqual(25.99, items?[0]["pricePerUnit"] as? Double)
        
        let paymentInfo = event?.payload["paymentInfo"] as? [String: Any]
        XCTAssertNotNil(paymentInfo)
        XCTAssertEqual("credit_card", paymentInfo?["method"] as? String)
        XCTAssertEqual("1234", paymentInfo?["cardLast4"] as? String)
        XCTAssertEqual("TXN-ABCD", paymentInfo?["transactionId"] as? String)
        
        let discounts = event?.payload["discounts"] as? [String]
        XCTAssertEqual(["SUMMER10", "LOYALTY5"], discounts)
    }
    
    func testSelfDescribingWithEncodableArrayThrowsError() {
        struct ArrayData: Encodable {
            var values: [String]
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                for value in values {
                    try container.encode(value)
                }
            }
        }
        
        let arrayData = ArrayData(values: ["value1", "value2", "value3"])
        
        XCTAssertThrowsError(
            try SelfDescribing(
                schema: "iglu:com.test/array_data/jsonschema/1-0-0",
                data: arrayData
            )
        ) { error in
            XCTAssertTrue(error is PayloadError)
            if case PayloadError.jsonSerializationToDictionaryFailed = error {
                // Expected error type
            } else {
                XCTFail("Expected PayloadError.jsonSerializationToDictionaryFailed")
            }
        }
    }
    
    func testSelfDescribingWithEncodablePrimitiveThrowsError() {
        struct PrimitiveData: Encodable {
            var message: String
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(message)
            }
        }
        
        let primitiveData = PrimitiveData(message: "This will encode as a string, not an object")
        
        XCTAssertThrowsError(
            try SelfDescribing(
                schema: "iglu:com.test/primitive_data/jsonschema/1-0-0",
                data: primitiveData
            )
        ) { error in
            XCTAssertTrue(error is PayloadError)
            if case PayloadError.jsonSerializationToDictionaryFailed = error {
                // Expected error type
            } else {
                XCTFail("Expected PayloadError.jsonSerializationToDictionaryFailed")
            }
        }
    }
    
    func testSelfDescribingWithInvalidEncodableThrowsEncodingError() {
        struct FailingEncodable: Encodable {
            func encode(to encoder: Encoder) throws {
                throw EncodingError.invalidValue(
                    self,
                    EncodingError.Context(
                        codingPath: [],
                        debugDescription: "This struct intentionally fails to encode"
                    )
                )
            }
        }
        
        let failingData = FailingEncodable()
        
        XCTAssertThrowsError(
            try SelfDescribing(
                schema: "iglu:com.test/failing_data/jsonschema/1-0-0",
                data: failingData
            )
        ) { error in
            XCTAssertTrue(error is EncodingError)
        }
    }
    
    func testSelfDescribingWithEncodableOptionalFields() {
        struct EventData: Encodable {
            var eventId: String
            var userId: String?
            var sessionId: String?
            var customProperties: [String: String]?
            var timestamp: Double
        }
        
        let eventData = EventData(
            eventId: "evt_123",
            userId: "user_456", // Present
            sessionId: nil, // Should be omitted
            customProperties: ["source": "mobile", "version": "2.1.0"], // Present
            timestamp: 1640995200.123
        )
        
        let event = try? SelfDescribing(
            schema: "iglu:com.analytics/custom_event/jsonschema/1-0-0",
            data: eventData
        )
        
        XCTAssertNotNil(event)
        XCTAssertEqual("iglu:com.analytics/custom_event/jsonschema/1-0-0", event?.schema)
        XCTAssertEqual("evt_123", event?.payload["eventId"] as? String)
        XCTAssertEqual("user_456", event?.payload["userId"] as? String)
        XCTAssertEqual(1640995200.123, event?.payload["timestamp"] as? Double)
        
        // sessionId should not be present (nil optional)
        XCTAssertFalse(event?.payload.keys.contains("sessionId") ?? true)
    }

    func testConsentWithdrawn() {
        let event = ConsentWithdrawn()
        event.name = "name"
        event.all = false
        event.version = "3"
        event.documentId = "1000"
        event.documentDescription = "description"
        XCTAssertEqual(false, event.payload["all"] as? Bool)
        XCTAssertEqual(1, event.allDocuments.count)
    }

    func testConsentGranted() {
        let event = ConsentGranted(expiry: "expiry", documentId: "1000", version: "3")
        event.name = "name"
        event.documentDescription = "description"
        XCTAssertEqual("expiry", event.payload["expiry"] as? String)
    }

    func testScreenView() {
        let screenId = UUID()

        let event = ScreenView(name: "name", screenId: screenId)
        XCTAssertEqual("name", event.payload["name"] as? String)
    }

    func testTiming() {
        let event = Timing(category: "cat", variable: "var", timing: 5)
        XCTAssertEqual("cat", event.payload["category"] as? String)
    }

    func testEcommerce() {
        let event = Ecommerce(orderId: "id", totalValue: 5, items: [])
        XCTAssertEqual("id", event.payload["tr_id"] as? String)
    }

    func testEcommerceItem() {
        let event = EcommerceItem(sku: "sku", price: 5.3, quantity: 5)
        XCTAssertEqual("sku", event.payload["ti_sk"] as? String)
    }

    func testPushNotificationContent() {
        let attachments = [
            [
                "identifier": "id",
                "url": "www.test.com",
                "type": "test"
            ],
            [
                "identifier": "id2",
                "url": "www.test2.com",
                "type": "test2"
            ]
        ]
        
        let userInfo = [
            "aps": [
                "alert": "test",
                "sound": "sound",
                "category": "category"
            ]
        ]
        
        let event = NotificationContent(title: "title", body: "body", badge: NSNumber(value: 5))
        event.subtitle = "subtitle"
        event.sound = "sound"
        event.launchImageName = "image"
        event.userInfo = userInfo
        event.attachments = attachments as [NSObject]
        XCTAssertEqual("sound", event.payload["sound"] as? String)
    }

    func testPushNotification() {
        let attachments = [
            [
                "identifier": "id",
                "url": "www.test.com",
                "type": "test"
            ],
            [
                "identifier": "id2",
                "url": "www.test2.com",
                "type": "test2"
            ]
        ]
        
        let userInfo = [
            "aps": [
                "alert": [
                    "title": "test-title",
                    "body": "test-body"
                ]
            ]
        ]
        
        let content = NotificationContent(title: "title", body: "body", badge: NSNumber(value: 5))
        content.subtitle = "subtitle"
        content.sound = "sound"
        content.launchImageName = "image"
        content.userInfo = userInfo
        content.attachments = attachments as [NSObject]

        let event = PushNotification(
            date: "date",
            action: "action",
            trigger: "PUSH",
            category: "category",
            thread: "thread",
            notification: content)
        XCTAssertEqual("action", event.payload["action"] as? String)
    }

    func testMessageNotification() {
        let event = MessageNotification(title: "title", body: "body", trigger: .push)
        event.notificationTimestamp = "2020-12-31T15:59:60-08:00"
        event.action = "action"
        event.bodyLocKey = "loc key"
        event.bodyLocArgs = ["loc arg1", "loc arg2"]
        event.sound = "chime.mp3"
        // TODO: commented out because Obj-C does not support the property
        //    event.notificationCount = @9;
        event.category = "category1"
        event.attachments = [
            MessageNotificationAttachment(identifier: "id", type: "type", url: "url")
        ]

        let payload = event.payload
        XCTAssertEqual("title", payload["title"] as? String)
        XCTAssertEqual("body", payload["body"] as? String)
        XCTAssertEqual("2020-12-31T15:59:60-08:00", payload["notificationTimestamp"] as? String)
        XCTAssertEqual("push", payload["trigger"] as? String)
        XCTAssertEqual("action", payload["action"] as? String)
        XCTAssertEqual("loc key", payload["bodyLocKey"] as? String)
        let locArgs = (payload["bodyLocArgs"]) as? [String]
        XCTAssertNotNil(locArgs)
        XCTAssertEqual(2, (locArgs?.count ?? 0))
        XCTAssertEqual("loc arg1", locArgs?[0])
        XCTAssertEqual("loc arg2", locArgs?[1])
        XCTAssertEqual("chime.mp3", payload["sound"] as? String)
        //    XCTAssertEqualObjects(@9, payload["notificationCount"]);
        XCTAssertEqual("category1", payload["category"] as? String)
        let attachments = (payload["attachments"]) as? [[String : Any]]
        XCTAssertNotNil(attachments)
        XCTAssertEqual(1, (attachments?.count ?? 0))
        let attachment = attachments?[0] as? [String : Any]
        XCTAssertEqual("id", attachment?["identifier"] as? String)
        XCTAssertEqual("type", attachment?["type"] as? String)
        XCTAssertEqual("url", attachment?["url"] as? String)
    }

    func testMessageNotificationWithUserInfo() {
        let userInfo: [String : Any] = [
            "aps": [
                "alert": [
                    "title": "test-title",
                    "body": "test-body",
                    "loc-key": "loc key",
                    "loc-args": ["loc arg1", "loc arg2"]
                ],
                "sound": "chime.aiff",
                "badge": 9,
                "category": "category1",
                "content-available": 1
            ],
            "custom-element": 1
        ]
        let event = MessageNotification.messageNotification(userInfo: userInfo, defaultTitle: nil, defaultBody: nil)!
        let payload = event.payload
        XCTAssertEqual("test-title", payload["title"] as? String)
        XCTAssertEqual("test-body", payload["body"] as? String)
        XCTAssertEqual("loc key", payload["bodyLocKey"] as? String)
        let locArgs = payload["bodyLocArgs"] as? [AnyHashable]
        XCTAssertEqual(2, (locArgs?.count ?? 0))
        XCTAssertEqual("loc arg1", locArgs?[0] as? String)
        XCTAssertEqual("loc arg2", locArgs?[1] as? String)
        XCTAssertEqual(9, payload["notificationCount"] as? Int)
        XCTAssertEqual("chime.aiff", payload["sound"] as? String)
        XCTAssertEqual("category1", payload["category"] as? String)
        XCTAssertEqual(true, payload["contentAvailable"] as? Bool)
    }

    func testError() {
        // Valid construction
        let error = SNOWError(message: "message")
        error.name = "name"
        error.stackTrace = "stacktrace"
        XCTAssertEqual("name", error.payload["exceptionName"] as? String)
    }

    func testTrackerError() {
        let trackerError = TrackerError(source: "classname", message: "message", error: nil, exception: NSException(name: NSExceptionName("CustomException"), reason: "reason", userInfo: nil))
        let payload = trackerError.payload
        XCTAssertEqual(payload["message"] as? String, "message")
        XCTAssertEqual(payload["className"] as? String, "classname")
        XCTAssertEqual(payload["exceptionName"] as? String, "CustomException")
    }
}
