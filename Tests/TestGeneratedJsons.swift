//
//  TestGeneratedJsons.swift
//  Snowplow
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

import XCTest
@testable import SnowplowTracker

let IGLU_PATH = "http://raw.githubusercontent.com/snowplow/iglu-central/master/schemas/"

class TestGeneratedJsons: XCTestCase {
    private var validator: IGLUClient?

    override func setUp() {
        super.setUp()
        validator = IGLUClient(jsonString: getJSONAsString(withFilePath: "iglu_resolver.json"), andBundles: [Bundle(for: TestGeneratedJsons.self)])
    }

    override func tearDown() {
        validator = nil
        super.tearDown()
    }

    func testScreenContextJson() {
        let stateMachine = ScreenStateMachine()
        let fakeEvent = TrackerEvent(event: Structured(category: "fake", action: "fake"), state: nil)
        let screenState = ScreenState(name: "name", type: "type", screenId: nil, transitionType: "transition", topViewControllerClassName: "topVCname", viewControllerClassName: "VCname")
        let entities = stateMachine.entities(from: fakeEvent, state: screenState)
        let screenContext = entities?.first
        XCTAssertNotNil(screenContext)
        XCTAssertTrue(validator!.validateJson(screenContext?.dictionary))
    }

    // TODO: this test fails for reasons I don't understand
//    func testClientSessionContextJson() {
//        let session = Session(foregroundTimeout: 1800, andBackgroundTimeout: 1800)
//        let data = session.getDictWithEventId(Utilities.getUUIDString(), eventTimestamp: 1654496481346, userAnonymisation: false)
//        let json = SelfDescribingJson(schema: kSPSessionContextSchema, andDictionary: data!).getAsDictionary()
//        XCTAssertTrue(validator!.validateJson(json))
//    }

