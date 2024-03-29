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

class TestSelfDescribingJson: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitWithObject() {
        let expected: [String : Any] = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0",
            "data": [
                "hello": "world"
            ]
        ]
        let data = [
            "hello": "world"
        ]
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: data)
        XCTAssertEqual(NSDictionary(dictionary: expected),
                       NSDictionary(dictionary: sdj.dictionary))
    }

    func testInitWithSPPayload() {
        let expected: [String : Any] = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0",
            "data": [
                "hello": "world"
            ]
        ]
        let data = Payload()
        data.addValueToPayload("world", forKey: "hello")
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andPayload: data)
        XCTAssertEqual(NSDictionary(dictionary: expected),
                       NSDictionary(dictionary: sdj.dictionary))
    }

    func testInitWithSPSelfDescribingJson() {
        let expected: [String : Any] = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0",
            "data": [
                "schema": "iglu:acme.com/nested_event/jsonschema/1-0-0",
                "data": [
                    "hello": "world"
                ]
            ]
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
        XCTAssertEqual(NSDictionary(dictionary: expected),
                       NSDictionary(dictionary: sdj.dictionary))
    }
    
    func testInitWithEncodable() {
        struct EncodableUserData: Encodable {
            var firstName: String
            var lastName: String
            var nickname: String?
            var age: Decimal
            var children: [EncodableUserData]?
        }
        
        let user = EncodableUserData(
            firstName: "John",
            lastName: "Doe",
            age: 32.5,
            children: [
                EncodableUserData(firstName: "Emily", lastName: "Doe", age: 1.2)
            ]
        )
        
        let json = try? SelfDescribingJson(schema: "iglu:acme.com/user/jsonschema/1-0-0", andEncodable: user)
        XCTAssertNotNil(json)
        XCTAssertEqual(json?.data["firstName"] as? String, "John")
        XCTAssertEqual(json?.data["lastName"] as? String, "Doe")
        XCTAssertFalse(json?.data.keys.contains("nickname") ?? false)
        XCTAssertNotNil(json?.data["children"])
        XCTAssertEqual((json?.data["children"] as? Array<Any>)?.count, 1)
        XCTAssertEqual(json?.data["age"] as? Double, 32.5)
        let children = json?.data["children"] as? Array<Dictionary<String, Any>>
        XCTAssertEqual(children?.count, 1)
        XCTAssertEqual(children?[0]["firstName"] as? String, "Emily")
        XCTAssertEqual(children?[0]["lastName"] as? String, "Doe")
        XCTAssertEqual(children?[0]["age"] as? Double, 1.2)
    }
    
    func testUpdateSchema() {
        let expected: [String : Any] = [
            "schema": "iglu:acme.com/test_event_2/jsonschema/1-0-0",
            "data": [
                "hello": "world"
            ]
        ]
        let data = [
            "hello": "world"
        ]
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: data)
        sdj.schema = "iglu:acme.com/test_event_2/jsonschema/1-0-0"
        XCTAssertEqual(NSDictionary(dictionary: expected),
                       NSDictionary(dictionary: sdj.dictionary))
    }

    func testUpdateDataWithObject() {
        let expected: [String : Any] = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0",
            "data": [
                "world": "hello"
            ]
        ]
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: [
                "hello": "world"
            ])
        sdj.data = [
            "world": "hello"
        ]
        XCTAssertEqual(NSDictionary(dictionary: expected),
                       NSDictionary(dictionary: sdj.dictionary))
    }

    func testUpdateDataWithSPPayload() {
        let expected: [String : Any] = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0",
            "data": [
                "world": "hello"
            ]
        ]
        let data = Payload()
        data.addValueToPayload("hello", forKey: "world")
        let sdj = SelfDescribingJson(
            schema: "iglu:acme.com/test_event/jsonschema/1-0-0",
            andDictionary: [
                "hello": "world"
            ])
        sdj.setData(withPayload: data)
        XCTAssertEqual(NSDictionary(dictionary: expected),
                       NSDictionary(dictionary: sdj.dictionary))
    }

    func testUpdateDataWithSPSelfDescribingJson() {
        let expected: [String : Any] = [
            "schema": "iglu:acme.com/test_event/jsonschema/1-0-0",
            "data": [
                "schema": "iglu:acme.com/nested_event/jsonschema/1-0-0",
                "data": [
                    "hello": "world"
                ]
            ]
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
        XCTAssertEqual(NSDictionary(dictionary: expected),
                       NSDictionary(dictionary: sdj.dictionary))
    }
}
