//
//  TestEvent.m
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPEvent.h"
#import "SPSelfDescribingJson.h"

@interface TestEvent : XCTestCase

@end

@implementation TestEvent

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEventBuilderConditions {
    // Valid construction
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setContexts:[self getCustomContext]];
        [builder setEventId:@"an-event-id-string"];
        [builder setTimestamp:1234567890];
    }];
    XCTAssertNotNil(event);
    XCTAssertEqualObjects([event getEventId], @"an-event-id-string");
    XCTAssertEqual([event getTimestamp], 1234567890);
    
    // Context is nil
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
            [builder setPageUrl:@"DemoPageUrl"];
            [builder setContexts:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Contexts cannot be nil.", exception.reason);
    }
    
    // Context is not SelfDescribingJson
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
            [builder setPageUrl:@"DemoPageUrl"];
            [builder setContexts:[self getBadCustomContext]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"All contexts must be SelfDescribingJson objects.", exception.reason);
    }
    
    // EventID is nil
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
            [builder setPageUrl:@"DemoPageUrl"];
            [builder setEventId:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"EventID cannot be nil or empty.", exception.reason);
    }
    
    // EventID is empty
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
            [builder setPageUrl:@"DemoPageUrl"];
            [builder setEventId:@""];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"EventID cannot be nil or empty.", exception.reason);
    }
}

- (void)testPageViewBuilderConditions {
    // Valid construction
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
    }];
    XCTAssertNotNil(event);
    
    // PageURL is empty
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
            [builder setPageUrl:@""];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"PageURL cannot be nil or empty.", exception.reason);
    }
    
    // PageURL is nil
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
            [builder setPageUrl:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"PageURL cannot be nil or empty.", exception.reason);
    }
}

- (void)testStructuredBuilderConditions {
    // Valid construction
    SPStructured *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"category"];
        [builder setAction:@"action"];
    }];
    XCTAssertNotNil(event);
    
    // Category is empty
    @try {
        event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
            [builder setCategory:@""];
            [builder setAction:@"action"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    
    // Category is nil
    @try {
        event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
            [builder setCategory:nil];
            [builder setAction:@"action"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    
    // Action is empty
    @try {
        event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
            [builder setCategory:@"category"];
            [builder setAction:@""];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Action cannot be nil or empty.", exception.reason);
    }
    
    // Action is nil
    @try {
        event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
            [builder setCategory:@"category"];
            [builder setAction:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Action cannot be nil or empty.", exception.reason);
    }
}

- (void)testUnstructuredBuilderConditions {
    // Valid construction
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSNumber numberWithInt:23] forKey:@"level"];
    [data setObject:[NSNumber numberWithInt:56473] forKey:@"score"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    SPUnstructured *event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:sdj];
    }];
    XCTAssertNotNil(event);
    
    // Category is empty
    @try {
        event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
            [builder setEventData:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"EventData cannot be nil.", exception.reason);
    }
}

- (void)testScreenViewBuilderConditions {
    // Valid construction
    SPScreenView *event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"name"];
        [builder setId:@"id"];
    }];
    XCTAssertNotNil(event);
    
    event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@""];
        [builder setId:@"id"];
    }];
    XCTAssertNotNil(event);
    
    event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"name"];
        [builder setId:@""];
    }];
    XCTAssertNotNil(event);
    
    // Name and ID is empty
    @try {
        event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
            [builder setName:@""];
            [builder setId:@""];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Name and ID cannot both be nil and empty.", exception.reason);
    }
    
    // Name and ID is nil
    @try {
        event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
            [builder setName:nil];
            [builder setId:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Name and ID cannot both be nil and empty.", exception.reason);
    }
}

