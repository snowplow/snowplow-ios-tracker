//
//  TestSchemaRuleset.m
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
#import "Snowplow.h"
#import "SPSchemaRule.h"
#import "SPSchemaRuleset.h"

@interface TestSchemaRuleset : XCTestCase

@end

@implementation TestSchemaRuleset

- (void)testSchemaRules {
    SPSchemaRule *twoPartVendor = [[SPSchemaRule alloc] initWithRule:@"iglu:com.acme/*/jsonschema/*-*-*"];
    XCTAssertNotNil(twoPartVendor);
    
    // version and event wildcard
    XCTAssertTrue([twoPartVendor matchWithUri:@"iglu:com.acme/event/jsonschema/1-0-0"]);
    XCTAssertFalse([twoPartVendor matchWithUri:@"iglu:com.snowplow/event/jsonschema/1-0-0"]);
    SPSchemaRule *equalRule = [[SPSchemaRule alloc] initWithRule:@"iglu:com.acme/*/jsonschema/*-*-*"];
    XCTAssertEqualObjects(twoPartVendor, equalRule);
    
    SPSchemaRule *threePartVendor = [[SPSchemaRule alloc] initWithRule:@"iglu:com.acme.marketing/*/jsonschema/*-*-*"];
    XCTAssertNotNil(threePartVendor);
    
    SPSchemaRule *validVendorWildcard = [[SPSchemaRule alloc] initWithRule:@"iglu:com.acme.*/*/jsonschema/*-*-*"];
    XCTAssertNotNil(validVendorWildcard);
    
    SPSchemaRule *invalidVendorWildcard = [[SPSchemaRule alloc] initWithRule:@"iglu:com.acme.*.whoops/*/jsonschema/*-*-*"];
    XCTAssertNil(invalidVendorWildcard);
    
    // vendor matching
    XCTAssertTrue([validVendorWildcard matchWithUri:@"iglu:com.acme.marketing/event/jsonschema/1-0-0"]);
    XCTAssertFalse([validVendorWildcard matchWithUri:@"iglu:com.snowplow/event/jsonschema/1-0-0"]);
    
    // vendor parts need to match in length, i.e. com.acme.* will not match com.acme.marketing.foo, only vendors of the form com.acme.x
    XCTAssertFalse([validVendorWildcard matchWithUri:@"iglu:com.acme.marketing.foo/event/jsonschema/1-0-0"]);
}

- (void)testSchemaRuleset {
    NSString *acme = @"iglu:com.acme.*/*/jsonschema/*-*-*";
    NSString *snowplow = @"iglu:com.snowplow.*/*/jsonschema/*-*-*";
    NSString *snowplowTest = @"iglu:com.snowplow.test/*/jsonschema/*-*-*";
    SPSchemaRuleset *ruleset = [SPSchemaRuleset rulesetWithAllowedList:@[acme, snowplow] andDeniedList:@[snowplowTest]];
    NSArray<NSString *> *allowed = @[acme, snowplow];
    XCTAssertEqualObjects(ruleset.allowed, allowed);
    NSArray<NSString *> *denied = @[snowplowTest];
    XCTAssertEqualObjects(ruleset.denied, denied);
    
    // matching
    XCTAssertTrue([ruleset matchWithUri:@"iglu:com.acme.marketing/event/jsonschema/1-0-0"]);
    XCTAssertTrue([ruleset matchWithUri:@"iglu:com.snowplow.marketing/event/jsonschema/1-0-0"]);
    XCTAssertFalse([ruleset matchWithUri:@"iglu:com.snowplow.test/event/jsonschema/1-0-0"]);
    XCTAssertFalse([ruleset matchWithUri:@"iglu:com.brand/event/jsonschema/1-0-0"]);
}

- (void)testSchemaRulesetOnlyDenied {
    NSString *snowplowTest = @"iglu:com.snowplow.test/*/jsonschema/*-*-*";
    SPSchemaRuleset *ruleset = [SPSchemaRuleset rulesetWithDeniedList:@[snowplowTest]];
    NSArray<NSString *> *allowed = @[];
    XCTAssertEqualObjects(ruleset.allowed, allowed);
    NSArray<NSString *> *denied = @[snowplowTest];
    XCTAssertEqualObjects(ruleset.denied, denied);
    
    // matching
    XCTAssertTrue([ruleset matchWithUri:@"iglu:com.acme.marketing/event/jsonschema/1-0-0"]);
    XCTAssertTrue([ruleset matchWithUri:@"iglu:com.snowplow.marketing/event/jsonschema/1-0-0"]);
    XCTAssertFalse([ruleset matchWithUri:@"iglu:com.snowplow.test/event/jsonschema/1-0-0"]);
    XCTAssertTrue([ruleset matchWithUri:@"iglu:com.brand/event/jsonschema/1-0-0"]);
}

- (void)testSchemaRulesetOnlyAllowed {
    NSString *acme = @"iglu:com.acme.*/*/jsonschema/*-*-*";
    NSString *snowplow = @"iglu:com.snowplow.*/*/jsonschema/*-*-*";
    SPSchemaRuleset *ruleset = [SPSchemaRuleset rulesetWithAllowedList:@[acme, snowplow]];
    NSArray<NSString *> *allowed = @[acme, snowplow];
    XCTAssertEqualObjects(ruleset.allowed, allowed);
    NSArray<NSString *> *denied = @[];
    XCTAssertEqualObjects(ruleset.denied, denied);
    
    // matching
    XCTAssertTrue([ruleset matchWithUri:@"iglu:com.acme.marketing/event/jsonschema/1-0-0"]);
    XCTAssertTrue([ruleset matchWithUri:@"iglu:com.snowplow.marketing/event/jsonschema/1-0-0"]);
    XCTAssertTrue([ruleset matchWithUri:@"iglu:com.snowplow.test/event/jsonschema/1-0-0"]);
    XCTAssertFalse([ruleset matchWithUri:@"iglu:com.brand/event/jsonschema/1-0-0"]);
}

@end
