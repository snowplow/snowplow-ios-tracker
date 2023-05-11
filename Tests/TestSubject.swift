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

class TestSubject: XCTestCase {
    func testReturnsPlatformContextIfEnabled() {
        let subject = Subject(platformContext: true, geoLocationContext: false)
        let platformDict = subject.platformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertNotNil(platformDict)
        XCTAssertNotNil(platformDict?.dictionary[kSPPlatformOsType])
    }

    func testDoesntReturnPlatformContextIfDisabled() {
        let subject = Subject(platformContext: false, geoLocationContext: false)
        let platformDict = subject.platformDict(userAnonymisation: false, advertisingIdentifierRetriever: nil)
        XCTAssertNil(platformDict)
    }

    func testReturnsGeolocationContextIfEnabled() {
        let subject = Subject(platformContext: false, geoLocationContext: true)
        subject.geoLatitude = NSNumber(value: 10.0)
        subject.geoLongitude = NSNumber(value: 10.0)
        let geoLocationDict = subject.geoLocationDict
        XCTAssertNotNil(geoLocationDict)
        XCTAssertNotNil(geoLocationDict)
    }

    func testDoesntReturnGeolocationContextIfDisabled() {
        let subject = Subject(platformContext: false, geoLocationContext: false)
        subject.geoLatitude = NSNumber(value: 10.0)
        subject.geoLongitude = NSNumber(value: 10.0)
        let geoLocationDict = subject.geoLocationDict
        XCTAssertNil(geoLocationDict)
    }

    func testAnonymisesUserIdentifiers() {
        let subject = Subject(platformContext: false, geoLocationContext: false)
        subject.userId = "aUserId"
        subject.ipAddress = "127.0.0.1"
        subject.networkUserId = "aNuid"
        subject.domainUserId = "aDuid"
        subject.language = "EN"

        let values = subject.standardDict(userAnonymisation: true)
        XCTAssertNil(values[kSPUid])
        XCTAssertNil(values[kSPIpAddress])
        XCTAssertNil(values[kSPNetworkUid])
        XCTAssertNil(values[kSPDomainUid])
        XCTAssertEqual(values[kSPLanguage], "EN")
    }
}
