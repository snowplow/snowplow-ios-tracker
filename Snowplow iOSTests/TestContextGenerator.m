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
#import "SPSelfDescribingJson.h"
#import "SPPayload.h"
#import "SPEvent.h"
#import "SNOWContextFilter.h"
#import "SNOWSchemaRuleset.h"
#import "SNOWSchemaRule.h"
#import "SNOWContextGenerator.h"


@interface TestContextGenerator : XCTestCase

@property (readonly) SNOWGlobalContexts * globalContexts;

@end

@implementation TestContextGenerator

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

- (void) testContextGenerator {
    SPSelfDescribingJson * expected = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme/event/jsonschema/1-0-0"
                                                                           andData:@{
                                                                                     @"someData": @42
                                                                                     }];
    SNOWContextGenerator * generator = [[SNOWContextGenerator alloc] initWithBlock:^NSArray<SPSelfDescribingJson *> *(SPPayload *event, NSString *eventType, NSString *eventSchema) {
        SPSelfDescribingJson * result = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme/event/jsonschema/1-0-0"
                                                                             andData:@{
                                                                                       @"someData": @42
                                                                                       }];
        return [NSArray arrayWithObjects:result, nil];
    }];
    [_globalContexts addContext:[[SNOWContext alloc] initWithGenerator:generator]];

    // make an event
    SPSelfDescribingJson * eventSdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme/event/jsonschema/1-0-0"
                                                                           andData:@{@"test": @1}];
    SPUnstructured * event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:eventSdj];
    }];
    SPPayload * payload = [event getPayloadWithEncoding:false];
    XCTAssertEqualObjects(@[expected], [_globalContexts evaluateWithPayload:payload]);
}

@end
