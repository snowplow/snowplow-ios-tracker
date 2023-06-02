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

// MARK: - MockState

class MockState: NSObject, State {
    var value = 0

    required init(value: Int) {
        super.init()
        self.value = value
    }
}

// MARK: - MockStateMachine

class MockStateMachine: StateMachineProtocol {
    var identifier: String
    
    init(_ identifier: String = "MockStateMachine") {
        self.identifier = identifier
    }
    
    var subscribedEventSchemasForTransitions: [String] {
        return ["inc", "dec"]
    }

    func transition(from event: Event, state currentState: State?) -> State? {
        let e = event as? SelfDescribingAbstract
        let state = currentState as? MockState ?? MockState(value: 0)
        if e?.schema == "inc" {
            return MockState(value: state.value + 1)
        } else if e?.schema == "dec" {
            return MockState(value: state.value - 1)
        } else {
            return MockState(value: 0)
        }
    }

    var subscribedEventSchemasForEntitiesGeneration: [String] {
        return ["*"]
    }

    func entities(from event: InspectableEvent, state: State?) -> [SelfDescribingJson]? {
        let mockState = state as? MockState
        let sdj = SelfDescribingJson(schema: "entity", andDictionary: [
            "value": mockState?.value ?? 0
        ])
        return [sdj]
    }

    var subscribedEventSchemasForPayloadUpdating: [String] {
        return ["event"]
    }

    func payloadValues(from event: InspectableEvent, state: State?) -> [String : Any]? {
        return [
            "newParam": "value"
        ]
    }

    var subscribedEventSchemasForAfterTrackCallback: [String] {
        return []
    }

    func afterTrack(event: SnowplowTracker.InspectableEvent) {
    }
    
    var subscribedEventSchemasForFiltering: [String] {
        return ["s1"]
    }
    
    func filter(event: InspectableEvent, state: State?) -> Bool? {
        return false
    }
}

class MockStateMachine1: MockStateMachine {
    override init(_ identifier: String = "MockStateMachine1") {
        super.init(identifier)
    }
}

class MockStateMachine2: MockStateMachine {
    override init(_ identifier: String = "MockStateMachine2") {
        super.init(identifier)
    }
}

// MARK: - Test

class TestStateManager: XCTestCase {
    func testStateManager() {
        let stateManager = StateManager()
        let stateMachine = MockStateMachine()
        stateManager.addOrReplaceStateMachine(MockStateMachine())

        let eventInc = SelfDescribing(schema: "inc", payload: [
            "value": 1
        ])
        let eventDec = SelfDescribing(schema: "dec", payload: [
            "value": 2
        ])
        let event = SelfDescribing(schema: "event", payload: [
            "value": 3
        ])

        var trackerState = stateManager.trackerState(forProcessedEvent: eventInc)
        let mockState = trackerState?.state(withStateMachine: stateMachine) as? MockState
        XCTAssertEqual(1, mockState?.value)
        var e = TrackerEvent(event: eventInc, state: trackerState)
        var entities = stateManager.entities(forProcessedEvent: e)
        XCTAssertEqual(1, ((entities[0].data) as? [String : Int])?["value"])
        XCTAssertTrue(stateManager.addPayloadValues(to: e))
        XCTAssertNil((e.payload)["newParam"])

        trackerState = stateManager.trackerState(forProcessedEvent: eventInc)
        XCTAssertEqual(2, (trackerState?.state(withStateMachine: stateMachine) as? MockState)?.value)
        e = TrackerEvent(event: eventInc, state: trackerState)
        entities = stateManager.entities(forProcessedEvent: e)
        XCTAssertEqual(2, ((entities[0].data) as? [String : Int])?["value"])
        XCTAssertTrue(stateManager.addPayloadValues(to: e))
        XCTAssertNil((e.payload)["newParam"])

        trackerState = stateManager.trackerState(forProcessedEvent: eventDec)
        XCTAssertEqual(1, (trackerState?.state(withStateMachine: stateMachine) as? MockState)?.value)
        e = TrackerEvent(event: eventDec, state: trackerState)
        entities = stateManager.entities(forProcessedEvent: e)
        XCTAssertEqual(1, ((entities[0].data) as? [String : Int])?["value"])
        XCTAssertTrue(stateManager.addPayloadValues(to: e))
        XCTAssertNil((e.payload)["newParam"])

        trackerState = stateManager.trackerState(forProcessedEvent: event)
        XCTAssertEqual(1, (trackerState?.state(withStateMachine: stateMachine) as? MockState)?.value)
        e = TrackerEvent(event: event, state: trackerState)
        entities = stateManager.entities(forProcessedEvent: e)
        XCTAssertEqual(1, ((entities[0].data) as? [String : Int])?["value"])
        XCTAssertTrue(stateManager.addPayloadValues(to: e))
        XCTAssertEqual("value", (e.payload)["newParam"] as? String)
    }

