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

class TestDataPersistence: XCTestCase {
    override func setUp() {
        _ = DataPersistence.remove(withNamespace: "namespace")
        _ = DataPersistence.remove(withNamespace: "namespace1")
        _ = DataPersistence.remove(withNamespace: "namespace2")
    }

    func testStringFromNamespace() {
        XCTAssertEqual("abc-1_2_3", DataPersistence.string(fromNamespace: "abc 1_2_3"))
    }

    func testDataPersistenceForNamespaceWithDifferentNamespaces() {
        let dp1 = DataPersistence.getFor(namespace: "namespace1")
        let dp2 = DataPersistence.getFor(namespace: "namespace2")
        XCTAssertFalse(dp1 === dp2)
    }

    func testDataPersistenceForNamespaceWithSameNamespaces() {
        let dp1 = DataPersistence.getFor(namespace: "namespace")
        let dp2 = DataPersistence.getFor(namespace: "namespace")
        XCTAssertTrue(dp1 === dp2)
    }

    func testRemoveForNamespace() {
        let dp1 = DataPersistence.getFor(namespace: "namespace")
        _ = DataPersistence.remove(withNamespace: "namespace")
        let dp2 = DataPersistence.getFor(namespace: "namespace")
        XCTAssertFalse(dp1 === dp2)
    }

    func testDataIsCorrectlyStored() {
        commonTestDataIsCorrectlyStored(onFile: true)
    }

    func testDataIsCorrectlyStoredWhenNotStoredOnFile() {
        commonTestDataIsCorrectlyStored(onFile: false)
    }

    func commonTestDataIsCorrectlyStored(onFile isStoredOnFile: Bool) {
        let dp = DataPersistence.getFor(namespace: "namespace", storedOnFile: isStoredOnFile)
        var session = [
            "key": "value"
        ]
        dp?.session = session
        XCTAssertEqual(session, dp?.session as! [String : String])
        XCTAssertEqual(session, dp?.data["session"] as! [String : String])
        // Override session
        session = [
            "key2": "value2"
        ]
        dp?.session = session
        XCTAssertEqual(session, dp?.session as! [String : String])
        XCTAssertEqual(session, dp?.data["session"] as! [String : String])
    }

    func testDataIsStoredWithoutInterference() {
        commonTestDataIsStoredWithoutInterferenceStored(onFile: true)
    }

    func testDataIsStoredWithoutInterferenceWhenNotStoredOnFile() {
        commonTestDataIsStoredWithoutInterferenceStored(onFile: false)
    }

    func commonTestDataIsStoredWithoutInterferenceStored(onFile isStoredOnFile: Bool) {
        let dp1 = DataPersistence.getFor(namespace: "namespace1", storedOnFile: isStoredOnFile)
        let dp2 = DataPersistence.getFor(namespace: "namespace2", storedOnFile: isStoredOnFile)
        let session = [
            "key": "value"
        ]
        dp1?.session = session
        // Check dp1
        XCTAssertEqual(session, dp1?.session as? [String : String])
        XCTAssertEqual(session, dp1?.data["session"] as? [String : String])
        // Check dp2
        XCTAssertNotEqual(session, dp2?.session as? [String : String])
        XCTAssertNotEqual(session, dp2?.data["session"] as? [String : String])
    }
}
