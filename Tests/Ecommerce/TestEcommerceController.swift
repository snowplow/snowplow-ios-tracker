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
        
        
//        let cart = CartEntity(totalValue: 500, currency: "GBP")
//
//        let event = AddToCartEvent(products: [product1, product2], cart: cart)
//        let entities = event.entitiesForProcessing
//
//        XCTAssertEqual(ecommerceActionSchema, event.schema)
//        XCTAssertEqual("add_to_cart", event.payload["type"] as? String)
//        XCTAssertEqual(3, entities?.count)
//        XCTAssertEqual(2, getProductEntities(entities).count)
//        XCTAssertEqual(1, getCartEntities(entities).count)
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
}
