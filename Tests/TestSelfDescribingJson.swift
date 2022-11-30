//
//  TestSelfDescribingJson.swift
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
//  Authors: Jonathan Almeida
//  License: Apache License Version 2.0
//

import XCTest
@testable import SnowplowTracker

class TestSelfDescribingJson: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitWithObject() {
        let expected = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0" as NSObject,
            "data": [
                "hello": "world"
            ] as NSObject
        ]
        let data = [
            "hello": "world" as NSObject
        ]
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: data)
        XCTAssertEqual(expected, sdj.dictionary)
    }

    func testInitWithSPPayload() {
        let expected = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0" as NSObject,
            "data": [
                "hello": "world"
            ] as NSObject
        ]
        let data = Payload()
        data.addValueToPayload("world", forKey: "hello")
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andPayload: data)
        XCTAssertEqual(expected, sdj.dictionary)
    }

    func testInitWithSPSelfDescribingJson() {
        let expected = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0" as NSObject,
            "data": [
                "schema": "iglu:acme.com/nested_event/jsonschema/1-0-0",
                "data": [
                    "hello": "world"
                ]
            ] as NSObject
        ]
        let nestedData = [
            "hello": "world"
        ]
        let data = SelfDescribingJson(
            schema: "iglu:acme.com/nested_event/jsonschema/1-0-0",
            andDictionary: nestedData)
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andSelfDescribingJson: data)
        XCTAssertEqual(expected, sdj.dictionary)
    }

    func testUpdateSchema() {
        let expected = [
            "schema": "iglu:acme.com/test_event_2/jsonschema/1-0-0" as NSObject,
            "data": [
                "hello": "world"
            ] as NSObject
        ]
        let data = [
            "hello": "world"
        ]
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: data)
        sdj.schema = "iglu:acme.com/test_event_2/jsonschema/1-0-0"
        XCTAssertEqual(expected, sdj.dictionary)
    }
    
    func testUpdateDataWithObject() {
        let expected = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0" as NSObject,
            "data": [
                "world": "hello"
            ] as NSObject
        ]
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: [
                "hello": "world"
            ])
        sdj.setData(withObject: [
            "world": "hello"
        ] as NSObject)
        XCTAssertEqual(expected, sdj.dictionary)
    }
    
    func testUpdateDataWithSPPayload() {
        let expected = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0" as NSObject,
            "data": [
                "world": "hello"
            ] as NSObject
        ]
        let data = Payload()
        data.addValueToPayload("hello", forKey: "world")
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: [
                "hello": "world"
            ])
        sdj.setData(withPayload: data)
        XCTAssertEqual(expected, sdj.dictionary)
    }

    func testUpdateDataWithSPSelfDescribingJson() {
        let expected = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0" as NSObject,
            "data": [
                "schema": "iglu:acme.com/nested_event/jsonschema/1-0-0",
                "data": [
                    "hello": "world"
                ]
            ] as NSObject
        ]
        let nestedData = [
            "hello": "world"
        ]
        let data = SelfDescribingJson(
            schema: "iglu:acme.com/nested_event/jsonschema/1-0-0",
            andDictionary: nestedData)
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: [
                "hello": "world"
            ])
        sdj.setData(withSelfDescribingJson: data)
        XCTAssertEqual(expected, sdj.dictionary)
    }
}