- (void)testTimingBuilderConditions {
    // Valid construction
    SPTiming *event = [SPTiming build:^(id<SPTimingBuilder> builder) {
        [builder setCategory:@"category"];
        [builder setVariable:@"variable"];
        [builder setTiming:5];
    }];
    XCTAssertNotNil(event);
    
    // Category is empty
    @try {
        event = [SPTiming build:^(id<SPTimingBuilder> builder) {
            [builder setCategory:@""];
            [builder setVariable:@"variable"];
            [builder setTiming:5];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    
    // Category is nil
    @try {
        event = [SPTiming build:^(id<SPTimingBuilder> builder) {
            [builder setCategory:nil];
            [builder setVariable:@"variable"];
            [builder setTiming:5];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    
    // Variable is empty
    @try {
        event = [SPTiming build:^(id<SPTimingBuilder> builder) {
            [builder setCategory:@"category"];
            [builder setVariable:@""];
            [builder setTiming:5];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Variable cannot be nil or empty.", exception.reason);
    }
    
    // Variable is nil
    @try {
        event = [SPTiming build:^(id<SPTimingBuilder> builder) {
            [builder setCategory:@"category"];
            [builder setVariable:nil];
            [builder setTiming:5];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Variable cannot be nil or empty.", exception.reason);
    }
    
    // Timing is nil
    @try {
        event = [SPTiming build:^(id<SPTimingBuilder> builder) {
            [builder setCategory:@"category"];
            [builder setVariable:@"variable"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Timing cannot be nil.", exception.reason);
    }
}

- (void)testEcommerceBuilderConditions {
    // Valid construction
    SPEcommerce *event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
        [builder setOrderId:@"orderid"];
        [builder setTotalValue:5];
        [builder setItems:[[NSArray alloc] init]]; // This is valid as we don't check for count of items. Should we?
    }];
    XCTAssertNotNil(event);
    
    // OrderID is empty
    @try {
        event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
            [builder setOrderId:@""];
            [builder setTotalValue:5];
            [builder setItems:[[NSArray alloc] init]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"OrderId cannot be nil or empty.", exception.reason);
    }
    
    // OrderID is nil
    @try {
        event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
            [builder setOrderId:nil];
            [builder setTotalValue:5];
            [builder setItems:[[NSArray alloc] init]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"OrderId cannot be nil or empty.", exception.reason);
    }
    
    // Items is nil
    @try {
        event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
            [builder setOrderId:@"orderid"];
            [builder setTotalValue:5];
            [builder setItems:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Items cannot be nil.", exception.reason);
    }
    
    // TotalValue is nil
    @try {
        event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
            [builder setOrderId:@"orderid"];
            [builder setItems:[[NSArray alloc] init]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"TotalValue cannot be nil.", exception.reason);
    }
}

- (void)testEcommerceItemBuilderConditions {
    // Valid construction
    SPEcommerceItem *event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
        [builder setItemId:@"itemid"];
        [builder setSku:@"sku"];
        [builder setPrice:5];
        [builder setQuantity:1];
    }];
    XCTAssertNotNil(event);
    
    // Item is empty
    @try {
        event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
            [builder setItemId:@""];
            [builder setSku:@"sku"];
            [builder setPrice:5];
            [builder setQuantity:1];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"ItemId cannot be nil or empty.", exception.reason);
    }
    
    // Item is nil
    @try {
        event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
            [builder setItemId:nil];
            [builder setSku:@"sku"];
            [builder setPrice:5];
            [builder setQuantity:1];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"ItemId cannot be nil or empty.", exception.reason);
    }
    
    // Sku is empty
    @try {
        event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
            [builder setItemId:@"itemid"];
            [builder setSku:@""];
            [builder setPrice:5];
            [builder setQuantity:1];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"SKU cannot be nil or empty.", exception.reason);
    }
    
    // Sku is nil
    @try {
        event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
            [builder setItemId:@"itemid"];
            [builder setSku:nil];
            [builder setPrice:5];
            [builder setQuantity:1];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"SKU cannot be nil or empty.", exception.reason);
    }
    
    // Price is nil
    @try {
        event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
            [builder setItemId:@"itemid"];
            [builder setSku:@"sku"];
            [builder setQuantity:1];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Price cannot be nil.", exception.reason);
    }
    
    // Quantity is nil
    @try {
        event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
            [builder setItemId:@"itemid"];
            [builder setSku:@"sku"];
            [builder setPrice:1];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Quantity cannot be nil.", exception.reason);
    }
}

// --- Helpers

- (NSMutableArray *) getCustomContext {
    NSDictionary * data = @{@"snowplow": @"demo-tracker"};
    SPSelfDescribingJson * context = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios/jsonschema/1-0-0"
                                                                          andData:data];
    return [NSMutableArray arrayWithArray:@[context]];
}

- (NSMutableArray *) getBadCustomContext {
    NSDictionary * data = @{@"snowplow": @"demo-tracker"};
    return [NSMutableArray arrayWithArray:@[data]];
}

@end
