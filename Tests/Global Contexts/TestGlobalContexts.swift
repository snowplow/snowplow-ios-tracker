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

        let generators = [
            "static": staticGC,
            "generator": generatorGC,
            "block": blockGC
        ]
        let tracker = createTracker(generators: generators) { _ in
        }
        guard let controller = tracker?.globalContexts else { XCTFail(); return }

        var result = Set<String>(controller.tags)
        var expected = Set<String>(["static", "generator", "block"])
        XCTAssertEqual(result, expected)

        // Can't remove a not existing tag
        var removedGC = controller.remove(tag: "notExistingTag")
        XCTAssertNil(removedGC)
        result = Set<String>(controller.tags)
        expected = Set<String>(["static", "generator", "block"])
        XCTAssertTrue(result == expected)

        // Remove an existing tag
        removedGC = controller.remove(tag: "static")
        XCTAssertNotNil(removedGC)
        result = Set<String>(controller.tags)
        expected = Set<String>(["generator", "block"])
        XCTAssertTrue(result == expected)

        // Add a not existing tag
        XCTAssertTrue(controller.add(tag: "static", contextGenerator: staticGC))
        result = Set<String>(controller.tags)
        expected = Set<String>(["generator", "block", "static"])
        XCTAssertTrue(result == expected)

        // Can't add an existing tag
        XCTAssertFalse(controller.add(tag: "static", contextGenerator: staticGC))
        result = Set<String>(controller.tags)
        expected = Set<String>(["generator", "block", "static"])
        XCTAssertTrue(result == expected)
    }

    func testAddRemove() {
        let staticGC = GlobalContext(staticContexts: [
            SelfDescribingJson(schema: "schema", andDictionary: [
                "key": "value"
            ])
        ])
        let tracker = createTracker(generators: [:]) { _ in
        }
        guard let controller = tracker?.globalContexts else { XCTFail(); return }

        var result = Set<String>(controller.tags)
        var expected = Set<String>([])
        XCTAssertTrue(result == expected)

        // Can't remove a not existing tag
        var removedGC = controller.remove(tag: "notExistingTag")
        XCTAssertNil(removedGC)

        // Add a not existing tag
        XCTAssertTrue(controller.add(tag: "static", contextGenerator: staticGC))
        result = Set<String>(controller.tags)
        expected = Set<String>(["static"])
        XCTAssertTrue(result == expected)

        // Remove an existing tag
        removedGC = controller.remove(tag: "static")
        XCTAssertNotNil(removedGC)
        result = Set<String>(controller.tags)
        expected = Set<String>([])
        XCTAssertTrue(result == expected)
    }

    func testStaticGenerator() {
        let staticGC = GlobalContext(staticContexts: [
            SelfDescribingJson(schema: "schema", andDictionary: [
                "key": "value"
            ])
        ])
        let globalContexts = [
            "static": staticGC
        ]
        let expectation = expectation(description: "Received event")
        let tracker = createTracker(generators: globalContexts) { event in
            XCTAssertTrue(event.entities.count == 1)
            XCTAssertEqual(event.entities[0].schema, "schema")
            expectation.fulfill()
        }

        let event = Structured(category: "Category", action: "Action")
        _ = tracker?.track(event)

        wait(for: [expectation], timeout: 1)
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
        let globalContexts = [
            "matching": filterMatchingGC,
            "notMatching": filterNotMatchingGC
        ]
        let expectation = expectation(description: "Received event")
        let tracker = createTracker(generators: globalContexts) { event in
            XCTAssertTrue(event.entities.count == 1)
            XCTAssertEqual(event.entities[0].schema, "schema")
            expectation.fulfill()
        }

        let event = Structured(category: stringToMatch, action: "Action")
        _ = tracker?.track(event)

        wait(for: [expectation], timeout: 1)
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
        let globalContexts = [
            "ruleset": rulesetGC
        ]
        let expectation = expectation(description: "Received events")
        var receivedEvents: [InspectableEvent] = []
        let tracker = createTracker(generators: globalContexts) { event in
            receivedEvents.append(event)
            if receivedEvents.count == 3 {
                expectation.fulfill()
            }
        }

        // Not matching primitive event
        let primitiveEvent = Structured(category: "Category", action: "Action")
        _ = tracker?.track(primitiveEvent)

        // Not matching self-describing event with mobile schema
        let screenView = ScreenView(name: "Name", screenId: nil)
        screenView.type = "Type"
        _ = tracker?.track(screenView)

        // Matching self-describing event with general schema
        let timing = Timing(category: "Category", variable: "Variable", timing: 123)
        timing.label = "Label"
        _ = tracker?.track(timing)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(receivedEvents[0].entities.count == 0)
        XCTAssertTrue(receivedEvents[1].entities.count == 0)
        XCTAssertTrue(receivedEvents[2].entities.count == 1)
        XCTAssertEqual(receivedEvents[2].entities[0].schema, "schema")
    }

    func testBlockGenerator() {
        let generators = [
            "generator": GlobalContext(generator: { event in
                return [
                    SelfDescribingJson(schema: "schema", andDictionary: [
                        "key": "value"
                    ])
                ]
            })
        ]
        let expectation = expectation(description: "Received event")
        let tracker = createTracker(generators: generators) { event in
            XCTAssertTrue(event.entities.count == 1)
            XCTAssertEqual(event.entities[0].schema, "schema")
            expectation.fulfill()
        }

        let event = Structured(category: "Category", action: "Action")
        _ = tracker?.track(event)

        wait(for: [expectation], timeout: 1)
    }

    func testContextGenerator() {
        let contextGeneratorGC = GlobalContext(contextGenerator: GlobalContextGenerator())
        let generators = [
            "contextGenerator": contextGeneratorGC
        ]
        let expectation = expectation(description: "Received event")
        let tracker = createTracker(generators: generators) { event in
            XCTAssertTrue(event.entities.count == 1)
            XCTAssertEqual(event.entities[0].schema, "schema")
            expectation.fulfill()
        }

        let event = Structured(category: "StringToMatch", action: "Action")
        _ = tracker?.track(event)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Utility function

    private func createTracker(generators: [String : GlobalContext], afterTrack: @escaping (InspectableEvent) -> ()) -> TrackerController? {
        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = "anAppId"
        trackerConfig.platformContext = false
        trackerConfig.geoLocationContext = false
        trackerConfig.base64Encoding = false
        trackerConfig.sessionContext = false
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        trackerConfig.applicationContext = false
        trackerConfig.screenContext = false
        
        let gcConfig = GlobalContextsConfiguration()
        gcConfig.contextGenerators = generators
        
        let networkConfig = NetworkConfiguration(networkConnection: MockNetworkConnection(requestOption: .post, statusCode: 200))
        
        let namespace = "testGlobalContexts" + UUID().uuidString

        return Snowplow.createTracker(
            namespace: namespace,
            network: networkConfig,
            configurations: [
                EventSink(callback: afterTrack),
                trackerConfig,
                gcConfig
            ])
    }
}
