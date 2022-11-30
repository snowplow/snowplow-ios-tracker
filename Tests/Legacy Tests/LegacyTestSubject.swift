//
//  TestLifecycleState.swift
//  Snowplow-iOSTests
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
//  Authors: Michael Hadam
//  License: Apache License Version 2.0
//

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
        XCTAssertNotNil(subject.getStandardDict(withUserAnonymisation: false))
    }

    func testSubjectInitWithOptions() {
        let subject = Subject(platformContext: true, andGeoContext: false)
        XCTAssertNotNil(subject.getPlatformDict(withUserAnonymisation: false))
        XCTAssertNotNil(subject.getStandardDict(withUserAnonymisation: false))
    }

    func testSubjectSetterFunctions() {
        let subject = Subject(platformContext: false, andGeoContext: true)
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

        guard var values = subject.getStandardDict(withUserAnonymisation: false)?.dictionary else {
            return XCTFail()
        }

        XCTAssertEqual(values[kSPUid], "aUserId" as NSObject)
        XCTAssertTrue((values[kSPResolution] == "1920x1080" as NSObject))
        XCTAssertTrue((values[kSPViewPort] == "1080x1920" as NSObject))
        XCTAssertTrue((values[kSPColorDepth] == "20" as NSObject))
        XCTAssertEqual(values[kSPTimezone], "UTC" as NSObject)
        XCTAssertEqual(values[kSPLanguage], "EN" as NSObject)
        XCTAssertEqual(values[kSPIpAddress], "127.0.0.1" as NSObject)
        XCTAssertEqual(values[kSPUseragent], "aUseragent" as NSObject)
        XCTAssertEqual(values[kSPNetworkUid], "aNuid" as NSObject)
        XCTAssertEqual(values[kSPDomainUid], "aDuid" as NSObject)

        // Setup GeoLocation
        subject.geoLongitude = NSNumber(value: 5)
        subject.geoLatitude = NSNumber(value: 89.2)
        subject.geoTimestamp = NSNumber(value: 5)
        subject.geoLatitudeLongitudeAccuracy = NSNumber(value: 5.5)
        subject.geoSpeed = NSNumber(value: 6.2)
        subject.geoBearing = NSNumber(value: 82.3)
        subject.geoAltitude = NSNumber(value: 62.3)
        subject.geoAltitudeAccuracy = NSNumber(value: 16.3)

        values = subject.getGeoLocationDict()!

        XCTAssertTrue((NSNumber(value: 5) == values[kSPGeoLongitude]))
        XCTAssertTrue((NSNumber(value: 89.2) == values[kSPGeoLatitude]))
        XCTAssertTrue((NSNumber(value: 5.5) == values[kSPGeoLatLongAccuracy]))
        XCTAssertTrue((NSNumber(value: 6.2) == values[kSPGeoSpeed]))
        XCTAssertTrue((NSNumber(value: 82.3) == values[kSPGeoBearing]))
        XCTAssertTrue((NSNumber(value: 62.3) == values[kSPGeoAltitude]))
        XCTAssertTrue((NSNumber(value: 16.3) == values[kSPGeoAltitudeAccuracy]))
        XCTAssertTrue((NSNumber(value: 5) == values[kSPGeoTimestamp]))
    }

    func testGeoLocationGetWithoutNeededKeys() {
        let subject = Subject(platformContext: false, andGeoContext: true)
        XCTAssertNil(subject.getGeoLocationDict())

        subject.geoLongitude = NSNumber(value: 5)
        subject.geoLatitude = NSNumber(value: 89.2)

        XCTAssertNotNil(subject.getGeoLocationDict())
    }

    func testGeoLocationWithSubjectConfiguration() {
        let config = SubjectConfiguration()
        config.geoLatitude = NSNumber(value: 12.12)
        config.geoLongitude = NSNumber(value: 24.24)
        let subject = Subject(platformContext: false, geoLocationContext: true, subjectConfiguration: config)

        let values = subject.getGeoLocationDict()

        XCTAssertEqual(NSNumber(value: 12.12), values?[kSPGeoLatitude])
        XCTAssertEqual(NSNumber(value: 24.24), values?[kSPGeoLongitude])
        XCTAssertNil(values?[kSPGeoAltitude])
    }
}
//#pragma clang diagnostic pop
