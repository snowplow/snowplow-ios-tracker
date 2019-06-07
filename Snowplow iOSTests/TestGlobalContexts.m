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


@interface TestGlobalContexts : XCTestCase

@property (readonly) SNOWGlobalContexts * globalContexts;

@end

@implementation TestGlobalContexts

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

- (void) testAddGlobalContexts {
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme/event/jsonschema/1-0-0"
                                                                      andData:@{@"test": @5}];
    SNOWContext * context = [[SNOWContext alloc] initWithContext:sdj];
    XCTAssertNotNil(context);
    XCTAssertNotNil(self.globalContexts);
    [self.globalContexts addContext:context];
    XCTAssertEqual([self.globalContexts.contexts count], 1);
    [self.globalContexts addContexts:@[[context copy], [context copy], context]];
    [[self.globalContexts.contexts objectAtIndex:0] setTag:@"test_one"];
    [[self.globalContexts.contexts objectAtIndex:1] setTag:@"test_two"];
    [[self.globalContexts.contexts objectAtIndex:2] setTag:@"test_three"];
    XCTAssertEqual([self.globalContexts.contexts count], 4);
}

- (void) testRemoveGlobalContexts {
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme/event/jsonschema/1-0-0"
                                                                      andData:@{@"test": @5}];
    SNOWContext * context = [[SNOWContext alloc] initWithContext:sdj];
    XCTAssertNotNil(context);
    XCTAssertNotNil(self.globalContexts);
    [self.globalContexts addContext:context];
    XCTAssertEqual([self.globalContexts.contexts count], 1);
    [self.globalContexts addContexts:@[[context copy], [context copy], context]];
    [[self.globalContexts.contexts objectAtIndex:0] setTag:@"test_one"];
    [[self.globalContexts.contexts objectAtIndex:1] setTag:@"test_two"];
    [[self.globalContexts.contexts objectAtIndex:2] setTag:@"test_three"];
    XCTAssertEqual([self.globalContexts.contexts count], 4);
    [self.globalContexts removeContextWithTag:@"test_one"];
    XCTAssertEqual([self.globalContexts.contexts count], 3);
    [self.globalContexts removeContextWithTag:@"test_two"];
    XCTAssertEqual([self.globalContexts.contexts count], 2);
    [self.globalContexts removeContextWithTag:@"test_two"];
    XCTAssertEqual([self.globalContexts.contexts count], 2);
}

@end
