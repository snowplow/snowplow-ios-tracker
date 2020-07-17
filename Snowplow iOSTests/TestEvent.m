//
//  TestEvent.m
//  Snowplow
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPEvent.h"
#import "SPTrackerError.h"
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
    NSString *presetEventId = [NSUUID UUID].UUIDString;
    
    // Valid construction
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setContexts:[self getCustomContext]];
        [builder setEventId:presetEventId];
        [builder setTimestamp:@1234567890];
    }];
    XCTAssertNotNil(event);
    XCTAssertEqualObjects([event getEventId], presetEventId);
    XCTAssertEqual([event getTimestamp].longLongValue, @(1234567890).longLongValue);
    event = nil;
    
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
    XCTAssertNil(event);
    
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
    XCTAssertNil(event);
}
 
- (void)testEventIdNilOrEmpty {
    // EventID is nil
    SPEvent *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setEventId:nil];
    }];
    XCTAssertNotNil(event);
    event = nil;
    
    // EventID is empty
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
            [builder setPageUrl:@"DemoPageUrl"];
            [builder setEventId:@""];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"EventID has to be a valid UUID.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testTrueTimestamp {
    // Set trueTimestamp
    SPEvent *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
    }];
    XCTAssertNil([event getTrueTimestamp]);

    // Set trueTimestamp
    NSNumber *testDate = @([[NSDate date] timeIntervalSince1970]);
    event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setTrueTimestamp:testDate];
    }];
    long long expected = (long long)(testDate.doubleValue * 1000);
    long long testing = (long long)([event getTrueTimestamp].doubleValue * 1000);
    XCTAssertEqual(testing, expected);
}

- (void)testPageViewBuilderConditions {
    // Valid construction
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
    }];
    XCTAssertNotNil(event);
    event = nil;
    
    // PageURL is empty
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
            [builder setPageUrl:@""];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"PageURL cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
    // PageURL is nil
    @try {
        event = [SPPageView build:^(id<SPPageViewBuilder> builder) {}];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"PageURL cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testStructuredBuilderConditions {
    // Valid construction
    SPStructured *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"category"];
        [builder setAction:@"action"];
    }];
    XCTAssertNotNil(event);
    event = nil;
    
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
    XCTAssertNil(event);
    
    // Category is nil
    @try {
        event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
            [builder setAction:@"action"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
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
    XCTAssertNil(event);
    
    // Action is nil
    @try {
        event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
            [builder setCategory:@"category"];
        }];
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
    SPUnstructured *event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:sdj];
    }];
    XCTAssertNotNil(event);
    event = nil;
    
    // Category is empty
    @try {
        event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {}];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"EventData cannot be nil.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testUnstructuredBuilderWrongDataCondition {
    // Invalid dictionary
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSNumber numberWithInt:12] forKey:[NSNumber numberWithInt:12]];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    // Data is wrong
    SPUnstructured *event;
    @try {
        event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
            [builder setEventData:sdj];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"EventData has to be JSON serializable.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testConsentWithdrawnBuilderConditions {
    // Valid construction
    SPConsentWithdrawn *event = [SPConsentWithdrawn build:^(id<SPConsentWithdrawnBuilder> builder) {
        [builder setName:@"name"];
        [builder setAll:false];
        [builder setVersion:@"3"];
        [builder setDocumentId:@"1000"];
        [builder setDescription:@"description"];
    }];
    XCTAssertNotNil(event);
}

