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

class TestSession: XCTestCase {
    override func setUp() {
        super.setUp()
        cleanFile(withNamespace: "tracker")
        UserDefaults.standard.removeObject(forKey: kSPInstallationUserId)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let session = Session(foregroundTimeout: 600, backgroundTimeout: 300)
        XCTAssertTrue(!session.inBackground)
        XCTAssertNotNil(session.getDictWithEventId("eventid-1", eventTimestamp: 1654496481346, userAnonymisation: false))
        XCTAssertTrue(session.sessionIndex ?? 0 >= 1)
        XCTAssertEqual(session.foregroundTimeout, 600000)
        XCTAssertEqual(session.backgroundTimeout, 300000)
    }

    func testInitWithOptions() {
        let session = Session(foregroundTimeout: 5, backgroundTimeout: 300)
        XCTAssertEqual(session.foregroundTimeout, 5000)
        XCTAssertEqual(session.backgroundTimeout, 300000)

        session.backgroundTimeout = 5
        session.foregroundTimeout = 10

        XCTAssertEqual(session.foregroundTimeout, 10)
        XCTAssertEqual(session.backgroundTimeout, 5)
    }

    func testFirstSession() {
        let session = Session(foregroundTimeout: 3, backgroundTimeout: 3)

        let sessionContext = session.getDictWithEventId("event_1", eventTimestamp: 1654496481346, userAnonymisation: false)
        let sessionIndex = session.sessionIndex ?? 0
        XCTAssertEqual(1, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.346Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
    }

    func testForegroundEventsOnSameSession() {
        let session = Session(foregroundTimeout: 3, backgroundTimeout: 3)

        var sessionContext = session.getDictWithEventId("event_1", eventTimestamp: 1654496481346, userAnonymisation: false)
        var sessionIndex = session.sessionIndex ?? 0
        let sessionId = sessionContext?[kSPSessionId] as? String
        XCTAssertEqual(1, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.346Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)

        Thread.sleep(forTimeInterval: 1)

        sessionContext = session.getDictWithEventId("event_2", eventTimestamp: 1654496481347, userAnonymisation: false)
        sessionIndex = session.sessionIndex ?? 0
        XCTAssertEqual(1, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.346Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertEqual(sessionId, sessionContext?[kSPSessionId] as? String)

        Thread.sleep(forTimeInterval: 1)

        sessionContext = session.getDictWithEventId("event_3", eventTimestamp: 1654496481348, userAnonymisation: false)
        sessionIndex = session.sessionIndex ?? 0
        XCTAssertEqual(1, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.346Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertEqual(sessionId, sessionContext?[kSPSessionId] as? String)

        Thread.sleep(forTimeInterval: 3.1)

        sessionContext = session.getDictWithEventId("event_4", eventTimestamp: 1654496481349, userAnonymisation: false)
        sessionIndex = session.sessionIndex ?? 0
        XCTAssertEqual(2, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual("event_4", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.349Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertNotEqual(sessionId, sessionContext?[kSPSessionId] as? String)
    }

    func testBackgroundEventsOnWhenLifecycleEventsDisabled() {
        cleanFile(withNamespace: "tracker")

        let emitter = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500), namespace: "tracker")
        let tracker = Tracker(trackerNamespace: "tracker", appId: nil, emitter: emitter) { tracker in
            tracker.lifecycleEvents = false
            tracker.sessionContext = true
            tracker.foregroundTimeout = 3
            tracker.backgroundTimeout = 2
        }
        
        let session = tracker.session
        session?.updateInBackground()

        let sessionContext = session?.getDictWithEventId("event_1", eventTimestamp: 1654496481346, userAnonymisation: false)
        let sessionIndex = session?.sessionIndex ?? 0
        XCTAssertEqual(1, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.346Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertFalse(session!.inBackground)
        XCTAssertEqual(0, session?.backgroundIndex)
    }

    func testBackgroundEventsOnSameSession() {
        cleanFile(withNamespace: "t1")
        
        let emitter = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500), namespace: "t1")
        let tracker = Tracker(trackerNamespace: "t1", appId: nil, emitter: emitter) { tracker in
            tracker.installEvent = false
            tracker.lifecycleEvents = true
            tracker.sessionContext = true
            tracker.foregroundTimeout = 3
            tracker.backgroundTimeout = 2
        }
        let session = tracker.session

        session?.updateInBackground() // It sends a background event
        
        Thread.sleep(forTimeInterval: 1)

        let sessionId = session?.sessionId

        var sessionContext = session?.getDictWithEventId("event_1", eventTimestamp: 1654496481346, userAnonymisation: false)
        var sessionIndex = session?.sessionIndex ?? 0
        XCTAssertEqual(1, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual(sessionId, sessionContext?[kSPSessionId] as? String)
        XCTAssertTrue(session!.inBackground)
        XCTAssertEqual(1, session?.backgroundIndex)

        Thread.sleep(forTimeInterval: 1)

        sessionContext = session?.getDictWithEventId("event_2", eventTimestamp: 1654496481347, userAnonymisation: false)
        sessionIndex = session?.sessionIndex ?? 0
        XCTAssertEqual(1, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual(sessionId, sessionContext?[kSPSessionId] as? String)
        XCTAssertTrue(session!.inBackground)
        XCTAssertEqual(1, session?.backgroundIndex)

        Thread.sleep(forTimeInterval: 1)

        sessionContext = session?.getDictWithEventId("event_3", eventTimestamp: 1654496481348, userAnonymisation: false)
        sessionIndex = session?.sessionIndex ?? 0
        XCTAssertEqual(1, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual(sessionId, sessionContext?[kSPSessionId] as? String)
        XCTAssertTrue(session!.inBackground)
        XCTAssertEqual(1, session?.backgroundIndex)

        Thread.sleep(forTimeInterval: 2.1)

        sessionContext = session?.getDictWithEventId("event_4", eventTimestamp: 1654496481349, userAnonymisation: false)
        sessionIndex = session?.sessionIndex ?? 0
        XCTAssertEqual(2, sessionIndex)
        XCTAssertEqual(sessionIndex, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual("event_4", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.349Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertNotEqual(sessionId, sessionContext?[kSPSessionId] as? String)
        XCTAssertTrue(session!.inBackground)
        XCTAssertEqual(1, session?.backgroundIndex)
    }

    func testMixedEventsOnManySessions() {
        cleanFile(withNamespace: "t2")
        
        let emitter = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500), namespace: "t2")
        let tracker = Tracker(trackerNamespace: "t2", appId: nil, emitter: emitter) { tracker in
            tracker.lifecycleEvents = true
            tracker.sessionContext = true
            tracker.foregroundTimeout = 1
            tracker.backgroundTimeout = 1
        }
        let session = tracker.session

        var sessionContext = session?.getDictWithEventId("event_1", eventTimestamp: 1654496481351, userAnonymisation: false)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.351Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertFalse(session!.inBackground)
        XCTAssertEqual(0, session?.backgroundIndex)
        XCTAssertEqual(0, session?.foregroundIndex)
        var oldSessionId = sessionContext?[kSPSessionId] as? String

        session?.updateInBackground()
        Thread.sleep(forTimeInterval: 1.1)

        sessionContext = session?.getDictWithEventId("event_2", eventTimestamp: 1654496481352, userAnonymisation: false)
        XCTAssertEqual(oldSessionId, sessionContext?[kSPSessionPreviousId] as? String)
        XCTAssertEqual("event_2", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.352Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertTrue(session!.inBackground)
        XCTAssertEqual(1, session?.backgroundIndex)
        XCTAssertEqual(0, session?.foregroundIndex)
        oldSessionId = sessionContext?[kSPSessionId] as? String

        session?.updateInForeground()
        Thread.sleep(forTimeInterval: 1.1)

        sessionContext = session?.getDictWithEventId("event_3", eventTimestamp: 1654496481353, userAnonymisation: false)
        XCTAssertEqual(oldSessionId, sessionContext?[kSPSessionPreviousId] as? String)
        XCTAssertEqual("event_3", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.353Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertFalse(session!.inBackground)
        XCTAssertEqual(1, session?.backgroundIndex)
        XCTAssertEqual(1, session?.foregroundIndex)
        oldSessionId = sessionContext?[kSPSessionId] as? String

        session?.updateInBackground()
        Thread.sleep(forTimeInterval: 1.1)

        sessionContext = session?.getDictWithEventId("event_4", eventTimestamp: 1654496481354, userAnonymisation: false)
        XCTAssertEqual(oldSessionId, sessionContext?[kSPSessionPreviousId] as? String)
        XCTAssertEqual("event_4", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.354Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        XCTAssertTrue(session!.inBackground)
        XCTAssertEqual(2, session?.backgroundIndex)
        XCTAssertEqual(1, session?.foregroundIndex)
    }

    func testTimeoutSessionWhenPauseAndResume() {
        let session = Session(foregroundTimeout: 1, backgroundTimeout: 1)

        var sessionContext = session.getDictWithEventId("event_1", eventTimestamp: 1654496481355, userAnonymisation: false)
        var prevSessionId = sessionContext?[kSPSessionId] as? String
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.355Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)

        session.stopChecker()
        Thread.sleep(forTimeInterval: 2)

        sessionContext = session.getDictWithEventId("event_2", eventTimestamp: 1654496481356, userAnonymisation: false)
        XCTAssertEqual(1, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual(prevSessionId, sessionContext?[kSPSessionId] as? String)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.355Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
        prevSessionId = sessionContext?[kSPSessionId] as? String

        session.startChecker()

        sessionContext = session.getDictWithEventId("event_3", eventTimestamp: 1654496481357, userAnonymisation: false)
        XCTAssertEqual(2, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual(prevSessionId, sessionContext?[kSPSessionPreviousId] as? String)
        XCTAssertEqual("event_3", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertEqual("2022-06-06T06:21:21.357Z", sessionContext?[kSPSessionFirstEventTimestamp] as? String)
    }

    func testBackgroundTimeBiggerThanBackgroundTimeoutCausesNewSession() {
        cleanFile(withNamespace: "tracker")
        
        let emitter = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500), namespace: "tracker")
        let tracker = Tracker(trackerNamespace: "tracker", appId: nil, emitter: emitter) { tracker in
            tracker.lifecycleEvents = true
            tracker.sessionContext = true
            tracker.foregroundTimeout = 100
            tracker.backgroundTimeout = 2
        }
        let session = tracker.session

        let sessionContext = session?.getDictWithEventId("event_1", eventTimestamp: 1654496481361, userAnonymisation: false)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertFalse(session!.inBackground)
        XCTAssertEqual(0, session?.backgroundIndex)
        XCTAssertEqual(0, session?.foregroundIndex)
        let oldSessionId = sessionContext?[kSPSessionId] as? String

        Thread.sleep(forTimeInterval: 1) // Smaller than background timeout
        session?.updateInBackground() // Sends a background event
        Thread.sleep(forTimeInterval: 3) // Bigger than background timeout
        session?.updateInForeground() // Sends a foreground event
        Thread.sleep(forTimeInterval: 1)

        XCTAssertEqual(oldSessionId, session?.previousSessionId)
        XCTAssertEqual(2, session?.sessionIndex)
        XCTAssertFalse(session!.inBackground)
        XCTAssertEqual(1, session?.backgroundIndex)
        XCTAssertEqual(1, session?.foregroundIndex)
    }

    func testBackgroundTimeSmallerThanBackgroundTimeoutDoesntCauseNewSession() {
        cleanFile(withNamespace: "tracker")
        
        let emitter = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500), namespace: "tracker")
        let tracker = Tracker(trackerNamespace: "tracker", appId: nil, emitter: emitter) { tracker in
            tracker.lifecycleEvents = true
            tracker.sessionContext = true
            tracker.foregroundTimeout = 100
            tracker.backgroundTimeout = 2
        }
        let session = tracker.session

        let sessionContext = session?.getDictWithEventId("event_1", eventTimestamp: 1654496481358, userAnonymisation: false)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)
        XCTAssertFalse(session!.inBackground)
        XCTAssertEqual(0, session?.backgroundIndex)
        XCTAssertEqual(0, session?.foregroundIndex)
        let oldSessionId = sessionContext?[kSPSessionId] as? String

        Thread.sleep(forTimeInterval: 3) // Bigger than background timeout
        session?.updateInBackground() // Sends a background event
        Thread.sleep(forTimeInterval: 1) // Smaller than background timeout
        session?.updateInForeground() // Sends a foreground event
        Thread.sleep(forTimeInterval: 1)

        XCTAssertEqual(oldSessionId, session?.sessionId)
        XCTAssertEqual(1, session?.sessionIndex)
        XCTAssertFalse(session!.inBackground)
        XCTAssertEqual(1, session?.backgroundIndex)
        XCTAssertEqual(1, session?.foregroundIndex)
    }

    func testNoEventsForLongTimeDontIncreaseIndexMultipleTimes() {
        let session = Session(foregroundTimeout: 1, backgroundTimeout: 1)

        var sessionContext = session.getDictWithEventId("event_1", eventTimestamp: 1654496481359, userAnonymisation: false)
        XCTAssertEqual("event_1", sessionContext?[kSPSessionFirstEventId] as? String)

        Thread.sleep(forTimeInterval: 4)

        sessionContext = session.getDictWithEventId("event_2", eventTimestamp: 1654496481360, userAnonymisation: false)
        XCTAssertEqual(2, sessionContext?[kSPSessionIndex] as? Int)
        XCTAssertEqual("event_2", sessionContext?[kSPSessionFirstEventId] as? String)
    }

    func testMultipleTrackersUpdateDifferentSessions() {
        cleanFile(withNamespace: "tracker1")
        cleanFile(withNamespace: "tracker2")

        let emitter1 = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500), namespace: "tracker1")
        let tracker1 = Tracker(trackerNamespace: "tracker1", appId: nil, emitter: emitter1) { tracker in
            tracker.sessionContext = true
            tracker.foregroundTimeout = 10
            tracker.backgroundTimeout = 10
        }
        let emitter2 = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500), namespace: "tracker2")
        let tracker2 = Tracker(trackerNamespace: "tracker2", appId: nil, emitter: emitter2) { tracker in
            tracker.sessionContext = true
            tracker.foregroundTimeout = 10
            tracker.backgroundTimeout = 10
        }
        let event = Structured(category: "c", action: "a")
        track(event, tracker1)
        track(event, tracker2)

        guard let initialValue1 = tracker1.session?.sessionIndex else { return XCTFail() }
        guard let id1 = tracker1.session?.sessionId else { return XCTFail() }
        guard let initialValue2 = tracker2.session?.sessionIndex else { return XCTFail() }
        guard var id2 = tracker2.session?.sessionId else { return XCTFail() }

        // Retrigger session in tracker1
        Thread.sleep(forTimeInterval: 7)
        track(event, tracker1)
        Thread.sleep(forTimeInterval: 5)

        // Send event to force update of session on tracker2
        track(event, tracker2)
        id2 = tracker2.session!.sessionId!

        // Check sessions have the correct state
        XCTAssertEqual(0, tracker1.session!.sessionIndex! - initialValue1) // retriggered
        XCTAssertEqual(1, tracker2.session!.sessionIndex! - initialValue2) // timed out

        //Recreate tracker2
        let tracker2b = Tracker(trackerNamespace: "tracker2", appId: nil, emitter: emitter2) { tracker in
            tracker.sessionContext = true
            tracker.foregroundTimeout = 5
            tracker.backgroundTimeout = 5
        }
        track(event, tracker2b)
        guard let initialValue2b = tracker2b.session?.sessionIndex else { return XCTFail() }
        guard let previousId2b = tracker2b.session?.previousSessionId else { return XCTFail() }

        // Check the new tracker session gets the data from the old tracker2 session
        XCTAssertEqual(initialValue2 + 2, initialValue2b)
        XCTAssertEqual(id2, previousId2b)
        XCTAssertNotEqual(id1, previousId2b)
    }

    func testMigrateSessionFromV3_0() {
        cleanFile(withNamespace: "tracker")
        storeAsV3_0(withNamespace: "tracker", eventId: "eventId", sessionId: "sessionId", sessionIndex: 123, userId: "userId")

        let emitter = Emitter(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 500), namespace: "tracker")
        let tracker = Tracker(trackerNamespace: "tracker", appId: nil, emitter: emitter) { tracker in
            tracker.sessionContext = true
        }
        let event = Structured(category: "c", action: "a")
        track(event, tracker)

        guard let session = tracker.session else { return XCTFail() }
        XCTAssertEqual("sessionId", session.previousSessionId!)
        XCTAssertEqual(124, session.sessionIndex!)
        XCTAssertEqual("userId", session.userId)
        XCTAssertNotEqual("eventId", session.firstEventId!)
    }

