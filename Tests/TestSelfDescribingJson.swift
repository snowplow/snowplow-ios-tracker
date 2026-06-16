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
    
    // MARK: - Encodable Serialization Tests
    
    func testInitWithEncodableAndCustomEncoder() {
        struct Product: Encodable {
            var name: String
            var price: Double
            var createdAt: Date
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let product = Product(
            name: "Test Product",
            price: 29.99,
            createdAt: Date(timeIntervalSince1970: 1640995200) // 2022-01-01T00:00:00Z
        )
        
        let json = try? SelfDescribingJson(
            schema: "iglu:acme.com/product/jsonschema/1-0-0",
            encoder: encoder,
            andEncodable: product
        )
        
        XCTAssertNotNil(json)
        XCTAssertEqual(json?.schema, "iglu:acme.com/product/jsonschema/1-0-0")
        XCTAssertEqual(json?.data["name"] as? String, "Test Product")
        XCTAssertEqual(json?.data["price"] as? Double, 29.99)
        XCTAssertEqual(json?.data["createdAt"] as? String, "2022-01-01T00:00:00Z")
    }
    
    func testInitWithEncodableArrayThrowsError() {
        struct SimpleArray: Encodable {
            var items: [String]
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                for item in items {
                    try container.encode(item)
                }
            }
        }
        
        let arrayData = SimpleArray(items: ["item1", "item2", "item3"])
        
        XCTAssertThrowsError(
            try SelfDescribingJson(
                schema: "iglu:acme.com/array_test/jsonschema/1-0-0",
                andEncodable: arrayData
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
    
    func testInitWithEncodablePrimitiveThrowsError() {
        struct PrimitiveWrapper: Encodable {
            var value: String
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(value)
            }
        }
        
        let primitiveData = PrimitiveWrapper(value: "just a string")
        
        XCTAssertThrowsError(
            try SelfDescribingJson(
                schema: "iglu:acme.com/primitive_test/jsonschema/1-0-0",
                andEncodable: primitiveData
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
    
    func testInitWithUncodableDataThrowsEncodingError() {
        struct BadEncodable: Encodable {
            let invalidData: Any = { print("This is a closure that cannot be encoded") }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                // This will throw because closures cannot be encoded
                try container.encode(String(describing: invalidData), forKey: .invalidData)
                throw EncodingError.invalidValue(
                    invalidData,
                    EncodingError.Context(
                        codingPath: [],
                        debugDescription: "Cannot encode closure"
                    )
                )
            }
            
            enum CodingKeys: String, CodingKey {
                case invalidData
            }
        }
        
        let badData = BadEncodable()
        
        XCTAssertThrowsError(
            try SelfDescribingJson(
                schema: "iglu:acme.com/bad_data/jsonschema/1-0-0",
                andEncodable: badData
            )
        ) { error in
            XCTAssertTrue(error is EncodingError)
        }
    }
    
    func testInitWithEncodableOptionalFields() {
        struct UserProfile: Encodable {
            var id: Int
            var username: String
            var email: String?
            var fullName: String?
            var avatarURL: String?
            var preferences: [String: String]?
        }
        
        let profile = UserProfile(
            id: 456,
            username: "testuser",
            email: nil, // This should be omitted from JSON
            fullName: "Test User",
            avatarURL: nil, // This should be omitted from JSON
            preferences: ["theme": "dark", "language": "en"]
        )
        
        let json = try? SelfDescribingJson(
            schema: "iglu:acme.com/user_profile/jsonschema/1-0-0",
            andEncodable: profile
        )
        
        XCTAssertNotNil(json)
        XCTAssertEqual(json?.data["id"] as? Int, 456)
        XCTAssertEqual(json?.data["username"] as? String, "testuser")
        XCTAssertEqual(json?.data["fullName"] as? String, "Test User")
        
        // Optional nil fields should not be present in the dictionary
        XCTAssertFalse(json?.data.keys.contains("email") ?? true)
        XCTAssertFalse(json?.data.keys.contains("avatarURL") ?? true)
    }
}
