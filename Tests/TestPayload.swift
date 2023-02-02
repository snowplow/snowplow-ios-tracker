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

class TestPayload: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let sample_payload = Payload()

        XCTAssertTrue(sample_payload.dictionary.isEmpty)

    }

    func testInitWithNSDictionary() {
        let sample_dict = [
            "Key1": "Value1",
            "Key2": "Value2"
        ]
        let sample_payload = Payload(dictionary: sample_dict)

        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_dict)
        XCTAssertTrue(sample_payload.description.contains("\"Key1\": \"Value1\""))
        XCTAssertTrue(sample_payload.description.contains("\"Key2\": \"Value2\""))
    }

    func testInitWithWrongDictionary() {
        let sample_dict = [
            "Key1": "Value1",
            "Key2": "Value2"
        ]
        let sample_dict2 = [
            "Key2": "Value1",
            "Key1": "Value2"
        ]
        let sample_payload = Payload(dictionary: sample_dict)

        XCTAssertNotEqual(
            sample_payload.dictionary as! [String : String],
            sample_dict2,
            "Payload is not initialized with the correct JSON or NSDictionary")
    }

    func testAddValueToPayload() {
        let sample_dict = [
            "Key1": "Value1"
        ]
        let sample_payload = Payload()
        sample_payload.addValueToPayload("Value1", forKey: "Key1")


        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_dict)
    }

    func testAddValueToPayload2() {
        let sample_dict = [
            "Key2": "Value2"
        ]
        let sample_payload = Payload()
        sample_payload.addValueToPayload("Value1", forKey: "Key1")


        XCTAssertNotEqual(
            sample_payload.dictionary as! [String : String],
            sample_dict,
            "Payload should not be the same as sample_dict")
    }

    func testAddValueToPayload3() {
        let sample_dict_init = [
            "Key1": "Value1"
        ]
        let sample_dict_final = [
            "Key1": "Value1",
            "Key2": "Value2"
        ]
        let sample_payload = Payload(dictionary: sample_dict_init)
        sample_payload.addValueToPayload("Value2", forKey: "Key2")

        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_dict_final)
    }

    func testAddNilValueToPayload() {
        let payload = Payload()
        payload.addValueToPayload(nil, forKey: "foo")
        XCTAssertTrue(payload.dictionary.isEmpty)
    }

    func testAddNilValueToPayloadUnsetsKey() {
        let payload = Payload(dictionary: [
            "foo": "bar"
        ])
        payload.addValueToPayload(nil, forKey: "foo")
        XCTAssertTrue(payload.dictionary.isEmpty)
    }

    func testAddNumericValueToPayload() {
        let sample_dict = [
            "Key1": 100
        ]
        let sample_payload = Payload()
        sample_payload.addValueToPayload(100, forKey: "Key1")


        XCTAssertEqual(
            sample_payload.dictionary as! [String : AnyHashable],
            sample_dict)
    }

    func testAddDictToPayload() {
        let sample_dic = [
            "Key1": "Value1"
        ]
        let sample_payload = Payload()
        sample_payload.addDictionaryToPayload(sample_dic)

        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_dic)
    }

    func testAddDictToPayload2() {
        let sample_dic = [
            "Key1": "Value1"
        ]
        let sample_dic2 = [
            "Key2": "Value2"
        ]
        let sample_dict_final = [
            "Key1": "Value1",
            "Key2": "Value2"
        ]
        let sample_payload = Payload(dictionary: sample_dic)
        sample_payload.addDictionaryToPayload(sample_dic2)

        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_dict_final)
    }

    func testAddDictToPayload3() {
        let sample_dic = [
            "Key1": "Value1"
        ]
        let sample_dic2 = [
            "Key2": 2
        ]
        let sample_dict_final = [
            "Key1": "Value1"
        ]

        let sample_payload = Payload(dictionary: sample_dic)
        sample_payload.addDictionaryToPayload(sample_dic2)

        XCTAssertEqual(
            sample_payload.dictionary as! [String : AnyHashable],
            sample_dict_final)
    }

    func testJsonToPayload() {
        // {"Key1":"Value1"} -> eyJLZXkxIjoiVmFsdWUxIn0=

        let sample_dic = [
            "Key1": "Value1"
        ]
        let sample_enc = [
            "type_enc": "eyJLZXkxIjoiVmFsdWUxIn0"
        ]

        // NSDictionary conversion to JSON string
        let somedata = try? JSONSerialization.data(withJSONObject: sample_dic, options: [])

        let sample_payload = Payload()
        sample_payload.addJsonToPayload(
            somedata!,
            base64Encoded: true,
            typeWhenEncoded: "type_enc",
            typeWhenNotEncoded: "type_notenc")

        XCTAssertEqual(
            sample_payload.dictionary as? [String : String],
            sample_enc)
    }

    func testJsonToPayload2() {
        // {"Key1":"Value1"} -> eyJLZXkxIjoiVmFsdWUxIn0=

        let sample_dic = [
            "Key1": "Value1"
        ]
        let sample_enc = [
            "type_notenc": "{\"Key1\":\"Value1\"}"
        ]

        // NSDictionary conversion to JSON string
        let somedata = try! JSONSerialization.data(withJSONObject: sample_dic, options: [])

        let sample_payload = Payload()
        sample_payload.addJsonToPayload(
            somedata,
            base64Encoded: false,
            typeWhenEncoded: "type_enc",
            typeWhenNotEncoded: "type_notenc")

        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_enc)
    }

    func testJsonStringToPayload() {
        // {"Key1":"Value1"} -> eyJLZXkxIjoiVmFsdWUxIn0=

        let sample_enc = [
            "type_notenc": "{\"Key1\":\"Value1\"}"
        ]
        let json_str = "{\"Key1\":\"Value1\"}"

        let sample_payload = Payload()
        sample_payload.addJsonStringToPayload(
            json_str,
            base64Encoded: false,
            typeWhenEncoded: "type_enc",
            typeWhenNotEncoded: "type_notenc")

        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_enc)
    }

    func testJsonStringToPayload2() {
        // {"Key1":"Value1"} -> eyJLZXkxIjoiVmFsdWUxIn0=

        let sample_enc = [
            "type_enc": "eyJLZXkxIjoiVmFsdWUxIn0"
        ]
        let json_str = "{\"Key1\":\"Value1\"}"

        let sample_payload = Payload()
        sample_payload.addJsonStringToPayload(
            json_str,
            base64Encoded: true,
            typeWhenEncoded: "type_enc",
            typeWhenNotEncoded: "type_notenc")

        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_enc)
    }

    func testgetPayloadAsDictionary() {
        let sample_payload = Payload()

        XCTAssertTrue(sample_payload.dictionary.isEmpty)
    }

    func testgetPayloadAsDictionary2() {
        let sample_dict = [
            "Key1": "Value1"
        ]
        let sample_payload = Payload(dictionary: [
            "Key1": "Value1"
        ])

        XCTAssertEqual(
            sample_payload.dictionary as! [String : String],
            sample_dict)
    }
}
