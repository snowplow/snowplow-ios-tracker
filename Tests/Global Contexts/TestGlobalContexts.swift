//
//  TestGlobalContexts.swift
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
//  Authors: Alex Benini
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

import XCTest
@testable import SnowplowTracker

// MARK: - GlobalContextGenerator

class GlobalContextGenerator: NSObject, ContextGenerator {
    func filter(from event: InspectableEvent) -> Bool {
        return "StringToMatch" == event.payload[kSPStuctCategory] as? String
    }

    func generator(from event: InspectableEvent) -> [SelfDescribingJson]? {
        return [
            SelfDescribingJson(schema: "schema", andDictionary: [
                "key": "value"
            ])
        ]
    }
}

// MARK: - TestGlobalContexts

class TestGlobalContexts: XCTestCase {
    func testGlobalContexts() {
        let staticGC = GlobalContext(staticContexts: [
            SelfDescribingJson(schema: "schema", andDictionary: [
                "key": "value"
            ])
        ])
        let generatorGC = GlobalContext(contextGenerator: GlobalContextGenerator())
        let blockGC = GlobalContext(generator: { event in
            return [
                SelfDescribingJson(schema: "schemaBlock", andDictionary: [
                    "key": "value"
                ])
            ]
        })
        
        var generators = [
            "static": staticGC,
            "generator": generatorGC,
            "block": blockGC
        ]
        let tracker = getTrackerWithGlobalContextGenerators(&generators)

        var result = Set<String>(tracker.globalContextTags)
        var expected = Set<String>(["static", "generator", "block"])
        XCTAssertEqual(result, expected)

        // Can't remove a not existing tag
        var removedGC = tracker.removeGlobalContext("notExistingTag")
        XCTAssertNil(removedGC)
        result = Set<String>(tracker.globalContextTags)
        expected = Set<String>(["static", "generator", "block"])
        XCTAssertTrue(result == expected)

        // Remove an existing tag
        removedGC = tracker.removeGlobalContext("static")
        XCTAssertNotNil(removedGC)
        result = Set<String>(tracker.globalContextTags)
        expected = Set<String>(["generator", "block"])
        XCTAssertTrue(result == expected)

        // Add a not existing tag
        XCTAssertTrue(tracker.add(staticGC, tag: "static"))
        result = Set<String>(tracker.globalContextTags)
        expected = Set<String>(["generator", "block", "static"])
        XCTAssertTrue(result == expected)

        // Can't add an existing tag
        XCTAssertFalse(tracker.add(staticGC, tag: "static"))
        result = Set<String>(tracker.globalContextTags)
        expected = Set<String>(["generator", "block", "static"])
        XCTAssertTrue(result == expected)
    }

    func testAddRemove() {
        let staticGC = GlobalContext(staticContexts: [
            SelfDescribingJson(schema: "schema", andDictionary: [
                "key": "value"
            ])
        ])
        var generators: [String : GlobalContext] = [:]
        let tracker = getTrackerWithGlobalContextGenerators(&generators)

        var result = Set<String>(tracker.globalContextTags)
        var expected = Set<String>([])
        XCTAssertTrue(result == expected)

        // Can't remove a not existing tag
        var removedGC = tracker.removeGlobalContext("notExistingTag")
        XCTAssertNil(removedGC)

        // Add a not existing tag
        XCTAssertTrue(tracker.add(staticGC, tag: "static"))
        result = Set<String>(tracker.globalContextTags)
        expected = Set<String>(["static"])
        XCTAssertTrue(result == expected)

        // Remove an existing tag
        removedGC = tracker.removeGlobalContext("static")
        XCTAssertNotNil(removedGC)
        result = Set<String>(tracker.globalContextTags)
        expected = Set<String>([])
        XCTAssertTrue(result == expected)
    }

    func testStaticGenerator() {
        let staticGC = GlobalContext(staticContexts: [
            SelfDescribingJson(schema: "schema", andDictionary: [
                "key": "value"
            ])
        ])
        var globalContexts = [
            "static": staticGC
        ]
        let tracker = getTrackerWithGlobalContextGenerators(&globalContexts)

        let event = Structured(category: "Category", action: "Action")
        let trackerEvent = TrackerEvent(event: event, state: nil)

        var contexts: [SelfDescribingJson] = []
        tracker.addGlobalContexts(toContexts: &contexts, event: trackerEvent)
        XCTAssertTrue(contexts.count == 1)
        XCTAssertEqual(contexts[0].schema, "schema")
    }

