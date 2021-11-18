//
//  TestEvent.m
//  Snowplow
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPEvent.h"
#import "SPTrackerError.h"
#import "SPSelfDescribingJson.h"

@interface LegacyTestEvent : XCTestCase

@end

@implementation LegacyTestEvent

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)testEventBuilderConditions {
    // Valid construction
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    [event setContexts:[self getCustomContext]];
    XCTAssertNotNil(event);
    event = nil;    
}
 
- (void)testTrueTimestamp {
    SPEvent *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    XCTAssertNil(event.trueTimestamp);

    // Set trueTimestamp
    NSDate *testDate = [NSDate date];
    event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    [event setTrueTimestamp:testDate];
    XCTAssertEqual(event.trueTimestamp, testDate);
}

- (void)testPageViewBuilderConditions {
    // Valid construction
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    XCTAssertNotNil(event);
    event = nil;
    
    // PageURL is empty
    @try {
        event = [[SPPageView alloc] initWithPageUrl:@""];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"PageURL cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testStructuredBuilderConditions {
    // Valid construction
    SPStructured *event = [[SPStructured alloc] initWithCategory:@"category" action:@"action"];
    XCTAssertNotNil(event);
    event = nil;
    
    // Category is empty
    @try {
        event = [[SPStructured alloc] initWithCategory:@"" action:@"action"];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
        
    // Action is empty
    @try {
        event = [[SPStructured alloc] initWithCategory:@"category" action:@""];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Action cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testUnstructuredBuilderEmptyCondition {
    // Valid construction
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSNumber numberWithInt:23] forKey:@"level"];
    [data setObject:[NSNumber numberWithInt:56473] forKey:@"score"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithEventData:sdj];
    XCTAssertNotNil(event);
    event = nil;
}

- (void)testUnstructuredBuilderWrongDataCondition {
    // Invalid dictionary
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSNumber numberWithInt:12] forKey:[NSNumber numberWithInt:12]];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    // Data is wrong
    SPSelfDescribing *event;
    @try {
        event = [[SPSelfDescribing alloc] initWithEventData:sdj];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"EventData payload has to be JSON serializable.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testConsentWithdrawnBuilderConditions {
    // Valid construction
    SPConsentWithdrawn *event = [[SPConsentWithdrawn alloc] init];
    [event setName:@"name"];
    [event setAll:false];
    [event setVersion:@"3"];
    [event setDocumentId:@"1000"];
    [event setDocumentDescription:@"description"];
    XCTAssertNotNil(event);
}

- (void)testConsentGrantedBuilderConditions {
    // Valid construction
    SPConsentGranted *event = [[SPConsentGranted alloc] initWithExpiry:@"expiry" documentId:@"1000" version:@"3"];
    event.name = @"name";
    event.documentDescription = @"description";
    XCTAssertNotNil(event);
    event = nil;
}

- (void)testConsentDocumentBuilderConditions {
    // Valid construction
    SPConsentDocument *event = [[SPConsentDocument alloc] initWithDocumentId:@"1000" version:@"3"];
    [event setName:@"name"];
    [event setDocumentDescription:@"description"];
    XCTAssertNotNil(event);
    event = nil;
}

- (void)testScreenViewBuilderConditions {
    NSUUID *screenId = [NSUUID UUID];
    
    // Valid construction
    SPScreenView *event = [[SPScreenView alloc] initWithName:@"name" screenId:screenId];
    XCTAssertNotNil(event);
    event = nil;

    @try {
        event = [[SPScreenView alloc] initWithName:@"" screenId:screenId];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Name cannot be empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testTimingBuilderConditions {
    // Valid construction
    SPTiming *event = [[SPTiming alloc] initWithCategory:@"category" variable:@"variable" timing:@5];
    XCTAssertNotNil(event);
    event = nil;
    
    // Category is empty
    @try {
        event = [[SPTiming alloc] initWithCategory:@"" variable:@"variable" timing:@5];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
        
    // Variable is empty
    @try {
        event = [[SPTiming alloc] initWithCategory:@"category" variable:@"" timing:@5];

    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Variable cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testEcommerceBuilderConditions {
    // Valid construction
    SPEcommerce *event = [[SPEcommerce alloc] initWithOrderId:@"orderId" totalValue:@5 items:@[]];
    XCTAssertNotNil(event);
    event = nil;
    
    // OrderID is empty
    @try {
        event = [[SPEcommerce alloc] initWithOrderId:@"" totalValue:@5 items:@[]];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"OrderId cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testEcommerceItemBuilderConditions {
    // Valid construction
    SPEcommerceItem *event = [[SPEcommerceItem alloc] initWithSku:@"sku" price:@5 quantity:@1];
    event.orderId = @"orderId";
    XCTAssertNotNil(event);
    event = nil;
    
    // Sku is empty
    @try {
        event = [[SPEcommerceItem alloc] initWithSku:@"" price:@5 quantity:@1];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"SKU cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testPushNotificationContentBuilderConditions {
    // Valid construction
    NSArray * attachments = @[ @{ @"identifier": @"id",
                                  @"url": @"www.test.com",
                                  @"type": @"test"
                                  },
                               @{ @"identifier": @"id2",
                                  @"url": @"www.test2.com",
                                  @"type": @"test2"
                                  }
                               ];

    NSDictionary * userInfo = @{ @"aps" : @{ @"alert": @"test",
                                             @"sound": @"sound",
                                             @"category": @"category"
                                             }
                                 };
    
    SPNotificationContent *event = [[SPNotificationContent alloc] initWithTitle:@"title" body:@"body" badge:@5];
    [event setSubtitle:@"subtitle"];
    [event setSound:@"sound"];
    [event setLaunchImageName:@"image"];
    [event setUserInfo:userInfo];
    [event setAttachments:attachments];
    XCTAssertNotNil(event);
    event = nil;
    
    // Title is empty
    @try {
        event = [[SPNotificationContent alloc] initWithTitle:@"" body:@"body" badge:@5];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Title cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Body is empty
    @try {
        event = [[SPNotificationContent alloc] initWithTitle:@"title" body:@"" badge:@5];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Body cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testPushNotificationBuilderConditions {
    // Valid construction
    NSArray * attachments = @[ @{ @"identifier": @"id",
                                  @"url": @"www.test.com",
                                  @"type": @"test"
                                  },
                               @{ @"identifier": @"id2",
                                  @"url": @"www.test2.com",
                                  @"type": @"test2"
                                  }
                               ];

    NSDictionary * userInfo = @{ @"aps" : @{ @"alert": @{@"title": @"test-title",
                                                         @"body": @"test-body"
                                                         },
                                             }
                                 };

    SPNotificationContent *content = [[SPNotificationContent alloc] initWithTitle:@"title" body:@"body" badge:@5];
        [content setSubtitle:@"subtitle"];
        [content setSound:@"sound"];
        [content setLaunchImageName:@"image"];
        [content setUserInfo:userInfo];
        [content setAttachments:attachments];

    SPPushNotification *event = [[SPPushNotification alloc] initWithDate:@"date" action:@"action" trigger:@"PUSH" category:@"category" thread:@"thread" notification:content];
    XCTAssertNotNil(event);
    event = nil;

    // Action is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"date" action:@"" trigger:@"PUSH" category:@"category" thread:@"thread" notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Action cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Trigger is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"date" action:@"action" trigger:@"" category:@"category" thread:@"thread" notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Trigger cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Date is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"" action:@"action" trigger:@"PUSH" category:@"category" thread:@"thread" notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Delivery date cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // CategoryId is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"date" action:@"action" trigger:@"PUSH" category:@"" thread:@"thread" notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category identifier cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // ThreadId is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"date" action:@"action" trigger:@"PUSH" category:@"category" thread:@"" notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Thread identifier cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testErrorBuilderConditions {
    // Valid construction
    SNOWError *event = [[SNOWError alloc] initWithMessage:@"message"];
    [event setName:@"name"];
    [event setStackTrace:@"stackTrace"];
    XCTAssertNotNil(event);
}

- (void)testTrackerErrorContainsStacktrace {
    @try {
        @throw([NSException exceptionWithName:@"CustomException" reason:@"reason" userInfo:nil]);
    } @catch (NSException *exception) {
        SPTrackerError *trackerError = [[SPTrackerError alloc] initWithSource:@"classname" message:@"message" error:nil exception:exception];
        NSDictionary<NSString *, NSObject *> *payload = trackerError.payload;
        XCTAssertEqualObjects(payload[@"message"], @"message");
        XCTAssertEqualObjects(payload[@"className"], @"classname");
        XCTAssertEqualObjects(payload[@"exceptionName"], @"CustomException");
        XCTAssertTrue([(NSString *)payload[@"stackTrace"] length]);
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
    NSDictionary *data = @{@"snowplow": @"demo-tracker"};
    return [NSMutableArray arrayWithArray:@[data]];
}

#pragma clang diagnostic pop

@end
