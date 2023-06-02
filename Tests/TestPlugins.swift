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

class TestPlugins: XCTestCase {
    override func tearDown() {
        Snowplow.removeAllTrackers()
        super.tearDown()
    }
    
    func testAddsEntitiesToEvent() {
        let plugin = PluginConfiguration(identifier: "plugin")
            .entities { [SelfDescribingJson(schema: "schema", andData: ["val": $0.payload["se_ca"]!])] }
        
        let expect = expectation(description: "Has context entity on event")
        let testPlugin = PluginConfiguration(identifier: "test")
            .afterTrack { event in
                XCTAssertTrue(
                    event.entities.filter({ entity in
                        entity.schema == "schema" && entity.data["val"] as? String == "cat"
                    }).count == 1
                )
                expect.fulfill()
            }
        
        let tracker = createTracker([plugin, testPlugin])
        _ = tracker.track(Structured(category: "cat", action: "act"))
        
        wait(for: [expect], timeout: 10)
    }
    
    func testAddsEntitiesFromMultiplePlugins() {
        let plugin1 = PluginConfiguration(identifier: "plugin1")
            .entities { _ in [SelfDescribingJson(schema: "schema1", andData: [:])] }
        
        let plugin2 = PluginConfiguration(identifier: "plugin2")
            .entities { _ in [SelfDescribingJson(schema: "schema2", andData: [:])] }
        
        let expect = expectation(description: "Has both context entities on event")
        let testPlugin = PluginConfiguration(identifier: "test")
            .afterTrack { event in
                XCTAssertTrue(
                    event.entities.filter({ $0.schema == "schema1" }).count == 1
                )
                XCTAssertTrue(
                    event.entities.filter({ $0.schema == "schema2" }).count == 1
                )
                expect.fulfill()
            }
        
        let tracker = createTracker([plugin1, plugin2, testPlugin])
        _ = tracker.track(ScreenView(name: "sv"))
        
        wait(for: [expect], timeout: 1)
    }
    
    func testAddsEntitiesOnlyForEventsMatchingSchema() {
        let plugin = PluginConfiguration(identifier: "plugin")
            .entities(schemas: ["schema1"]) { _ in [SelfDescribingJson(schema: "xx", andData: [:])] }
        
        var event1HasEntity: Bool? = nil
        var event2HasEntity: Bool? = nil
        
        let testPlugin = PluginConfiguration(identifier: "test")
            .afterTrack { event in
                if event.schema == "schema1" {
                    event1HasEntity = event.entities.contains(where: { $0.schema == "xx" })
                }
                if event.schema == "schema2" {
                    event2HasEntity = event.entities.contains(where: { $0.schema == "xx" })
                }
            }
        
        let tracker = createTracker([plugin, testPlugin])
        _ = tracker.track(SelfDescribing(schema: "schema1", payload: [:]))
        _ = tracker.track(SelfDescribing(schema: "schema2", payload: [:]))
        
        waitForEventsToBeTracked()
        
        XCTAssertTrue(event1HasEntity!)
        XCTAssertFalse(event2HasEntity!)
    }
    
    func testCallsAfterTrackOnlyForEventsMatchingSchema() {
        var event1Called: Bool = false
        var event2Called: Bool = false
        var event3Called: Bool = false
        
        let plugin = PluginConfiguration(identifier: "plugin")
            .afterTrack(schemas: ["schema1"]) { event in
                if event.schema == "schema1" { event1Called = true }
                if event.schema == "schema2" { event2Called = true }
                if event.schema == nil { event3Called = true }
            }
        
        let tracker = createTracker([plugin])
        _ = tracker.track(SelfDescribing(schema: "schema1", payload: [:]))
        _ = tracker.track(SelfDescribing(schema: "schema2", payload: [:]))
        _ = tracker.track(Structured(category: "cat", action: "act"))
        
        waitForEventsToBeTracked()
        
        XCTAssertTrue(event1Called)
        XCTAssertFalse(event2Called)
        XCTAssertFalse(event3Called)
    }
    
    func testCallsAfterTrackOnlyForStructuredEvent() {
        var selfDescribingCalled: Bool = false
        var structuredCalled: Bool = false
        
        let plugin = PluginConfiguration(identifier: "plugin")
            .afterTrack(schemas: ["se"]) { event in
                if event.schema == "schema1" { selfDescribingCalled = true }
                if event.schema == nil { structuredCalled = true }
            }
        
        let tracker = createTracker([plugin])
        _ = tracker.track(SelfDescribing(schema: "schema1", payload: [:]))
        _ = tracker.track(Structured(category: "cat", action: "act"))
        
        waitForEventsToBeTracked()
        
        XCTAssertTrue(structuredCalled)
        XCTAssertFalse(selfDescribingCalled)
    }
    
    func testAddsPluginToTracker() {
        let tracker = createTracker([])
        
        let expect = expectation(description: "Plugin called")
        let plugin = PluginConfiguration(identifier: "plugin")
            .afterTrack { _ -> Void in expect.fulfill() }
        tracker.plugins.add(plugin: plugin)
        
        _ = tracker.track(ScreenView(name: "sv"))
        
        wait(for: [expect], timeout: 1)
    }
    
    func testRemovesPluginFromTracker() {
        var pluginCalled = false
        let plugin = PluginConfiguration(identifier: "plugin")
            .afterTrack { _ in pluginCalled = true }
        
        let tracker = createTracker([plugin])
        XCTAssertEqual(["plugin"], tracker.plugins.identifiers)
        tracker.plugins.remove(identifier: "plugin")
        
        _ = tracker.track(ScreenView(name: "sv"))
        
        let expect = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () -> Void in expect.fulfill() }
        wait(for: [expect], timeout: 1)
        
        XCTAssertFalse(pluginCalled)
    }
    
    func testFiltersEvents() {
        let filterPlugin = PluginConfiguration(identifier: "filter")
            .filter(schemas: ["s1"]) { _ in false }
        
        var afterTrackCalled = false
        let afterTrackPlugin = PluginConfiguration(identifier: "afterTrack")
            .afterTrack { _ in afterTrackCalled = true }
        
        let tracker = createTracker([filterPlugin, afterTrackPlugin])
        
        // track event with the schema to filter out
        _ = tracker.track(SelfDescribing(schema: "s1", payload: [:]))
        
        let expect1 = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () -> Void in expect1.fulfill() }
        wait(for: [expect1], timeout: 1)
        
        XCTAssertFalse(afterTrackCalled)
        
        // track event with a different schema
        _ = tracker.track(SelfDescribing(schema: "s2", payload: [:]))
        
        let expect2 = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () -> Void in expect2.fulfill() }
        wait(for: [expect2], timeout: 1)
        
        XCTAssertTrue(afterTrackCalled)
    }
    
    private func createTracker(_ configurations: [ConfigurationProtocol]) -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        let namespace = "testPlugins" + String(describing: Int.random(in: 0..<100))
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: configurations + [trackerConfig])!
    }
    
    private func waitForEventsToBeTracked() {
        let expect = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () -> Void in
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }
}