    func testStaticGeneratortWithFilter() {
        let stringToMatch = "StringToMatch"
        let filterMatchingGC = GlobalContext(
            staticContexts: [
                SelfDescribingJson(schema: "schema", andDictionary: [
                    "key": "value"
                ])
            ],
            filter: { event in
                return stringToMatch == event.payload[kSPStuctCategory] as? String
            })
        let filterNotMatchingGC = GlobalContext(staticContexts: [
            SelfDescribingJson(schema: "schemaNotMatching", andDictionary: [
                "key": "value"
            ])
        ], filter: { event in
            return false
        })
        var globalContexts = [
            "matching": filterMatchingGC,
            "notMatching": filterNotMatchingGC
        ]
        let tracker = getTrackerWithGlobalContextGenerators(&globalContexts)

        let event = Structured(category: stringToMatch, action: "Action")
        let trackerEvent = TrackerEvent(event: event, state: nil)

        var contexts: [SelfDescribingJson] = []
        tracker.addGlobalContexts(toContexts: &contexts, event: trackerEvent)
        XCTAssertTrue(contexts.count == 1)
        XCTAssertEqual(contexts[0].schema, "schema")
    }

    func testStaticGeneratorWithRuleset() {
        let allowed = "iglu:com.snowplowanalytics.*/*/jsonschema/*-*-*"
        let denied = "iglu:com.snowplowanalytics.mobile/*/jsonschema/*-*-*"
        let ruleset = SchemaRuleset(allowedList: [allowed], andDeniedList: [denied])

        let rulesetGC = GlobalContext(staticContexts: [
            SelfDescribingJson(schema: "schema", andDictionary: [
                "key": "value"
            ])
        ], ruleset: ruleset)
        var globalContexts = [
            "ruleset": rulesetGC
        ]
        let tracker = getTrackerWithGlobalContextGenerators(&globalContexts)

        var contexts: [SelfDescribingJson] = []

        // Not matching primitive event
        let primitiveEvent = Structured(category: "Category", action: "Action")
        var trackerEvent = TrackerEvent(event: primitiveEvent, state: nil)
        tracker.addGlobalContexts(toContexts: &contexts, event: trackerEvent)
        XCTAssertTrue(contexts.count == 0)

        // Not matching self-describing event with mobile schema
        let screenView = ScreenView(name: "Name", screenId: nil)
        screenView.type = "Type"
        trackerEvent = TrackerEvent(event: screenView, state: nil)
        tracker.addGlobalContexts(toContexts: &contexts, event: trackerEvent)
        XCTAssertTrue(contexts.count == 0)

        // Matching self-describing event with general schema
        let timing = Timing(category: "Category", variable: "Variable", timing: 123)
        timing.label = "Label"
        trackerEvent = TrackerEvent(event: timing, state: nil)
        tracker.addGlobalContexts(toContexts: &contexts, event: trackerEvent)
        XCTAssertTrue(contexts.count == 1)
        XCTAssertEqual(contexts[0].schema, "schema")
    }

    func testBlockGenerator() {
        var generators = [
            "generator": GlobalContext(generator: { event in
                return [
                    SelfDescribingJson(schema: "schema", andDictionary: [
                        "key": "value"
                    ])
                ]
            })
        ]
        let tracker = getTrackerWithGlobalContextGenerators(&generators)

        let event = Structured(category: "Category", action: "Action")
        let trackerEvent = TrackerEvent(event: event, state: nil)

        var contexts: [SelfDescribingJson] = []
        tracker.addGlobalContexts(toContexts: &contexts, event: trackerEvent)
        XCTAssertTrue(contexts.count == 1)
        XCTAssertEqual(contexts[0].schema, "schema")
    }

    func testContextGenerator() {
        let contextGeneratorGC = GlobalContext(contextGenerator: GlobalContextGenerator())
        var generators = [
            "contextGenerator": contextGeneratorGC
        ]
        let tracker = getTrackerWithGlobalContextGenerators(&generators)

        let event = Structured(category: "StringToMatch", action: "Action")
        let trackerEvent = TrackerEvent(event: event, state: nil)

        var contexts: [SelfDescribingJson] = []
        tracker.addGlobalContexts(toContexts: &contexts, event: trackerEvent)
        XCTAssertTrue(contexts.count == 1)
        XCTAssertEqual(contexts[0].schema, "schema")
    }

    // MARK: - Utility function


    func getTrackerWithGlobalContextGenerators(_ generators: inout [String : GlobalContext]) -> Tracker {
        let networkConfig = NetworkConfiguration(
            endpoint: "https://com.acme.fake",
            method: .post)
        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "anAppId"
        trackerConfig.platformContext = true
        trackerConfig.geoLocationContext = false
        trackerConfig.base64Encoding = false
        trackerConfig.sessionContext = true
        let gcConfig = GlobalContextsConfiguration()
        gcConfig.contextGenerators = generators
        let serviceProvider = ServiceProvider(
            namespace: "aNamespace",
            network: networkConfig,
            configurations: [gcConfig])
        return serviceProvider.tracker
    }
}