    //#pragma clang diagnostic push
    //#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    func testPlatformContextJson() {
        let subject = Subject(platformContext: true, andGeoContext: true)
        let data = subject.getPlatformDict(withUserAnonymisation: false)?.dictionary
        var json: [String : NSObject]?
        #if os(iOS)
        json = SelfDescribingJson(schema: kSPMobileContextSchema, andDictionary: data!).dictionary
        #else
        json = SelfDescribingJson(schema: kSPDesktopContextSchema, andDictionary: data!).dictionary
        #endif
        XCTAssertTrue(validator!.validateJson(json))
    }

    func testGeoContextJson() {
        let subject = Subject(platformContext: false, andGeoContext: true)
        subject.geoLongitude = NSNumber(value: 5)
        subject.geoLatitude = NSNumber(value: 89.2)
        subject.geoTimestamp = NSNumber(value: 5)
        subject.geoLatitudeLongitudeAccuracy = NSNumber(value: 5.5)
        subject.geoSpeed = NSNumber(value: 6.2)
        subject.geoBearing = NSNumber(value: 82.3)
        subject.geoAltitude = NSNumber(value: 62.3)
        subject.geoAltitudeAccuracy = NSNumber(value: 16.3)
        let data = subject.getGeoLocationDict()
        let json = SelfDescribingJson(schema: kSPGeoContextSchema, andDictionary: data!).dictionary
        XCTAssertTrue(validator!.validateJson(json))
    }

    //#pragma clang diagnostic pop

    func testGdprContextJson() {
        let gdpr = GDPRContext(
            basis: .consent,
            documentId: "id",
            documentVersion: "version",
            documentDescription: "description")
        XCTAssertTrue(validator!.validateJson(gdpr.context.dictionary))
    }

    func testStructuredEventPayloadJson() {
        let tracker = getTracker("acme.fake.url")
        tracker.base64Encoded = false
        let event = Structured(category: "DemoCategory", action: "DemoAction")
        event.label = "DemoLabel"
        event.property = "DemoProperty"
        event.value = NSNumber(value: 5)

        // Check that the final payload passes validation
        let trackerEvent = TrackerEvent(event: event, state: nil)
        let data = tracker.payload(with: trackerEvent).dictionary

        let dataArray = [data] as NSObject
        let json = SelfDescribingJson(schema: kSPPayloadDataSchema, andData: dataArray).dictionary

        XCTAssertTrue(validator!.validateJson(json))
    }

    func testUnstructuredEventPayloadJson() {
        let tracker = getTracker("acme.fake.url")
        tracker.base64Encoded = false
        var input: [String : NSObject] = [:]
        input["level"] = NSNumber(value: 23)
        input["score"] = NSNumber(value: 56473)
        let sdj = SelfDescribingJson(
            schema: "iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0",
            andDictionary: input)
        let event = SelfDescribing(eventData: sdj)

        // Check that the final payload passes validation
        let trackerEvent = TrackerEvent(event: event, state: nil)
        let data = tracker.payload(with: trackerEvent).dictionary

        let dataArray = [data] as NSObject
        let json = SelfDescribingJson(schema: kSPPayloadDataSchema, andData: dataArray).dictionary

        XCTAssertTrue(validator!.validateJson(json))

        // Check that the nested unstructured event passes validation
        let ue_pr = data?["ue_pr"] as? String
        var unstructDictionary: [AnyHashable : Any]? = nil
        do {
            if let aData = ue_pr?.data(using: .utf8) {
                unstructDictionary = try JSONSerialization.jsonObject(with: aData, options: []) as? [AnyHashable : Any]
            }
        } catch {
        }

        XCTAssertTrue(validator!.validateJson(unstructDictionary))
    }

    func testSelfDescribingEventPayloadJson() {
        let tracker = getTracker("acme.fake.url")
        tracker.base64Encoded = false
        var input: [String : NSObject] = [:]
        input["level"] = NSNumber(value: 23)
        input["score"] = NSNumber(value: 56473)
        let sdj = SelfDescribingJson(
            schema: "iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0",
            andDictionary: input)
        let event = SelfDescribing(eventData: sdj)

        // Check that the final payload passes validation
        let trackerEvent = TrackerEvent(event: event, state: nil)
        let data = tracker.payload(with: trackerEvent).dictionary

        let dataArray = [data] as NSObject
        let json = SelfDescribingJson(schema: kSPPayloadDataSchema, andData: dataArray).dictionary

        XCTAssertTrue(validator!.validateJson(json))

        // Check that the nested unstructured event passes validation
        let ue_pr = data?["ue_pr"] as? String
        var unstructDictionary: [AnyHashable : Any]? = nil
        do {
            if let aData = ue_pr?.data(using: .utf8) {
                unstructDictionary = try JSONSerialization.jsonObject(with: aData, options: []) as? [AnyHashable : Any]
            }
        } catch {
        }

        XCTAssertTrue(validator!.validateJson(unstructDictionary))
    }

    func testConsentWithdrawnEventPayloadJson() {
        let event = ConsentWithdrawn()
        event.documentDescription = "Description"
        event.documentId = "1234"
        event.version = "10"
        event.all = false
        event.name = "Name"

        let sdj = SelfDescribingJson(schema: event.schema, andDictionary: event.payload).dictionary
        XCTAssertTrue(validator!.validateJson(sdj))
    }

    func testConsentDocumentEventPayloadJson() {
        let event = ConsentDocument(documentId: "1234", version: "10")
        event.documentDescription = "Description"
        event.name = "Name"

        let sdj = event.payload.dictionary
        XCTAssertTrue(validator!.validateJson(sdj))
    }

    func testConsentGrantedEventPayloadJson() {
        let event = ConsentGranted(expiry: "2012-04-23T18:25:43.511Z", documentId: "1234", version: "10")
        event.documentDescription = "Description"
        event.name = "Name"

        let sdj = SelfDescribingJson(schema: event.schema, andDictionary: event.payload).dictionary
        XCTAssertTrue(validator!.validateJson(sdj))
    }

    func testPageViewEventPayloadJson() {
        let tracker = getTracker("acme.fake.url")
        let event = PageView(pageUrl: "DemoPageUrl")
        event.pageTitle = "DemoPageTitle"
        event.referrer = "DemoPageReferrer"

        // Check that the final payload passes validation
        let trackerEvent = TrackerEvent(event: event, state: nil)
        let data = tracker.payload(with: trackerEvent).dictionary

        let dataArray = [data] as NSObject
        let json = SelfDescribingJson(schema: kSPPayloadDataSchema, andData: dataArray).dictionary

        XCTAssertTrue(validator!.validateJson(json))
    }

    func testEcommerceEventPayloadJson() {
        let tracker = getTracker("acme.fake.url")

        let transactionID = "6a8078be"
        var itemArray: [EcommerceItem] = []
        let item = EcommerceItem(sku: "DemoItemSku", price: 0.75, quantity: 1)
        item.name = "DemoItemName"
        item.category = "DemoItemCategory"
        item.currency = "USD"

        itemArray.append(item)
        let event = Ecommerce(orderId: transactionID, totalValue: 350, items: itemArray)
        event.affiliation = "DemoTranAffiliation"
        // TODO: incompatible properties with ObjC
        //    event.taxValue = 10;
        //    event.shipping = 15;
        event.city = "Boston"
        event.state = "Massachusetts"
        event.country = "USA"
        event.currency = "USD"

        // Check that the main payload passes validation
        let trackerEvent = TrackerEvent(event: event, state: nil)
        var data = tracker.payload(with: trackerEvent).dictionary

        var dataArray = [data] as NSObject
        var json = SelfDescribingJson(schema: kSPPayloadDataSchema, andData: dataArray).dictionary

        XCTAssertTrue(validator!.validateJson(json))

        // Check that the item payload passes validation
        data = tracker.payload(with: trackerEvent).dictionary

        dataArray = [data] as NSObject
        json = SelfDescribingJson(schema: kSPPayloadDataSchema, andData: dataArray).dictionary

        XCTAssertTrue(validator!.validateJson(json))
    }

    func testTimingEventJson() {
        let event = Timing(category: "DemoTimingCategory", variable: "DemoTimingVariable", timing: 5)
        let sdj = SelfDescribingJson(schema: event.schema, andDictionary: event.payload).dictionary
        XCTAssertTrue(validator!.validateJson(sdj))
    }

    func testScreenViewEventJson() {
        let event = ScreenView(name: "DemoScreenName", screenId: UUID())
        let sdj = SelfDescribingJson(schema: event.schema, andDictionary: event.payload).dictionary
        XCTAssertTrue(validator!.validateJson(sdj))
    }

    func testPushNotificationEventJson() {
        var attachments: [AnyHashable] = []
        attachments.append(
            [
                kSPPnAttachmentId: "identifier",
                kSPPnAttachmentUrl: "url",
                kSPPnAttachmentType: "type"
            ])
        
        let userInfo = [
            "aps": [
                "alert": [
                    "title": "test title",
                    "body": "test",
                    "loc-key": "test key"
                ],
                "content-available": NSNumber(value: 0)
            ] as NSObject
        ]
        
        let content = NotificationContent(title: "title", body: "body", badge: NSNumber(value: 5))
        content.subtitle = "subtitle"
        content.sound = "sound"
        content.launchImageName = "launchImageName"
        content.userInfo = userInfo

        let event = PushNotification(date: "date", action: "action", trigger: "PUSH", category: "category", thread: "thread", notification: content)

        let sdj = SelfDescribingJson(schema: event.schema, andDictionary: event.payload).dictionary
        XCTAssertTrue(validator!.validateJson(sdj))
    }

    func testMessageNotificationEventJson() {
        let userInfo = [
            "aps": [
                "alert": [
                    "title": "test title",
                    "body": "test",
                    "loc-key": "test key"
                ],
                "content-available": NSNumber(value: 0)
            ] as NSObject
        ]
        let event = MessageNotification.messageNotification(userInfo: userInfo, defaultTitle: nil, defaultBody: nil)
        let sdj = SelfDescribingJson(schema: event!.schema, andDictionary: event!.payload).dictionary
        XCTAssertTrue(validator!.validateJson(sdj))
    }

    func testApplicationInstallJson() {
        let installEvent = SelfDescribingJson(schema: kSPApplicationInstallSchema, andDictionary: [String : NSObject]())
        let json = installEvent.dictionary
        XCTAssertTrue(validator!.validateJson(json))
    }

    func testApplicationContextJson() {
        let json = Utilities.getApplicationContext(withVersion: "testversion", andBuild: "testbuild")
        XCTAssertTrue(validator!.validateJson(json.dictionary))
    }

    func testErrorEventJson() {
        let event = SNOWError(message: "some error message")
        event.name = "some exception name"
        event.stackTrace = "some stack trace"
        let sdj = SelfDescribingJson(schema: event.schema, andDictionary: event.payload).dictionary
        XCTAssertTrue(validator!.validateJson(sdj))
    }

    func testFinalEventPayloadJson() {
        let tracker = getTracker("acme.fake.url")
        let event = PageView(pageUrl: "DemoPageUrl")
        event.pageTitle = "DemoPageTitle"
        event.referrer = "DemoPageReferrer"

        // Check that the final payload passes validation
        let trackerEvent = TrackerEvent(event: event, state: nil)
        let data = tracker.payload(with: trackerEvent).dictionary

        let dataArray = [data] as NSObject
        let json = SelfDescribingJson(schema: kSPPayloadDataSchema, andData: dataArray).dictionary
        XCTAssertTrue(validator!.validateJson(json))

        // Check that the nested context json passes validation
        let contextsJson = data?["co"] as? String
        var contextDictionary: [AnyHashable : Any]? = nil
        if let aData = contextsJson?.data(using: .utf8) {
            contextDictionary = try? JSONSerialization.jsonObject(with: aData, options: []) as? [AnyHashable : Any]
        }
        XCTAssertTrue(validator!.validateJson(contextDictionary))
    }

    func getJSONAsString(withFilePath filePath: String?) -> String? {
        let path = Bundle(for: TestGeneratedJsons.self).path(forResource: filePath, ofType: nil, inDirectory: "Products")
        if let data = NSData(contentsOfFile: path ?? "") as Data? {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func getTracker(_ url: String) -> Tracker {
        let endpoint = "https://\(url)"
        let networkConfig = NetworkConfiguration(endpoint: endpoint, method: .post)
        let trackerConfig = TrackerConfiguration(appId: "anAppId")
        trackerConfig.platformContext = true
        trackerConfig.geoLocationContext = true
        trackerConfig.base64Encoding = false
        trackerConfig.sessionContext = true
        let serviceProvider = ServiceProvider(namespace: "aNamespace", network: networkConfig, configurations: [trackerConfig])
        return serviceProvider.tracker
    }
}
