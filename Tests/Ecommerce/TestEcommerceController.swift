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

class TestEcommerceController: XCTestCase {
    
    var trackedEvents: [InspectableEvent] = []
    var tracker: TrackerController?
    
    override func setUp() {
        tracker = createTracker()
    }
    
    override func tearDown() {
        Snowplow.removeAllTrackers()
        trackedEvents.removeAll()
    }
    
    func testAddScreenEntity() {
        tracker?.ecommerce.setEcommerceScreen(EcommerceScreenEntity(type: "product", language: "EN-GB", locale: "UK"))
        
        _ = tracker?.track(ScreenView(name: "screenId"))
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(trackedEvents[0].entities.contains { $0.schema == ecommercePageSchema })
        
        let screenEntities = getScreenEntities(trackedEvents[0].entities)
        XCTAssertEqual(1, screenEntities.count)
        
        var entity = screenEntities[0]
        XCTAssertEqual("product", entity.data["type"] as? String)
        XCTAssertEqual("EN-GB", entity.data["language"] as? String)
        XCTAssertEqual("UK", entity.data["locale"] as? String)
        
        // replacing earlier Screen
        tracker?.ecommerce.setEcommerceScreen(EcommerceScreenEntity(type: "listing", locale: "USA"))
        _ = tracker?.track(ScreenView(name: "screenId2"))
        waitForEventsToBeTracked()
        
        entity = getScreenEntities(trackedEvents[1].entities)[0]
        XCTAssertEqual("listing", entity.data["type"] as? String)
        XCTAssertEqual("USA", entity.data["locale"] as? String)
        
        // removing Screen
        tracker?.ecommerce.removeEcommerceScreen()
        _ = tracker?.track(ScreenView(name: "screenId3"))
        waitForEventsToBeTracked()
        
        XCTAssertFalse(trackedEvents[2].entities.contains { $0.schema == ecommercePageSchema })
    }
    
    func testAddUserEntity() {
        tracker?.ecommerce.setEcommerceUser(EcommerceUserEntity(id: "userId", isGuest: true, email: "email@email.com"))
        
        _ = tracker?.track(ScreenView(name: "screenId"))
        waitForEventsToBeTracked()
        
        XCTAssertEqual(1, trackedEvents.count)
        XCTAssert(trackedEvents[0].entities.contains { $0.schema == ecommerceUserSchema })
        
        let userEntities = getUserEntities(trackedEvents[0].entities)
        XCTAssertEqual(1, userEntities.count)
        
        var entity = userEntities[0]
        XCTAssertEqual("userId", entity.data["id"] as? String)
        XCTAssertEqual(true, entity.data["is_guest"] as? Bool)
        XCTAssertEqual("email@email.com", entity.data["email"] as? String)
        
        // replacing earlier User
        tracker?.ecommerce.setEcommerceUser(EcommerceUserEntity(id: "newUser", isGuest: false))
        _ = tracker?.track(ScreenView(name: "screenId2"))
        waitForEventsToBeTracked()
        
        entity = getUserEntities(trackedEvents[1].entities)[0]
        XCTAssertEqual("newUser", entity.data["id"] as? String)
        XCTAssertEqual(false, entity.data["is_guest"] as? Bool)
        
        // removing Screen
        tracker?.ecommerce.removeEcommerceUser()
        _ = tracker?.track(ScreenView(name: "screenId3"))
        waitForEventsToBeTracked()
        
        XCTAssertFalse(trackedEvents[2].entities.contains { $0.schema == ecommerceUserSchema })
    }
    
    private func createTracker() -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        
        let namespace = "testEcommerce" + String(describing: Int.random(in: 0..<100))
        let plugin = PluginConfiguration(identifier: "testPlugin" + namespace)
            .afterTrack { event in
                if namespace == self.tracker?.namespace {
                    self.trackedEvents.append(event)
                }
            }
        
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: [trackerConfig, plugin])!
    }
    
    private func waitForEventsToBeTracked() {
        let expect = expectation(description: "Wait for events to be tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () -> Void in
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }
    
    private func getScreenEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == ecommercePageSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
    
    private func getUserEntities(_ all: [SelfDescribingJson]?) -> [SelfDescribingJson] {
        var entities: [SelfDescribingJson] = []
        if let all = all {
            for entity in all {
                if (entity.schema == ecommerceUserSchema) {
                    entities.append(entity)
                }
            }
        }
        return entities
    }
}
