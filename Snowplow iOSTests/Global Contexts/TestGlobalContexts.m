//
//  TestGlobalContexts.m
//  Snowplow-iOSTests
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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

#import <XCTest/XCTest.h>
#import "SPTracker.h"
#import "SPTrackerEvent.h"
#import "SPSelfDescribingJson.h"

/// Category needed to make the private methods testable.
@interface SPTracker (Testing)
- (void)addGlobalContextsToContexts:(NSMutableArray<SPSelfDescribingJson *> *)contexts event:(id<SPInspectableEvent>)event;
@end

#pragma mark - GlobalContextGenerator

@interface GlobalContextGenerator: NSObject <SPContextGenerator>
@end

@implementation GlobalContextGenerator

- (BOOL)filterFromEvent:(id<SPInspectableEvent>)event {
    return [@"StringToMatch" isEqualToString:(NSString *)event.payload[kSPStuctCategory]];
}

- (NSArray<SPSelfDescribingJson *> *)generatorFromEvent:(id<SPInspectableEvent>)event {
    return @[
        [[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}],
    ];
}

@end

#pragma mark - TestGlobalContexts

@interface TestGlobalContexts : XCTestCase
@end

@implementation TestGlobalContexts

- (void)testGlobalContexts {
    SPGlobalContext *staticGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]]];
    SPGlobalContext *generatorGC = [[SPGlobalContext alloc] initWithContextGenerator:[GlobalContextGenerator new]];
    SPGlobalContext *blockGC = [[SPGlobalContext alloc] initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return @[
            [[SPSelfDescribingJson alloc] initWithSchema:@"schemaBlock" andData:@{@"key": @"value"}],
        ];
    }];
    SPTracker *tracker = [self getTrackerWithGlobalContextGenerators:@{
        @"static": staticGC,
        @"generator": generatorGC,
        @"block": blockGC,
    }.mutableCopy];
    
    NSSet *result = [NSSet setWithArray:tracker.globalContextTags];
    NSSet *expected = [NSSet setWithArray:@[@"static", @"generator", @"block"]];
    XCTAssertEqualObjects(result, expected);
    
    // Can't remove a not existing tag
    SPGlobalContext *removedGC = [tracker removeGlobalContext:@"notExistingTag"];
    XCTAssertNil(removedGC);
    result = [NSSet setWithArray:tracker.globalContextTags];
    expected = [NSSet setWithArray:@[@"static", @"generator", @"block"]];
    XCTAssertTrue([result isEqualToSet:expected]);
    
    // Remove an existing tag
    removedGC = [tracker removeGlobalContext:@"static"];
    XCTAssertNotNil(removedGC);
    result = [NSSet setWithArray:tracker.globalContextTags];
    expected = [NSSet setWithArray:@[@"generator", @"block"]];
    XCTAssertTrue([result isEqualToSet:expected]);
    
    // Add a not existing tag
    XCTAssertTrue([tracker addGlobalContext:staticGC tag:@"static"]);
    result = [NSSet setWithArray:tracker.globalContextTags];
    expected = [NSSet setWithArray:@[@"generator", @"block", @"static"]];
    XCTAssertTrue([result isEqualToSet:expected]);
    
    // Can't add an existing tag
    XCTAssertFalse([tracker addGlobalContext:staticGC tag:@"static"]);
    result = [NSSet setWithArray:tracker.globalContextTags];
    expected = [NSSet setWithArray:@[@"generator", @"block", @"static"]];
    XCTAssertTrue([result isEqualToSet:expected]);
}

- (void)testAddRemoveGlobalContexts {
    SPGlobalContext *staticGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]]];
    SPTracker *tracker = [self getTrackerWithGlobalContextGenerators:nil];

    NSSet *result = [NSSet setWithArray:tracker.globalContextTags];
    NSSet *expected = [NSSet setWithArray:@[]];
    XCTAssertTrue([result isEqualToSet:expected]);
    
    // Can't remove a not existing tag
    SPGlobalContext *removedGC = [tracker removeGlobalContext:@"notExistingTag"];
    XCTAssertNil(removedGC);
    
    // Add a not existing tag
    XCTAssertTrue([tracker addGlobalContext:staticGC tag:@"static"]);
    result = [NSSet setWithArray:tracker.globalContextTags];
    expected = [NSSet setWithArray:@[@"static"]];
    XCTAssertTrue([result isEqualToSet:expected]);
    
    // Remove an existing tag
    removedGC = [tracker removeGlobalContext:@"static"];
    XCTAssertNotNil(removedGC);
    result = [NSSet setWithArray:tracker.globalContextTags];
    expected = [NSSet setWithArray:@[]];
    XCTAssertTrue([result isEqualToSet:expected]);
}

