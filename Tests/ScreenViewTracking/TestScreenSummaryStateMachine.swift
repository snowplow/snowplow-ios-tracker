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
        AppStateSimulator.reset()
        super.setUp()
    }

    override func tearDown() {
        AppStateSimulator.reset()
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
    
    func testEndScreenViewClosesOutEngagementDuration() {
        let expectEndScreenView = expectation(description: "EndScreenView event")

        let eventSink = EventSink { event in
            if event.schema == kSPEndScreenViewSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["foreground_sec"] as? Double, 10.0)
                expectEndScreenView.fulfill()
            }
        }

        let tracker = createTracker([eventSink])

        _ = tracker.track(ScreenView(name: "Screen 1"))
        InternalQueue.sync { timeTraveler.travel(by: 10) }
        _ = tracker.track(EndScreenView())

        wait(for: [expectEndScreenView], timeout: 10)
    }

    func testEndScreenViewWithMatchingScreenIdClosesOutEngagementDuration() {
        let expectEndScreenView = expectation(description: "EndScreenView event")
        let screenId = UUID()

        let eventSink = EventSink { event in
            if event.schema == kSPEndScreenViewSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["foreground_sec"] as? Double, 10.0)
                expectEndScreenView.fulfill()
            }
        }

        let tracker = createTracker([eventSink])

        _ = tracker.track(ScreenView(name: "Screen 1", screenId: screenId))
        InternalQueue.sync { timeTraveler.travel(by: 10) }
        _ = tracker.track(EndScreenView(screenId: screenId))

        wait(for: [expectEndScreenView], timeout: 10)
    }

    /// A delayed/stale EndScreenView call referencing a screen the user has already natively
    /// navigated away from must not be tracked, and must not close out the engagement duration
    /// of whichever screen is currently active.
    func testEndScreenViewWithMismatchedScreenIdIsIgnored() {
        let expectNoEndScreenView = expectation(description: "EndScreenView event should not fire")
        expectNoEndScreenView.isInverted = true

        let eventSink = EventSink { event in
            if event.schema == kSPEndScreenViewSchema {
                expectNoEndScreenView.fulfill()
            }
        }

        let tracker = createTracker([eventSink])

        _ = tracker.track(ScreenView(name: "Screen 1"))
        InternalQueue.sync { timeTraveler.travel(by: 10) }
        _ = tracker.track(EndScreenView(screenId: UUID()))

        wait(for: [expectNoEndScreenView], timeout: 2)
    }

    /// Once a screen is manually ended, its engagement metrics must be frozen. Later
    /// Foreground/Background transitions and the automatic pre-ScreenView ScreenEnd must not
    /// keep mutating foreground_sec/background_sec on the ended screen's state, or attach a
    /// screen summary entity computed from it — otherwise this reintroduces the exact
    /// over-accumulation bug the manual trigger exists to fix.
    func testEngagementMetricsStopAccumulatingAfterManualEnd() {
        let expectEndScreenView = expectation(description: "EndScreenView event")
        let expectNoEntityOnBackground = expectation(description: "No screen summary entity on Background after end")
        expectNoEntityOnBackground.isInverted = true
        let expectNoEntityOnForeground = expectation(description: "No screen summary entity on Foreground after end")
        expectNoEntityOnForeground.isInverted = true
        let expectNoEntityOnAutomaticScreenEnd = expectation(description: "No screen summary entity on automatic ScreenEnd after manual end")
        expectNoEntityOnAutomaticScreenEnd.isInverted = true

        let eventSink = EventSink { event in
            if event.schema == kSPEndScreenViewSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["foreground_sec"] as? Double, 10.0)
                expectEndScreenView.fulfill()
            }
            if event.schema == kSPBackgroundSchema {
                if event.entities.first(where: { $0.schema == kSPScreenSummarySchema }) != nil {
                    expectNoEntityOnBackground.fulfill()
                }
            }
            if event.schema == kSPForegroundSchema {
                if event.entities.first(where: { $0.schema == kSPScreenSummarySchema }) != nil {
                    expectNoEntityOnForeground.fulfill()
                }
            }
            if event.schema == kSPScreenEndSchema {
                if event.entities.first(where: { $0.schema == kSPScreenSummarySchema }) != nil {
                    expectNoEntityOnAutomaticScreenEnd.fulfill()
                }
            }
        }

        let tracker = createTracker([eventSink])

        _ = tracker.track(ScreenView(name: "Screen 1"))
        InternalQueue.sync { timeTraveler.travel(by: 10) }
        _ = tracker.track(EndScreenView())
        InternalQueue.sync { timeTraveler.travel(by: 5) }
        _ = tracker.track(Background(index: 1))
        InternalQueue.sync { timeTraveler.travel(by: 20) }
        _ = tracker.track(Foreground(index: 1))
        // Triggers the automatic pre-ScreenView ScreenEnd flush against the still-ended state.
        _ = tracker.track(ScreenView(name: "Screen 2"))

        wait(for: [expectEndScreenView, expectNoEntityOnBackground, expectNoEntityOnForeground, expectNoEntityOnAutomaticScreenEnd], timeout: 10)
    }

    /// The automatic screen_end flush injected before every real ScreenView must stay on its own
    /// schema — it must never surface as the new manual-trigger schema.
    func testEndScreenViewDoesNotFireAsSideEffectOfAutomaticScreenTransition() {
        let expectScreenEnd = expectation(description: "Screen end event")
        let expectNoEndScreenView = expectation(description: "EndScreenView event should not fire")
        expectNoEndScreenView.isInverted = true

        let eventSink = EventSink { event in
            if event.schema == kSPScreenEndSchema {
                expectScreenEnd.fulfill()
            }
            if event.schema == kSPEndScreenViewSchema {
                expectNoEndScreenView.fulfill()
            }
        }

        let tracker = createTracker([eventSink])

        _ = tracker.track(ScreenView(name: "Screen 1"))
        _ = tracker.track(ScreenView(name: "Screen 2"))

        wait(for: [expectScreenEnd, expectNoEndScreenView], timeout: 10)
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

    /// Seeding the session as being in the background makes the Foreground event fire when the app is opened,
    /// which reattributes the time the screen spent in a background-launched process to `background_sec`.
    /// Before the seed, no Foreground event fired at all and all of that time was credited to `foreground_sec`.
    func testAttributesTimeBeforeTheFirstForegroundOnABackgroundLaunchToBackgroundSeconds() {
        simulateAppState(.background)

        let expectForeground = expectation(description: "Foreground event")

        let eventSink = EventSink { event in
            if event.schema == kSPForegroundSchema {
                let entity = event.entities.first { $0.schema == kSPScreenSummarySchema }
                XCTAssertEqual((entity?.data as? [String: Any])?["foreground_sec"] as? Double, 0.0)
                XCTAssertEqual((entity?.data as? [String: Any])?["background_sec"] as? Double, 10.0)
                expectForeground.fulfill()
            }
        }

        let namespace = "testBackgroundLaunchScreenSummary"
        let emitter = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200),
                              namespace: namespace,
                              eventStore: MockEventStore())
        let tracker = Tracker(trackerNamespace: namespace, appId: nil, emitter: emitter) { tracker in
            tracker.installEvent = false
            tracker.lifecycleEvents = true
            tracker.sessionContext = true
            tracker.screenEngagementAutotracking = true
        }
        tracker.addOrReplace(stateMachine: eventSink.toStateMachine())

        InternalQueue.sync { _ = tracker.track(ScreenView(name: "Screen 1")) }
        InternalQueue.sync { timeTraveler.travel(by: 10) }
        tracker.session?.updateInForeground()

        wait(for: [expectForeground], timeout: 10)
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
