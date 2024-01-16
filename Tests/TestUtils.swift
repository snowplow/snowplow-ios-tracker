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

class TestUtils: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetTimeZone() {
        XCTAssertEqual(
            Utilities.timezone,
            NSTimeZone.system.identifier)
    }
    
    func testGetLanguage() {
        XCTAssertNotNil(Utilities.language)
    }
    
    func testGetPlatform() {
#if os(iOS)
        XCTAssertEqual(Utilities.platform, .mobile)
#elseif os(visionOS)
        XCTAssertEqual(Utilities.platform, .headset)
#else
        XCTAssertEqual(Utilities.platform, .desktop)
#endif
    }
    
    func testGetResolution() {
        #if !os(visionOS)
        let actualResolution = Utilities.resolution
        XCTAssertTrue(actualResolution != nil)
        #endif
    }
    
    func testGetEventId() {
        let sample_uuid = Utilities.getUUIDString()
        
        // For regex pattern matching to verify if it's of UUID type 4
        let pattern = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}"
        let searchRange = NSRange(location: 0, length: sample_uuid.count)
        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
        }
        let matches = regex?.matches(in: sample_uuid, options: [], range: searchRange)
        
        XCTAssertEqual(
            (matches?.count ?? 0),
            Int(1),
            "UUID generated doesn't match the type 4 UUID RFC")
    }
    
    func testGetTimestamp() {
        let sample_rand = String(format: "%lld", Utilities.getTimestamp().int64Value)
        
        // For regex pattern matching to verify if it's of UUID type 4
        let pattern = "[0-9]+"
        let searchRange = NSRange(location: 0, length: sample_rand.count)
        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
        }
        let matches = regex?.matches(in: sample_rand, options: [], range: searchRange)
        
        XCTAssertEqual(
            (matches?.count ?? 0),
            Int(1),
            "Timestamp generated doesn't match the correct format 1234.567")
        
    }
    
    func testTimestampToISOString() {
        XCTAssertEqual(Utilities.timestamp(toISOString: 1654496481347), "2022-06-06T06:21:21.347Z")
        XCTAssertEqual(Utilities.timestamp(toISOString: 1654498990916), "2022-06-06T07:03:10.916Z")
    }
    
    func testAppId() {
        // This is always NULL in a test environment
        print("appId: \(Utilities.appId!)")
    }
    
    func testUrlEncodingString() {
        XCTAssertEqual(Utilities.urlEncode(""), "")
        XCTAssertEqual(Utilities.urlEncode("a"), "a")
        XCTAssertEqual(Utilities.urlEncode("a b"), "a%20b")
        XCTAssertEqual(Utilities.urlEncode("a=&"), "a%3D%26")
    }
    
    func testUrlEncodingDictionary() {
        XCTAssertEqual(Utilities.urlEncode([
            "a": "b" as NSObject
        ]), "a=b")
        
        let twoKeys = [
            "a": "b" as NSObject,
            "c": "d" as NSObject
        ]
        assertEqualUrlEncode(Utilities.urlEncode(twoKeys), "a=b&c=d")
        
        let intValues = [
            "a": NSNumber(value: -5),
            "c": NSNumber(value: 3)
        ]
        assertEqualUrlEncode(Utilities.urlEncode(intValues), "a=-5&c=3")
        
        let boolValues = [
            "a": NSNumber(value: false),
            "c": NSNumber(value: true)
        ]
        assertEqualUrlEncode(Utilities.urlEncode(boolValues), "a=0&c=1")
        
        let encodedValues = [
            "a": " " as NSObject,
            "c": "=" as NSObject
        ]
        assertEqualUrlEncode(Utilities.urlEncode(encodedValues), "a=%20&c=%3D")
    }
    
    func testEscapedQueryString() {
        let testValues = [
            "null_value_key" : NSNull(),
            "string_value_key" : "Not null" as NSObject,
            "characters_key" : "|!\" £$%&/()=?^ì§°ç*éùàò+{}◊∞Ç±¿≈ ⁄›‰¢’”»ıè¶#@][ˆ¡≠`´÷‹~~¥‘“«`" as NSObject
        ]
        let now = Utilities.urlEncode(testValues)
        let then = "string_value_key=Not%20null&characters_key=%7C%21%22%20%C2%A3%24%25%26%2F%28%29%3D%3F%5E%C3%AC%C2%A7%C2%B0%C3%A7%2A%C3%A9%C3%B9%C3%A0%C3%B2%2B%7B%7D%E2%97%8A%E2%88%9E%C3%87%C2%B1%C2%BF%E2%89%88%20%EF%A3%BF%E2%81%84%E2%80%BA%E2%80%B0%C2%A2%E2%80%99%E2%80%9D%C2%BB%C4%B1%C3%A8%C2%B6%23%40%5D%5B%CB%86%C2%A1%E2%89%A0%60%C2%B4%C3%B7%E2%80%B9~~%C2%A5%E2%80%98%E2%80%9C%C2%AB%60&null_value_key=%3Cnull%3E"
        assertEqualUrlEncode(now, then)
        let urlString = "\("http://www.snowplow.com")?\(now)"
        let url = URL(string: urlString)
        XCTAssertNotNil(url)
    }
    
    
    func testDictionaryNullRemover() {
        let dict = [
            "a_null_value" : NSNull(),
            "a_string_value" : "Not null!" as NSObject
        ]
        XCTAssertEqual(dict.count, 2)
        let result = Utilities.removeNullValuesFromDict(withDict: dict)
        XCTAssertEqual(result.count, 1)
    }
    
    func testTruncateUrlSchemeDoesntChangeValidUrl() {
        let url = "https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/snowplow-tracker-protocol/#snowplow-events"
        XCTAssertEqual(url, Utilities.truncateUrlScheme(url))
    }
    
    func testTruncateUrlSchemeDoesntChangeInvalidUrl() {
        let url = "this is not a valid URL"
        XCTAssertEqual(url, Utilities.truncateUrlScheme(url))
    }
    
    func testTruncateUrlSchemeTruncatesLongUrlScheme() {
        let url = "12345678901234567890://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/snowplow-tracker-protocol/#snowplow-events"
        let expected = "1234567890123456://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/snowplow-tracker-protocol/#snowplow-events"
        
        XCTAssertEqual(expected, Utilities.truncateUrlScheme(url))
    }
    
    private func assertEqualUrlEncode(_ now: String, _ then: String) {
        XCTAssertEqual(
            Set<String>(now.split(separator: "&").map { String($0) }),
            Set<String>(then.split(separator: "&").map { String($0) })
        )
    }
}
