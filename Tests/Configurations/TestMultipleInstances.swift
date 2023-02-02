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

class TestMultipleInstances: XCTestCase {
    override func setUp() {
        Snowplow.removeAllTrackers()
    }

    override func tearDown() {
        Snowplow.removeAllTrackers()
    }

    func testSingleInstanceIsReconfigurable() {
        let t1 = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake"))
        XCTAssertEqual(t1?.network?.endpoint, "https://snowplowanalytics.fake/com.snowplowanalytics.snowplow/tp2")
        let t2 = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake2"))
        XCTAssertEqual(t2?.network?.endpoint, "https://snowplowanalytics.fake2/com.snowplowanalytics.snowplow/tp2")
        XCTAssertEqual(["t1"], Snowplow.instancedTrackerNamespaces)
        XCTAssertTrue(t1 === t2)
    }

    func testMultipleInstances() {
        let t1 = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake"))
        XCTAssertEqual(t1?.network?.endpoint, "https://snowplowanalytics.fake/com.snowplowanalytics.snowplow/tp2")
        let t2 = Snowplow.createTracker(namespace: "t2", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake2"))
        XCTAssertEqual(t2?.network?.endpoint, "https://snowplowanalytics.fake2/com.snowplowanalytics.snowplow/tp2")
        XCTAssertFalse(t1 === t2)
        let expectedNamespaces = Set<String>(["t1", "t2"])
        XCTAssertEqual(expectedNamespaces, Set<String>(Snowplow.instancedTrackerNamespaces))
    }

    func testDefaultTracker() {
        let t1 = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake"))
        _ = Snowplow.createTracker(namespace: "t2", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake2"))
        let td = Snowplow.defaultTracker()
        XCTAssertEqual(t1?.namespace, td?.namespace)
    }

    func testUpdateDefaultTracker() {
        _ = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake"))
        let t2 = Snowplow.createTracker(namespace: "t2", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake2"))
        _ = Snowplow.setAsDefault(tracker: t2)
        let td = Snowplow.defaultTracker()
        XCTAssertEqual(t2?.namespace, td?.namespace)
    }

    func testRemoveTracker() {
        let t1 = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake"))
        let t2 = Snowplow.createTracker(namespace: "t2", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake2"))
        _ = Snowplow.remove(tracker: t1)
        XCTAssertNotNil(t2)
        XCTAssertEqual(["t2"], Snowplow.instancedTrackerNamespaces)
    }

    func testRecreateTrackerWhichWasRemovedWithSameNamespace() {
        let t1 = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake"))
        _ = Snowplow.remove(tracker: t1)
        let t2 = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake2"))
        XCTAssertFalse(t1 === t2)
        XCTAssertEqual(["t1"], Snowplow.instancedTrackerNamespaces)
    }

    func testRemoveDefaultTracker() {
        let t1 = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake"))
        _ = Snowplow.remove(tracker: t1)
        let td = Snowplow.defaultTracker()
        XCTAssertNil(td)
        XCTAssertEqual([], Snowplow.instancedTrackerNamespaces)
    }

    func testRemoveAllTrackers() {
        _ = Snowplow.createTracker(namespace: "t1", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake"))
        _ = Snowplow.createTracker(namespace: "t2", network: NetworkConfiguration(endpoint: "snowplowanalytics.fake2"))
        Snowplow.removeAllTrackers()
        XCTAssertEqual([], Snowplow.instancedTrackerNamespaces)
    }
}
