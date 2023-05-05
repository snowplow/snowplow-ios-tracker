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

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"

class LegacyTestSubject: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSubjectInit() {
        let subject = Subject()
        XCTAssertNotNil(subject.standardDict(userAnonymisation: false))
    }

    func testSubjectInitWithOptions() {
        let subject = Subject(platformContext: true, geoLocationContext: false)
        XCTAssertNotNil(subject.platformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil))
        XCTAssertNotNil(subject.standardDict(userAnonymisation: false))
    }

    func testSubjectSetterFunctions() {
        let subject = Subject(platformContext: false, geoLocationContext: true)
        subject.userId = "aUserId"
        subject.screenResolution = SPSize(width: 1920, height: 1080)
        subject.screenViewPort = SPSize(width: 1080, height: 1920)
        subject.colorDepth = NSNumber(value: 20)
        subject.timezone = "UTC"
        subject.language = "EN"
        subject.ipAddress = "127.0.0.1"
        subject.useragent = "aUseragent"
        subject.networkUserId = "aNuid"
        subject.domainUserId = "aDuid"

        let values = subject.standardDict(userAnonymisation: false)

        XCTAssertEqual(values[kSPUid], "aUserId")
        XCTAssertTrue((values[kSPResolution] == "1920x1080"))
        XCTAssertTrue((values[kSPViewPort] == "1080x1920"))
        XCTAssertTrue((values[kSPColorDepth] == "20"))
        XCTAssertEqual(values[kSPTimezone], "UTC")
        XCTAssertEqual(values[kSPLanguage], "EN")
        XCTAssertEqual(values[kSPIpAddress], "127.0.0.1")
        XCTAssertEqual(values[kSPUseragent], "aUseragent")
        XCTAssertEqual(values[kSPNetworkUid], "aNuid")
        XCTAssertEqual(values[kSPDomainUid], "aDuid")

        // Setup GeoLocation
        subject.geoLongitude = NSNumber(value: 5)
        subject.geoLatitude = NSNumber(value: 89.2)
        subject.geoTimestamp = NSNumber(value: 5)
        subject.geoLatitudeLongitudeAccuracy = NSNumber(value: 5.5)
        subject.geoSpeed = NSNumber(value: 6.2)
        subject.geoBearing = NSNumber(value: 82.3)
        subject.geoAltitude = NSNumber(value: 62.3)
        subject.geoAltitudeAccuracy = NSNumber(value: 16.3)

        let geoValues = subject.geoLocationDict!

        XCTAssertTrue((NSNumber(value: 5) == geoValues[kSPGeoLongitude]))
        XCTAssertTrue((NSNumber(value: 89.2) == geoValues[kSPGeoLatitude]))
        XCTAssertTrue((NSNumber(value: 5.5) == geoValues[kSPGeoLatLongAccuracy]))
        XCTAssertTrue((NSNumber(value: 6.2) == geoValues[kSPGeoSpeed]))
        XCTAssertTrue((NSNumber(value: 82.3) == geoValues[kSPGeoBearing]))
        XCTAssertTrue((NSNumber(value: 62.3) == geoValues[kSPGeoAltitude]))
        XCTAssertTrue((NSNumber(value: 16.3) == geoValues[kSPGeoAltitudeAccuracy]))
        XCTAssertTrue((NSNumber(value: 5) == geoValues[kSPGeoTimestamp]))
    }

    func testGeoLocationGetWithoutNeededKeys() {
        let subject = Subject(platformContext: false, geoLocationContext: true)
        XCTAssertNil(subject.geoLocationDict)

        subject.geoLongitude = NSNumber(value: 5)
        subject.geoLatitude = NSNumber(value: 89.2)

        XCTAssertNotNil(subject.geoLocationDict)
    }

    func testGeoLocationWithSubjectConfiguration() {
        let config = SubjectConfiguration()
        config.geoLatitude = NSNumber(value: 12.12)
        config.geoLongitude = NSNumber(value: 24.24)
        let subject = Subject(platformContext: false, geoLocationContext: true, subjectConfiguration: config)

        let values = subject.geoLocationDict

        XCTAssertEqual(NSNumber(value: 12.12), values?[kSPGeoLatitude])
        XCTAssertEqual(NSNumber(value: 24.24), values?[kSPGeoLongitude])
        XCTAssertNil(values?[kSPGeoAltitude])
    }
}
//#pragma clang diagnostic pop
