//
//  TestGlobalContexts.m
//  Snowplow-iOSTests
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@"com.acme.fake"];
    }];
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:NO];
    
    SPGlobalContext *staticGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]]];
    SPGlobalContext *generatorGC = [[SPGlobalContext alloc] initWithContextGenerator:[GlobalContextGenerator new]];
    SPGlobalContext *blockGC = [[SPGlobalContext alloc] initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return @[
            [[SPSelfDescribingJson alloc] initWithSchema:@"schemaBlock" andData:@{@"key": @"value"}],
        ];
    }];
    
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:[NSUUID UUID].UUIDString];
        [builder setGlobalContextGenerators:@{
            @"static": staticGC,
            @"generator": generatorGC,
            @"block": blockGC,
        }];
    }];
    
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

- (void)testStaticGenerator {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@"com.acme.fake"];
    }];
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:NO];
    
    SPGlobalContext *staticGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]]];
    
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setBase64Encoded:NO];
        [builder setAppId:[NSUUID UUID].UUIDString];
        [builder setGlobalContextGenerators:@{
            @"static": staticGC,
        }];
    }];
    
    SPPrimitive *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"Category"];
        [builder setAction:@"Action"];
        [builder setLabel:@"Label"];
    }];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

- (void)testStaticGeneratortWithFilter {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@"com.acme.fake"];
    }];
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:NO];
    
    NSString *stringToMatch = @"StringToMatch";
    SPGlobalContext *filterMatchingGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]]
                                                                                 filter:^BOOL(id<SPInspectableEvent> event) {
        return [stringToMatch isEqualToString:(NSString *)event.payload[kSPStuctCategory]];
    }];
    SPGlobalContext *filterNotMatchingGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schemaNotMatching" andData:@{@"key": @"value"}]]
                                                                                    filter:^BOOL(id<SPInspectableEvent> event) {
        return NO;
    }];
    
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setBase64Encoded:NO];
        [builder setAppId:[NSUUID UUID].UUIDString];
        [builder setGlobalContextGenerators:@{
            @"matching": filterMatchingGC,
            @"notMatching": filterNotMatchingGC,
        }];
    }];
    
    SPPrimitive *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:stringToMatch];
        [builder setAction:@"Action"];
        [builder setLabel:@"Label"];
    }];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

- (void)testStaticGeneratorWithRuleset {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@"com.acme.fake"];
    }];
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:NO];
    
    NSString *allowed = @"iglu:com.snowplowanalytics.*/*/jsonschema/*-*-*";
    NSString *denied = @"iglu:com.snowplowanalytics.mobile/*/jsonschema/*-*-*";
    SPSchemaRuleset *ruleset = [SPSchemaRuleset rulesetWithAllowedList:@[allowed] andDeniedList:@[denied]];
    
    SPGlobalContext *rulesetGC = [[SPGlobalContext alloc] initWithStaticContexts:@[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]]
                                                                                 ruleset:ruleset];
    
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setBase64Encoded:NO];
        [builder setAppId:[NSUUID UUID].UUIDString];
        [builder setGlobalContextGenerators:@{
            @"ruleset": rulesetGC,
        }];
    }];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];

    // Not matching primitive event
    SPPrimitive *primitiveEvent = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"Category"];
        [builder setAction:@"Action"];
        [builder setLabel:@"Label"];
    }];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:primitiveEvent];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 0);

    // Not matching self-describing event with mobile schema
    SPSelfDescribing *selfDescribingEvent = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"Name"];
        [builder setType:@"Type"];
    }];
    trackerEvent = [[SPTrackerEvent alloc] initWithEvent:selfDescribingEvent];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 0);

    // Matching self-describing event with general schema
    selfDescribingEvent = [SPTiming build:^(id<SPTimingBuilder>  _Nonnull builder) {
        [builder setTiming:123];
        [builder setLabel:@"Label"];
        [builder setCategory:@"Category"];
        [builder setVariable:@"Variable"];
    }];
    trackerEvent = [[SPTrackerEvent alloc] initWithEvent:selfDescribingEvent];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

- (void)testBlockGenerator {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@"com.acme.fake"];
    }];
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:NO];
    
    SPGlobalContext *generatorGC = [[SPGlobalContext alloc] initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return @[[[SPSelfDescribingJson alloc] initWithSchema:@"schema" andData:@{@"key": @"value"}]];
    }];
    
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setBase64Encoded:NO];
        [builder setAppId:[NSUUID UUID].UUIDString];
        [builder setGlobalContextGenerators:@{
            @"generator": generatorGC,
        }];
    }];
    
    SPPrimitive *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"Category"];
        [builder setAction:@"Action"];
        [builder setLabel:@"Label"];
    }];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

- (void)testContextGenerator {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@"com.acme.fake"];
    }];
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:NO];
    
    SPGlobalContext *contextGeneratorGC = [[SPGlobalContext alloc] initWithContextGenerator:[GlobalContextGenerator new]];
    
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setBase64Encoded:NO];
        [builder setAppId:[NSUUID UUID].UUIDString];
        [builder setGlobalContextGenerators:@{
            @"contextGenerator": contextGeneratorGC,
        }];
    }];
    
    SPPrimitive *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"StringToMatch"];
        [builder setAction:@"Action"];
        [builder setLabel:@"Label"];
    }];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    
    NSMutableArray<SPSelfDescribingJson *> *contexts = [NSMutableArray array];
    [tracker addGlobalContextsToContexts:contexts event:trackerEvent];
    XCTAssertTrue(contexts.count == 1);
    XCTAssertEqual(contexts[0].schema, @"schema");
}

@end
