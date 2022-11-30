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
        XCTAssertNotEqual(dp1, dp2)
    }

    func testDataPersistenceForNamespaceWithSameNamespaces() {
        let dp1 = DataPersistence.getFor(namespace: "namespace")
        let dp2 = DataPersistence.getFor(namespace: "namespace")
        XCTAssertEqual(dp1, dp2)
    }

    func testRemoveForNamespace() {
        let dp1 = DataPersistence.getFor(namespace: "namespace")
        _ = DataPersistence.remove(withNamespace: "namespace")
        let dp2 = DataPersistence.getFor(namespace: "namespace")
        XCTAssertNotEqual(dp1, dp2)
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
            "key": "value" as NSObject
        ]
        dp?.session = session
        XCTAssertEqual(session, dp?.session)
        XCTAssertEqual(session, dp?.data["session"])
        // Override session
        session = [
            "key2": "value2" as NSObject
        ]
        dp?.session = session
        XCTAssertEqual(session, dp?.session)
        XCTAssertEqual(session, dp?.data["session"])
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
            "key": "value" as NSObject
        ]
        dp1?.session = session
        // Check dp1
        XCTAssertEqual(session, dp1?.session)
        XCTAssertEqual(session, dp1?.data["session"])
        // Check dp2
        XCTAssertNotEqual(session, dp2?.session)
        XCTAssertNotEqual(session, dp2?.data["session"])
    }
}