- (void)testStaticGenerator {
    SPGlobalContext *staticGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]]];
    SPTracker *tracker = [self getTrackerWithGlobalContextGenerators:@{@"static": staticGC}.mutableCopy];
    
    SPPrimitive *event = [[SPStructured alloc] initWithCategory:@"Category" action:@"Action"];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

- (void)testStaticGeneratortWithFilter {
    NSString *stringToMatch = @"StringToMatch";
    SPGlobalContext *filterMatchingGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]]
                                                                                 filter:^BOOL(id<SPInspectableEvent> event) {
        return [stringToMatch isEqualToString:(NSString *)event.payload[kSPStuctCategory]];
    }];
    SPGlobalContext *filterNotMatchingGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schemaNotMatching" andData:@{@"key": @"value"}]] filter:^BOOL(id<SPInspectableEvent> event) {
        return NO;
    }];
    SPTracker *tracker = [self getTrackerWithGlobalContextGenerators:@{
        @"matching": filterMatchingGC,
        @"notMatching": filterNotMatchingGC,
    }.mutableCopy];

    SPPrimitive *event = [[SPStructured alloc] initWithCategory:stringToMatch action:@"Action"];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

- (void)testStaticGeneratorWithRuleset {
    NSString *allowed = @"iglu:com.snowplowanalytics.*/*/jsonschema/*-*-*";
    NSString *denied = @"iglu:com.snowplowanalytics.mobile/*/jsonschema/*-*-*";
    SPSchemaRuleset *ruleset = [SPSchemaRuleset rulesetWithAllowedList:@[allowed] andDeniedList:@[denied]];
    
    SPGlobalContext *rulesetGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]] ruleset:ruleset];
    SPTracker *tracker = [self getTrackerWithGlobalContextGenerators:@{@"ruleset": rulesetGC}.mutableCopy];

    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];

    // Not matching primitive event
    SPPrimitive *primitiveEvent = [[SPStructured alloc] initWithCategory:@"Category" action:@"Action"];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:primitiveEvent];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 0);

    // Not matching self-describing event with mobile schema
    SPSelfDescribing *selfDescribingEvent = [[[SPScreenView alloc] initWithName:@"Name" screenId:nil] type:@"Type"];
    trackerEvent = [[SPTrackerEvent alloc] initWithEvent:selfDescribingEvent];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 0);

    // Matching self-describing event with general schema
    selfDescribingEvent = [[[SPTiming alloc] initWithCategory:@"Category" variable:@"Variable" timing:@123] label:@"Label"];
    trackerEvent = [[SPTrackerEvent alloc] initWithEvent:selfDescribingEvent];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

- (void)testBlockGenerator {
    SPGlobalContext *generatorGC = [[SPGlobalContext alloc] initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return @[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]];
    }];
    SPTracker *tracker = [self getTrackerWithGlobalContextGenerators:@{@"generator": generatorGC}.mutableCopy];

    SPPrimitive *event = [[SPStructured alloc] initWithCategory:@"Category" action:@"Action"];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

- (void)testContextGenerator {
    SPGlobalContext *contextGeneratorGC = [[SPGlobalContext alloc] initWithContextGenerator:[GlobalContextGenerator new]];
    SPTracker *tracker = [self getTrackerWithGlobalContextGenerators:@{@"contextGenerator": contextGeneratorGC}.mutableCopy];
    
    SPPrimitive *event = [[SPStructured alloc] initWithCategory:@"StringToMatch" action:@"Action"];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

// MARK: - Utility function

    - (SPTracker *)getTrackerWithGlobalContextGenerators:(NSMutableDictionary<NSString *,SPGlobalContext *> *)generators {
        SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithEndpoint:@"com.acme.fake"
                                                                                        protocol:SPProtocolHttps
                                                                                          method:SPRequestOptionsPost];
        SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"aNamespace" appId:@"anAppId"];
        trackerConfig.platformContext = YES;
        trackerConfig.geoLocationContext = NO;
        trackerConfig.base64Encoding = NO;
        trackerConfig.sessionContext = YES;
        SPGlobalContextsConfiguration *gcConfig = [[SPGlobalContextsConfiguration alloc] init];
        gcConfig.contextGenerators = generators;
        SPServiceProvider *serviceProvider = [[SPServiceProvider alloc] initWithNetwork:networkConfig
                                                                                tracker:trackerConfig
                                                                         configurations:@[gcConfig]];
        return serviceProvider.tracker;
    }

@end
