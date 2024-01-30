//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

import Foundation
class TestScreenSummaryStateMachine: XCTestCase {
    var timeTraveler = TimeTraveler()
    
    override func setUp() {
        ScreenSummaryState.dateGenerator = timeTraveler.generateTimeInterval
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testTrackTransitionToBackgroundAndForeground() {
        let expectBackground = expectation(description: "Background event")
        let expectForeground = expectation(description: "Foreground event")
        
        let eventSink = EventSink { event in
            if event.schema == kSPBackgroundSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["foreground_sec"] as? Double, 10.0)
                XCTAssertEqual((entity?.data as? [String: Any])?["background_sec"] as? Double, 0.0)
                expectBackground.fulfill()
            }
            
            if event.schema == kSPForegroundSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["foreground_sec"] as? Double, 10.0)
                XCTAssertEqual((entity?.data as? [String: Any])?["background_sec"] as? Double, 5.0)
                expectForeground.fulfill()
            }
        }
        
        let tracker = createTracker([eventSink])
        
        _ = tracker.track(ScreenView(name: "Screen 1"))
        InternalQueue.sync { timeTraveler.travel(by: 10) }
        _ = tracker.track(Background(index: 1))
        InternalQueue.sync { timeTraveler.travel(by: 5) }
        _ = tracker.track(Foreground(index: 1))
        
        wait(for: [expectBackground, expectForeground], timeout: 10)
    }
    
    func testTracksScreenEndEventWithScreenSummary() {
        let expectScreenEnd = expectation(description: "Screen end event")
        
        let eventSink = EventSink { event in
            if event.schema == kSPScreenEndSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["foreground_sec"] as? Double, 10.0)
                XCTAssertEqual((entity?.data as? [String: Any])?["background_sec"] as? Double, 0.0)
                expectScreenEnd.fulfill()
            }
        }
        
        let tracker = createTracker([eventSink])
        
        _ = tracker.track(ScreenView(name: "Screen 1"))
        InternalQueue.sync { timeTraveler.travel(by: 10) }
        _ = tracker.track(ScreenView(name: "Screen 2"))
        
        wait(for: [expectScreenEnd], timeout: 10)
    }
    
    func testUpdatesListMetrics() {
        let expectScreenEnd = expectation(description: "Screen end event")
        
        let eventSink = EventSink { event in
            if event.schema == kSPScreenEndSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["last_item_index"] as? Int, 3)
                XCTAssertEqual((entity?.data as? [String: Any])?["items_count"] as? Int, 10)
                expectScreenEnd.fulfill()
            }
        }
        
        let tracker = createTracker([eventSink])
        
        _ = tracker.track(ScreenView(name: "Screen 1"))
        _ = tracker.track(ListItemView(index: 1, totalItems: 10))
        _ = tracker.track(ListItemView(index: 3, totalItems: 10))
        _ = tracker.track(ListItemView(index: 2, totalItems: 10))
        _ = tracker.track(ScreenView(name: "Screen 2"))
        
        wait(for: [expectScreenEnd], timeout: 10)
    }
    
    func testUpdatesScrollMetrics() {
        let expectScreenEnd = expectation(description: "Screen end event")
        
        let eventSink = EventSink { event in
            if event.schema == kSPScreenEndSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["min_y_offset"] as? Int, 10)
                XCTAssertEqual((entity?.data as? [String: Any])?["min_x_offset"] as? Int, 15)
                XCTAssertEqual((entity?.data as? [String: Any])?["max_y_offset"] as? Int, 50)
                XCTAssertEqual((entity?.data as? [String: Any])?["max_x_offset"] as? Int, 30)
                XCTAssertEqual((entity?.data as? [String: Any])?["content_height"] as? Int, 100)
                XCTAssertEqual((entity?.data as? [String: Any])?["content_width"] as? Int, 200)
                expectScreenEnd.fulfill()
            }
        }
        
        let tracker = createTracker([eventSink])
        
        _ = tracker.track(ScreenView(name: "Screen 1"))
        _ = tracker.track(ScrollChanged(yOffset: 10, viewHeight: 20, contentHeight: 100))
        _ = tracker.track(ScrollChanged(xOffset: 15, yOffset: 30, viewWidth: 15, viewHeight: 20, contentWidth: 200, contentHeight: 100))
        _ = tracker.track(ScrollChanged(yOffset: 20, viewHeight: 20, contentHeight: 100))
        _ = tracker.track(ScreenView(name: "Screen 2"))
        
        wait(for: [expectScreenEnd], timeout: 10)
    }

    private func createTracker(_ configurations: [ConfigurationProtocol]) -> TrackerController {
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        let namespace = "testScreenSummary" + String(describing: Int.random(in: 0..<100))
        return Snowplow.createTracker(namespace: namespace,
                                      network: networkConfig,
                                      configurations: configurations + [trackerConfig])
    }
}
