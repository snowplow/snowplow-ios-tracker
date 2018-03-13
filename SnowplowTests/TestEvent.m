//
//  TestEvent.m
//  Snowplow
//
//  Copyright (c) 2013-2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2018 Snowplow Analytics Ltd
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
        [builder setTimestamp:@1234567890];
    }];
    XCTAssertNotNil(event);
    XCTAssertEqualObjects([event getEventId], @"an-event-id-string");
    XCTAssertEqual([event getTimestamp].longLongValue, @(1234567890).longLongValue);
    
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

- (void)testConsentWithdrawnBuilderConditions {
    // Valid construction
    SPConsentWithdrawn *event = [SPConsentWithdrawn build:^(id<SPConsentWithdrawnBuilder> builder) {
        [builder setName:@"name"];
        [builder setAll:false];
        [builder setVersion:[NSNumber numberWithInt:3]];
        [builder setDocumentId:[NSNumber numberWithInt:1000]];
        [builder setDescription:@"description"];
    }];
    XCTAssertNotNil(event);
}

- (void)testConsentGrantedBuilderConditions {
    // Valid construction
    SPConsentGranted *event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
        [builder setName:@"name"];
        [builder setExpiry:@"expiry"];
        [builder setVersion:[NSNumber numberWithInt:3]];
        [builder setDocumentId:[NSNumber numberWithInt:1000]];
        [builder setDescription:@"description"];
    }];
    XCTAssertNotNil(event);

    // documentId is empty
    @try {
        event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
            [builder setDocumentId:nil];
            [builder setVersion:[NSNumber numberWithInt:3]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Document ID cannot be nil.", exception.reason);
    }

    // Version is empty
    @try {
        event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
            [builder setDocumentId:[NSNumber numberWithInt:3]];
            [builder setVersion:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Version cannot be nil.", exception.reason);
    }
}

- (void)testConsentDocumentBuilderConditions {
    // Valid construction
    SPConsentGranted *event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
        [builder setName:@"name"];
        [builder setExpiry:@"expiry"];
        [builder setVersion:[NSNumber numberWithInt:3]];
        [builder setDocumentId:[NSNumber numberWithInt:1000]];
        [builder setDescription:@"description"];
    }];
    XCTAssertNotNil(event);

    // documentId is empty
    @try {
        event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
            [builder setDocumentId:nil];
            [builder setVersion:[NSNumber numberWithInt:3]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Document ID cannot be nil.", exception.reason);
    }

    // Version is empty
    @try {
        event = [SPConsentGranted build:^(id<SPConsentGrantedBuilder> builder) {
            [builder setVersion:nil];
            [builder setDocumentId:[NSNumber numberWithInt:3]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Version cannot be nil.", exception.reason);
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

    // Badge is empty
    @try {
        event = [SPNotificationContent build:^(id<SPNotificationContentBuilder> builder) {
            [builder setTitle:@"title"];
            [builder setSubtitle:@"subtitle"];
            [builder setBody:@"body"];
            [builder setBadge:nil];
            [builder setSound:@"sound"];
            [builder setLaunchImageName:@"image"];
            [builder setUserInfo:userInfo];
            [builder setAttachments:attachments];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Badge cannot be nil.", exception.reason);
    }
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

    // Notification is empty
    @try {
        event = [SPPushNotification build:^(id<SPPushNotificationBuilder> builder) {
            [builder setAction:@"action"];
            [builder setTrigger:@"trigger"];
            [builder setDeliveryDate:@"date"];
            [builder setCategoryIdentifier:@"category"];
            [builder setThreadIdentifier:@"thread"];
            [builder setNotification:nil];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Notification cannot be nil.", exception.reason);
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