- (void)testConsentGrantedBuilderConditions {
    // Valid construction
    SPConsentGranted *event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
        [builder setName:@"name"];
        [builder setExpiry:@"expiry"];
        [builder setVersion:@"3"];
        [builder setDocumentId:@"1000"];
        [builder setDescription:@"description"];
    }];
    XCTAssertNotNil(event);
    event = nil;

    // documentId is empty
    @try {
        event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
            [builder setVersion:@"3"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Document ID cannot be nil.", exception.reason);
    }
    XCTAssertNil(event);

    // Version is empty
    @try {
        event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
            [builder setDocumentId:@"1000"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Version cannot be nil.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testConsentDocumentBuilderConditions {
    // Valid construction
    SPConsentGranted *event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
        [builder setName:@"name"];
        [builder setExpiry:@"expiry"];
        [builder setVersion:@"3"];
        [builder setDocumentId:@"1000"];
        [builder setDescription:@"description"];
    }];
    XCTAssertNotNil(event);
    event = nil;

    // documentId is empty
    @try {
        event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
            [builder setVersion:@"3"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Document ID cannot be nil.", exception.reason);
    }
    XCTAssertNil(event);

    // Version is empty
    @try {
        event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
            [builder setDocumentId:@"3"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Version cannot be nil.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testScreenViewBuilderConditions {
    NSString *screenId = [NSUUID UUID].UUIDString;
    
    // Valid construction
    SPScreenView *event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"name"];
        [builder setScreenId:screenId];
    }];
    XCTAssertNotNil(event);
    event = nil;

    @try {
        event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
            [builder setName:@""];
            [builder setScreenId:screenId];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Name cannot be empty.", exception.reason);
    }
    XCTAssertNil(event);
   
    @try {
        event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
            [builder setName:@"name"];
            [builder setScreenId:@""];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"ScreenID has to be a valid UUID string.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testTimingBuilderConditions {
    // Valid construction
    SPTiming *event = [SPTiming build:^(id<SPTimingBuilder> builder) {
        [builder setCategory:@"category"];
        [builder setVariable:@"variable"];
        [builder setTiming:5];
    }];
    XCTAssertNotNil(event);
    event = nil;
    
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
    XCTAssertNil(event);
    
    // Category is nil
    @try {
        event = [SPTiming build:^(id<SPTimingBuilder> builder) {
            [builder setVariable:@"variable"];
            [builder setTiming:5];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
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
    XCTAssertNil(event);
    
    // Variable is nil
    @try {
        event = [SPTiming build:^(id<SPTimingBuilder> builder) {
            [builder setCategory:@"category"];
            [builder setTiming:5];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Variable cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
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
    XCTAssertNil(event);
}

- (void)testEcommerceBuilderConditions {
    // Valid construction
    SPEcommerce *event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
        [builder setOrderId:@"orderid"];
        [builder setTotalValue:5];
        [builder setItems:[[NSArray alloc] init]]; // This is valid as we don't check for count of items. Should we?
    }];
    XCTAssertNotNil(event);
    event = nil;
    
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
    XCTAssertNil(event);
    
    // OrderID is nil
    @try {
        event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
            [builder setTotalValue:5];
            [builder setItems:[[NSArray alloc] init]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"OrderId cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
    // Items is nil
    @try {
        event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
            [builder setOrderId:@"orderid"];
            [builder setTotalValue:5];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Items cannot be nil.", exception.reason);
    }
    XCTAssertNil(event);
    
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
    XCTAssertNil(event);
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
    event = nil;
    
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
    XCTAssertNil(event);
    
    // Item is nil
    @try {
        event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
            [builder setSku:@"sku"];
            [builder setPrice:5];
            [builder setQuantity:1];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"ItemId cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
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
    XCTAssertNil(event);
    
    // Sku is nil
    @try {
        event = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
            [builder setItemId:@"itemid"];
            [builder setPrice:5];
            [builder setQuantity:1];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"SKU cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
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
    XCTAssertNil(event);
    
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

    SPNotificationContent *event = [SPNotificationContent build:^(id<SPNotificationContentBuilder> builder) {
        [builder setTitle:@"title"];
        [builder setSubtitle:@"subtitle"];
        [builder setBody:@"body"];
        [builder setBadge:[NSNumber numberWithInt:5]];
        [builder setSound:@"sound"];
        [builder setLaunchImageName:@"image"];
        [builder setUserInfo:userInfo];
        [builder setAttachments:attachments];
    }];
    XCTAssertNotNil(event);
    event = nil;

    // Title is empty
    @try {
        event = [SPNotificationContent build:^(id<SPNotificationContentBuilder> builder) {
            [builder setTitle:@""];
            [builder setSubtitle:@"subtitle"];
            [builder setBody:@"body"];
            [builder setBadge:[NSNumber numberWithInt:5]];
            [builder setSound:@"sound"];
            [builder setLaunchImageName:@"image"];
            [builder setUserInfo:userInfo];
            [builder setAttachments:attachments];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Title cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Body is empty
    @try {
        event = [SPNotificationContent build:^(id<SPNotificationContentBuilder> builder) {
            [builder setTitle:@"title"];
            [builder setSubtitle:@"subtitle"];
            [builder setBody:@""];
            [builder setBadge:[NSNumber numberWithInt:5]];
            [builder setSound:@"sound"];
            [builder setLaunchImageName:@"image"];
            [builder setUserInfo:userInfo];
            [builder setAttachments:attachments];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Body cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Badge is empty
    @try {
        event = [SPNotificationContent build:^(id<SPNotificationContentBuilder> builder) {
            [builder setTitle:@"title"];
            [builder setSubtitle:@"subtitle"];
            [builder setBody:@"body"];
            [builder setSound:@"sound"];
            [builder setLaunchImageName:@"image"];
            [builder setUserInfo:userInfo];
            [builder setAttachments:attachments];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Badge cannot be nil.", exception.reason);
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

    SPNotificationContent *content = [SPNotificationContent build:^(id<SPNotificationContentBuilder> builder) {
        [builder setTitle:@"title"];
        [builder setSubtitle:@"subtitle"];
        [builder setBody:@"body"];
        [builder setBadge:[NSNumber numberWithInt:5]];
        [builder setSound:@"sound"];
        [builder setLaunchImageName:@"image"];
        [builder setUserInfo:userInfo];
        [builder setAttachments:attachments];
    }];

    SPPushNotification *event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
        [builder setAction:@"action"];
        [builder setTrigger:@"PUSH"];
        [builder setDeliveryDate:@"date"];
        [builder setCategoryIdentifier:@"category"];
        [builder setThreadIdentifier:@"thread"];
        [builder setNotification:content];
    }];
    XCTAssertNotNil(event);
    event = nil;

    // Action is empty
    @try {
        event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
            [builder setAction:@""];
            [builder setTrigger:@"trigger"];
            [builder setDeliveryDate:@"date"];
            [builder setCategoryIdentifier:@"category"];
            [builder setThreadIdentifier:@"thread"];
            [builder setNotification:content];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Action cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Trigger is nil
    @try {
        event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
            [builder setAction:@"action"];
            [builder setTrigger:@""];
            [builder setDeliveryDate:@"date"];
            [builder setCategoryIdentifier:@"category"];
            [builder setThreadIdentifier:@"thread"];
            [builder setNotification:content];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Trigger cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Date is nil
    @try {
        event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
            [builder setAction:@"action"];
            [builder setTrigger:@"trigger"];
            [builder setDeliveryDate:@""];
            [builder setCategoryIdentifier:@"category"];
            [builder setThreadIdentifier:@"thread"];
            [builder setNotification:content];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Delivery date cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // CategoryId is empty
    @try {
        event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
            [builder setAction:@"action"];
            [builder setTrigger:@"trigger"];
            [builder setDeliveryDate:@"date"];
            [builder setCategoryIdentifier:@""];
            [builder setThreadIdentifier:@"thread"];
            [builder setNotification:content];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category identifier cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // ThreadId is empty
    @try {
        event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
            [builder setAction:@"action"];
            [builder setTrigger:@"trigger"];
            [builder setDeliveryDate:@"date"];
            [builder setCategoryIdentifier:@"category"];
            [builder setThreadIdentifier:@""];
            [builder setNotification:content];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Thread identifier cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Notification is empty
    @try {
        event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
            [builder setAction:@"action"];
            [builder setTrigger:@"trigger"];
            [builder setDeliveryDate:@"date"];
            [builder setCategoryIdentifier:@"category"];
            [builder setThreadIdentifier:@"thread"];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Notification cannot be nil.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testErrorBuilderConditions {
    // Valid construction
    SNOWError * error = [SNOWError build:^(id<SPErrorBuilder> builder) {
        [builder setName:@"name"];
        [builder setMessage:@"message"];
        [builder setStackTrace:@"stackTrace"];
    }];
    
    XCTAssertNotNil(error);
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
    NSDictionary * data = @{@"snowplow": @"demo-tracker"};
    return [NSMutableArray arrayWithArray:@[data]];
}

@end