    func testAddRemoveStateMachine() {
        let stateManager = StateManager()
        let stateMachine = MockStateMachine("identifier")
        stateManager.addOrReplaceStateMachine(stateMachine)
        _ = stateManager.removeStateMachine("identifier")

        let eventInc = SelfDescribing(schema: "inc", payload: [
            "value": 1
        ])

        let trackerState = stateManager.trackerState(forProcessedEvent: eventInc)
        let mockState = trackerState?.state(withIdentifier: "identifier") as? MockState
        XCTAssertNil(mockState)
        let e = TrackerEvent(event: eventInc, state: trackerState)
        let entities = stateManager.entities(forProcessedEvent: e)
        XCTAssertEqual(0, entities.count)
    }

    func testAllowsMultipleStateMachines() {
        let stateManager = StateManager()
        stateManager.addOrReplaceStateMachine(MockStateMachine1())
        stateManager.addOrReplaceStateMachine(MockStateMachine2())

        let eventInc = SelfDescribing(schema: "inc", payload: [
            "value": 1
        ])

        let trackerState = stateManager.trackerState(forProcessedEvent: eventInc)
        let e = TrackerEvent(event: eventInc, state: trackerState)
        let entities = stateManager.entities(forProcessedEvent: e)
        XCTAssertEqual(2, entities.count)
    }

    func testDoesntDuplicateStateFromStateMachinesWithSameId() {
        let stateManager = StateManager()
        stateManager.addOrReplaceStateMachine(MockStateMachine())
        stateManager.addOrReplaceStateMachine(MockStateMachine())

        let eventInc = SelfDescribing(schema: "inc", payload: [
            "value": 1
        ])

        let trackerState = stateManager.trackerState(forProcessedEvent: eventInc)
        let e = TrackerEvent(event: eventInc, state: trackerState)
        let entities = stateManager.entities(forProcessedEvent: e)
        XCTAssertEqual(1, entities.count)
    }

    func testReplacingStateMachineDoesntResetTrackerState() {
        let stateManager = StateManager()
        stateManager.addOrReplaceStateMachine(MockStateMachine("identifier"))
        let trackerState1 = stateManager.trackerState(forProcessedEvent: SelfDescribing(schema: "inc", payload: [
            "value": 1
        ]))
        XCTAssertEqual(1, (trackerState1?.state(withIdentifier: "identifier") as? MockState)?.value)

        stateManager.addOrReplaceStateMachine(MockStateMachine())
        let trackerState2 = stateManager.trackerState(forProcessedEvent: Structured(category: "category", action: "action"))
        XCTAssertEqual(1, (trackerState2?.state(withIdentifier: "identifier") as? MockState)?.value)
    }

    func testReplacingStateMachineWithDifferentOneResetsTrackerState() {
        let stateManager = StateManager()
        stateManager.addOrReplaceStateMachine(MockStateMachine1("identifier"))
        let trackerState1 = stateManager.trackerState(forProcessedEvent: SelfDescribing(schema: "inc", payload: [
            "value": 1
        ]))
        XCTAssertEqual(1, (trackerState1?.state(withIdentifier: "identifier") as? MockState)?.value)

        stateManager.addOrReplaceStateMachine(MockStateMachine2("identifier"))
        let trackerState2 = stateManager.trackerState(forProcessedEvent: Structured(category: "category", action: "action"))
        XCTAssertNil(trackerState2?.state(withIdentifier: "identifier"))
    }
    
    func testFilterReturnsSettingOfStateMachine() {
        let stateManager = StateManager()
        stateManager.addOrReplaceStateMachine(MockStateMachine1("identifier"))
        
        
        XCTAssertFalse(
            stateManager.filter(
                event: TrackerEvent(event: SelfDescribing(schema: "s1", payload: [:]))
            )
        )

        XCTAssertTrue(
            stateManager.filter(
                event: TrackerEvent(event: SelfDescribing(schema: "s2", payload: [:]))
            )
        )
    }
}