    func testIncrementsEventIndex() {
        let session = Session(foregroundTimeout: 3, backgroundTimeout: 3)

        var sessionContext = session.getDictWithEventId("event_1", eventTimestamp: 1654496481346, userAnonymisation: false)
        XCTAssertEqual(1, sessionContext?[kSPSessionEventIndex] as? Int)

        Thread.sleep(forTimeInterval: 1)

        sessionContext = session.getDictWithEventId("event_2", eventTimestamp: 1654496481347, userAnonymisation: false)
        XCTAssertEqual(2, sessionContext?[kSPSessionEventIndex] as? Int)

        Thread.sleep(forTimeInterval: 1)

        sessionContext = session.getDictWithEventId("event_3", eventTimestamp: 1654496481348, userAnonymisation: false)
        XCTAssertEqual(3, sessionContext?[kSPSessionEventIndex] as? Int)

        Thread.sleep(forTimeInterval: 3.1)

        sessionContext = session.getDictWithEventId("event_4", eventTimestamp: 1654496481349, userAnonymisation: false)
        XCTAssertEqual(1, sessionContext?[kSPSessionEventIndex] as? Int)
    }

    func testAnonymisesUserIdentifiers() {
        let session = Session(foregroundTimeout: 3, backgroundTimeout: 3)
        _ = session.getDictWithEventId("event_1", eventTimestamp: 1654496481345, userAnonymisation: false)
        session.startNewSession() // create previous session ID reference

        let withoutAnonymisation = session.getDictWithEventId("event_2", eventTimestamp: 1654496481346, userAnonymisation: false)
        XCTAssertNotEqual("00000000-0000-0000-0000-000000000000", withoutAnonymisation?[kSPSessionUserId] as? String)
        XCTAssertNotNil(withoutAnonymisation?[kSPSessionPreviousId])

        let withAnonymisation = session.getDictWithEventId("event_3", eventTimestamp: 1654496481347, userAnonymisation: true)
        XCTAssertEqual("00000000-0000-0000-0000-000000000000", withAnonymisation?[kSPSessionUserId] as? String)
        XCTAssertEqual(NSNull(), withAnonymisation?[kSPSessionPreviousId] as? NSNull)
    }

    // Service methods

    func cleanFile(withNamespace namespace: String) {
        _ = DataPersistence.remove(withNamespace: namespace)
    }

    // Migration methods

    func storeAsV3_0(withNamespace namespace: String, eventId: String?, sessionId: String?, sessionIndex: Int, userId: String?) {
        let dataPersistence = DataPersistence.getFor(namespace: namespace)
        var newSessionDict: [String : Any] = [:]
        newSessionDict[kSPSessionFirstEventId] = eventId
        newSessionDict[kSPSessionId] = sessionId
        newSessionDict[kSPSessionIndex] = sessionIndex
        dataPersistence?.session = newSessionDict

        //Store userId
        let userDefaults = UserDefaults.standard
        userDefaults.set(userId, forKey: kSPInstallationUserId)
    }
    
    private func track(_ event: Event, _ tracker: Tracker) {
        InternalQueue.sync {
            _ = tracker.track(event)
        }
    }
}
