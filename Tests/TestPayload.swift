//
//  TestPayload.swift
//  SnowplowTests
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
//  Authors: Jonathan Almeida
//  License: Apache License Version 2.0
//

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

        XCTAssertEqual(
            sample_payload.dictionary,
            [String : NSObject]())

    }

    func testInitWithNSDictionary() {
        let sample_dict: [String : NSObject] = [
            "Key1": "Value1" as NSObject,
            "Key2": "Value2" as NSObject
        ]
        let sample_payload = Payload(dictionary: sample_dict)

        XCTAssertEqual(
            sample_payload.dictionary,
            sample_dict)
        XCTAssertTrue(sample_payload.description.contains("\"Key1\": Value1"))
        XCTAssertTrue(sample_payload.description.contains("\"Key2\": Value2"))
    }

    func testInitWithWrongDictionary() {
        let sample_dict: [String : NSObject] = [
            "Key1": "Value1" as NSObject,
            "Key2": "Value2" as NSObject
        ]
        let sample_dict2: [String : NSObject] = [
            "Key2": "Value1" as NSObject,
            "Key1": "Value2" as NSObject
        ]
        let sample_payload = Payload(dictionary: sample_dict)

        XCTAssertNotEqual(
            sample_payload.dictionary,
            sample_dict2,
            "Payload is not initialized with the correct JSON or NSDictionary")
    }

    func testAddValueToPayload() {
        let sample_dict: [String : NSObject] = [
            "Key1": "Value1" as NSObject
        ]
        let sample_payload = Payload()
        sample_payload.addValueToPayload("Value1", forKey: "Key1")


        XCTAssertEqual(
            sample_payload.dictionary,
            sample_dict)
    }

    func testAddValueToPayload2() {
        let sample_dict: [String : NSObject] = [
            "Key2": "Value2" as NSObject
        ]
        let sample_payload = Payload()
        sample_payload.addValueToPayload("Value1", forKey: "Key1")


        XCTAssertNotEqual(
            sample_payload.dictionary,
            sample_dict,
            "Payload should not be the same as sample_dict")
    }

    func testAddValueToPayload3() {
        let sample_dict_init: [String : NSObject] = [
            "Key1": "Value1" as NSObject
        ]
        let sample_dict_final: [String : NSObject] = [
            "Key1": "Value1" as NSObject,
            "Key2": "Value2" as NSObject
        ]
        let sample_payload = Payload(dictionary: sample_dict_init)
        sample_payload.addValueToPayload("Value2", forKey: "Key2")

        XCTAssertEqual(
            sample_payload.dictionary,
            sample_dict_final)
    }

    func testAddNilValueToPayload() {
        let payload = Payload()
        payload.addValueToPayload(nil, forKey: "foo")
        XCTAssertEqual(payload.dictionary, [String : NSObject]())
    }

    func testAddNilValueToPayloadUnsetsKey() {
        let payload = Payload(dictionary: [
            "foo": "bar" as NSObject
        ])
        payload.addValueToPayload(nil, forKey: "foo")
        XCTAssertEqual(payload.dictionary, [String : NSObject]())
    }

    func testAddNumericValueToPayload() {
        let sample_dict = [
            "Key1": NSNumber(value: 100)
        ]
        let sample_payload = Payload()
        sample_payload.addNumericValueToPayload(NSNumber(value: 100), forKey: "Key1")


        XCTAssertEqual(
            sample_payload.dictionary,
            sample_dict)
    }

    func testAddNilNumericValueToPayload() {
        let sample_payload = Payload()
        sample_payload.addNumericValueToPayload(nil, forKey: "Key1")


        XCTAssertEqual(
            sample_payload.dictionary,
            [String : NSObject]())
    }

    func testAddNilNumericValueToPayloadUnsetsKey() {
        let sample_payload = Payload(dictionary: [
            "Key1": NSNumber(value: 100)
        ])
        sample_payload.addNumericValueToPayload(nil, forKey: "Key1")


        XCTAssertEqual(
            sample_payload.dictionary,
            [String : NSObject]())
    }

    func testAddDictToPayload() {
        let sample_dic = [
            "Key1": "Value1" as NSObject
        ]
        let sample_payload = Payload()
        sample_payload.addDictionaryToPayload(sample_dic)

        XCTAssertEqual(
            sample_payload.dictionary,
            sample_dic)
    }

    func testAddDictToPayload2() {
        let sample_dic = [
            "Key1": "Value1" as NSObject
        ]
        let sample_dic2 = [
            "Key2": "Value2" as NSObject
        ]
        let sample_dict_final = [
            "Key1": "Value1" as NSObject,
            "Key2": "Value2" as NSObject
        ]
        let sample_payload = Payload(dictionary: sample_dic)
        sample_payload.addDictionaryToPayload(sample_dic2)

        XCTAssertEqual(
            sample_payload.dictionary,
            sample_dict_final)
    }

    func testAddDictToPayload3() {
        let sample_dic = [
            "Key1": "Value1" as NSObject
        ]
        let sample_dic2 = [
            "Key2": NSNumber(value: 2)
        ]
        let sample_dict_final = [
            "Key1": "Value1" as NSObject
        ]

        let sample_payload = Payload(dictionary: sample_dic)
        sample_payload.addDictionaryToPayload(sample_dic2)

        XCTAssertEqual(
            sample_payload.dictionary,
            sample_dict_final)
    }

    func testJsonToPayload() {
        // {"Key1":"Value1"} -> eyJLZXkxIjoiVmFsdWUxIn0=

        let sample_dic = [
            "Key1": "Value1"
        ]
        let sample_enc = [
            "type_enc": "eyJLZXkxIjoiVmFsdWUxIn0" as NSObject
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
            sample_payload.dictionary,
            sample_enc)
    }

    func testJsonToPayload2() {
        // {"Key1":"Value1"} -> eyJLZXkxIjoiVmFsdWUxIn0=

        let sample_dic = [
            "Key1": "Value1"
        ]
        let sample_enc = [
            "type_notenc": "{\"Key1\":\"Value1\"}" as NSObject
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
            sample_payload.dictionary,
            sample_enc)
    }

    func testJsonStringToPayload() {
        // {"Key1":"Value1"} -> eyJLZXkxIjoiVmFsdWUxIn0=

        let sample_enc = [
            "type_notenc": "{\"Key1\":\"Value1\"}" as NSObject
        ]
        let json_str = "{\"Key1\":\"Value1\"}"

        let sample_payload = Payload()
        sample_payload.addJsonStringToPayload(
            json_str,
            base64Encoded: false,
            typeWhenEncoded: "type_enc",
            typeWhenNotEncoded: "type_notenc")

        XCTAssertEqual(
            sample_payload.dictionary,
            sample_enc)
    }

    func testJsonStringToPayload2() {
        // {"Key1":"Value1"} -> eyJLZXkxIjoiVmFsdWUxIn0=

        let sample_enc = [
            "type_enc": "eyJLZXkxIjoiVmFsdWUxIn0" as NSObject
        ]
        let json_str = "{\"Key1\":\"Value1\"}"

        let sample_payload = Payload()
        sample_payload.addJsonStringToPayload(
            json_str,
            base64Encoded: true,
            typeWhenEncoded: "type_enc",
            typeWhenNotEncoded: "type_notenc")

        XCTAssertEqual(
            sample_payload.dictionary,
            sample_enc)
    }

    func testgetPayloadAsDictionary() {
        let sample_payload = Payload()

        XCTAssertEqual(
            sample_payload.dictionary,
            [String : NSObject]())
    }

    func testgetPayloadAsDictionary2() {
        let sample_dict = [
            "Key1": "Value1" as NSObject
        ]
        let sample_payload = Payload(dictionary: [
            "Key1": "Value1" as NSObject
        ])

        XCTAssertEqual(
            sample_payload.dictionary,
            sample_dict)
    }
}
