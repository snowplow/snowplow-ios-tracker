//
//  TestGlobalContexts.m
//  Snowplow-iOS
//
//  Created by Michael Hadam on 6/10/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SPTracker.h"
#import "SPEmitter.h"
#import "Snowplow.h"
#import "SNOWGlobalContexts.h"
#import "SNOWContext.h"
#import "SPSelfDescribingJSON.h"
#import "SPPayload.h"
#import "SPEvent.h"
#import "SNOWContextFilter.h"
#import "SNOWSchemaRuleset.h"
#import "SNOWSchemaRule.h"
#import "SNOWContextGenerator.h"


@interface TestSchemaRuleset : XCTestCase

@property (readonly) SNOWGlobalContexts * globalContexts;

@end

@implementation TestSchemaRuleset

// Class method that's run once before all the unit tests
+ (void)setUp {
    [super setUp];
}

// Instance method run before each unit test
- (void)setUp {
    [super setUp];
    _globalContexts = [[SNOWGlobalContexts alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testSchemaRules {
    SNOWSchemaRule * twoPartVendor = [[SNOWSchemaRule alloc] initWithRule:@"iglu:com.acme/*/jsonschema/*-*-*"];
    XCTAssertNotNil(twoPartVendor);
    // version and event wildcard
    XCTAssertTrue([twoPartVendor match:@"iglu:com.acme/event/jsonschema/1-0-0"]);
    XCTAssertFalse([twoPartVendor match:@"iglu:com.snowplow/event/jsonschema/1-0-0"]);
    SNOWSchemaRule * equalRule = [[SNOWSchemaRule alloc] initWithRule:@"iglu:com.acme/*/jsonschema/*-*-*"];
    XCTAssertEqualObjects(twoPartVendor, equalRule);

    SNOWSchemaRule * threePartVendor = [[SNOWSchemaRule alloc] initWithRule:@"iglu:com.acme.marketing/*/jsonschema/*-*-*"];
    XCTAssertNotNil(threePartVendor);

    SNOWSchemaRule * validVendorWildcard = [[SNOWSchemaRule alloc] initWithRule:@"iglu:com.acme.*/*/jsonschema/*-*-*"];
    XCTAssertNotNil(validVendorWildcard);

    SNOWSchemaRule * invalidVendorWildcard = [[SNOWSchemaRule alloc] initWithRule:@"iglu:com.acme.*.whoops/*/jsonschema/*-*-*"];
    XCTAssertNil(invalidVendorWildcard);
    NSArray * expected = @[@"com.acme", @"event", @"jsonschema", @"1", @"0", @"0"];
    XCTAssertEqualObjects([SNOWSchemaRule getPartsFromURI:@"iglu:com.acme/event/jsonschema/1-0-0"], expected);

    // vendor matching
    XCTAssertTrue([validVendorWildcard match:@"iglu:com.acme.marketing/event/jsonschema/1-0-0"]);
    XCTAssertFalse([validVendorWildcard match:@"iglu:com.snowplow/event/jsonschema/1-0-0"]);
    // vendor parts need to match in length, i.e. com.acme.* will not match com.acme.marketing.foo, only vendors of the form com.acme.x
    XCTAssertFalse([validVendorWildcard match:@"iglu:com.acme.marketing.foo/event/jsonschema/1-0-0"]);
}

- (void) testSchemaRuleset {
    SNOWSchemaRuleset * ruleset = [[SNOWSchemaRuleset alloc] initWithAllowList:@[@"iglu:com.acme/*/jsonschema/*-*-*"]];
    XCTAssertNotNil(ruleset);
    SNOWSchemaRule * rule = [[SNOWSchemaRule alloc] initWithRule:@"iglu:com.acme/*/jsonschema/*-*-*"];
    XCTAssertEqualObjects(ruleset.allow, @[rule]);
}

- (void) testRulesetContext {
    // test event that should match accept ruleset
    SPSelfDescribingJson * contextSdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme/context/jsonschema/1-0-0"
                                                                             andData:@{@"test": @5}];
    SNOWSchemaRuleset * ruleset = [[SNOWSchemaRuleset alloc] initWithAllowList:@[@"iglu:com.acme/*/jsonschema/*-*-*"]];
    XCTAssertNotNil(ruleset);
    SNOWContext * context = [[SNOWContext alloc] initWithRuleset:ruleset andContext:contextSdj];
    XCTAssertNotNil(context);
    XCTAssertNotNil(self.globalContexts);
    [self.globalContexts addContext:context];
    XCTAssertEqual([self.globalContexts.contexts count], 1);
    // context added, now evaluate against a matching payload
    SPSelfDescribingJson * eventSdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme/event/jsonschema/1-0-0"
                                                                           andData:@{@"test": @1}];
    SPUnstructured * event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:eventSdj];
    }];
    SPPayload * payload = [event getPayloadWithEncoding:false];
    XCTAssertEqualObjects([_globalContexts evaluateWithPayload:payload], @[contextSdj]);

    // test event that shouldn't match accept ruleset
    eventSdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.snowplow/event/jsonschema/1-0-0"
                                                    andData:@{@"test": @1}];
    event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:eventSdj];
    }];
    payload = [event getPayloadWithEncoding:false];
    XCTAssertEqualObjects([self.globalContexts evaluateWithPayload:payload], @[]);
    [_globalContexts removeAllContexts];
}

@end
