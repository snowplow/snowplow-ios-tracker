//
//  TestContextFilter.m
//  Snowplow-iOSTests
//
//  Created by Michael Hadam on 6/17/19.
//  Copyright © 2019 Snowplow Analytics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
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

@interface TestContextFilter : XCTestCase

@property (readonly) SNOWGlobalContexts * globalContexts;

@end

@implementation TestContextFilter

- (void)setUp {
    [super setUp];
    _globalContexts = [[SNOWGlobalContexts alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testFilterContext {
    SPSelfDescribingJson * contextSdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme/context/jsonschema/1-0-0"
                                                                             andData:@{@"test": @5}];
    SNOWContextFilter * filter = [[SNOWContextFilter alloc] initWithFilter:^bool(SPPayload *event, NSString *eventType, NSString *eventSchema) {
        NSLog(@"schema: %@ type: %@ dict: %@", eventSchema, eventType, event);
        return [eventSchema isEqualToString:@"iglu:com.acme/event/jsonschema/1-0-0"];
    }];
    SNOWContext * context = [[SNOWContext alloc] initWithFilter:filter andContext:contextSdj];
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
    XCTAssertEqual([[self.globalContexts evaluateWithPayload:payload] count], 1);
}

@end
