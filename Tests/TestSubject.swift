//
//  TestSubject.swift
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

class TestSubject: XCTestCase {
    func testReturnsPlatformContextIfEnabled() {
        let subject = Subject(platformContext: true, andGeoContext: false)
        let platformDict = subject.getPlatformDict(withUserAnonymisation: false)
        XCTAssertNotNil(platformDict)
        XCTAssertNotNil(platformDict?.dictionary?[kSPPlatformOsType])
    }

    func testDoesntReturnPlatformContextIfDisabled() {
        let subject = Subject(platformContext: false, andGeoContext: false)
        let platformDict = subject.getPlatformDict(withUserAnonymisation: false)
        XCTAssertNil(platformDict)
    }

    func testReturnsGeolocationContextIfEnabled() {
        let subject = Subject(platformContext: false, andGeoContext: true)
        subject.geoLatitude = NSNumber(value: 10.0)
        subject.geoLongitude = NSNumber(value: 10.0)
        let geoLocationDict = subject.getGeoLocationDict()
        XCTAssertNotNil(geoLocationDict)
        XCTAssertNotNil(geoLocationDict)
    }

    func testDoesntReturnGeolocationContextIfDisabled() {
        let subject = Subject(platformContext: false, andGeoContext: false)
        subject.geoLatitude = NSNumber(value: 10.0)
        subject.geoLongitude = NSNumber(value: 10.0)
        let geoLocationDict = subject.getGeoLocationDict()
        XCTAssertNil(geoLocationDict)
    }

    func testAnonymisesUserIdentifiers() {
        let subject = Subject(platformContext: false, andGeoContext: false)
        subject.userId = "aUserId"
        subject.ipAddress = "127.0.0.1"
        subject.networkUserId = "aNuid"
        subject.domainUserId = "aDuid"
        subject.language = "EN"

        guard let values = subject.getStandardDict(withUserAnonymisation: true)?.dictionary else {
            return XCTFail()
        }
        XCTAssertNil(values[kSPUid])
        XCTAssertNil(values[kSPIpAddress])
        XCTAssertNil(values[kSPNetworkUid])
        XCTAssertNil(values[kSPDomainUid])
        XCTAssertEqual(values[kSPLanguage], "EN" as NSObject)
    }
}