//
//  TestEvent.m
//  Snowplow
//

#import <XCTest/XCTest.h>
#import "SPEvent.h"
#import "SPTrackerError.h"
#import "SPSelfDescribingJson.h"

@interface TestEvent : XCTestCase

@end

@implementation TestEvent

- (void)testEvent {
    // Valid construction
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    event.contexts = self.goodCustomContext;
    XCTAssertNotNil(event);
    event = nil;
    
    // Context is not SelfDescribingJson
    BOOL isFailed = NO;
    @try {
        event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
        [event contexts:self.badCustomContext];
    }
    @catch (NSException *exception) {
        isFailed = YES;
        XCTAssertEqualObjects(@"All contexts must be SelfDescribingJson objects.", exception.reason);
    }
    XCTAssertTrue(isFailed);
}
 
- (void)testTrueTimestamp {
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    XCTAssertNil(event.trueTimestamp);

    // Set trueTimestamp
    NSDate *testDate = [NSDate date];
    event.trueTimestamp = testDate;
    XCTAssertEqual(event.trueTimestamp, testDate);
}

- (void)testPageView {
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

- (void)testStructured {
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

- (void)testUnstructured {
    // Valid construction
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@23 forKey:@"level"];
    [data setObject:@56473 forKey:@"score"];
    SPSelfDescribingJson *sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithEventData:sdj];
    XCTAssertNotNil(event);
}

- (void)testUnstructuredWithWrongData {
    // Invalid dictionary
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@12 forKey:@12];
    SPSelfDescribingJson *sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
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

- (void)testConsentWithdrawn {
    // Valid construction
    SPConsentWithdrawn *event = [[[[[[[SPConsentWithdrawn alloc] init]
                                     name:@"name"]
                                    all:NO]
                                   version:@"3"]
                                  documentId:@"1000"]
                                 documentDescription:@"description"];
    XCTAssertNotNil(event);
}

- (void)testConsentGranted {
    // Valid construction
    SPConsentGranted *event = [[SPConsentGranted alloc] initWithExpiry:@"expiry" documentId:@"1000" version:@"3"];
    event.name = @"name";
    event.documentDescription = @"description";
    XCTAssertNotNil(event);
}

- (void)testConsentDocument {
    // Valid construction
    SPConsentGranted *event = [[SPConsentGranted alloc] initWithExpiry:@"expiry" documentId:@"1000" version:@"3"];
    event.name = @"name";
    event.documentDescription = @"description";
    XCTAssertNotNil(event);
}

- (void)testScreenView {
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

- (void)testTiming {
    // Valid construction
    SPTiming *event = [[SPTiming alloc] initWithCategory:@"cat" variable:@"var" timing:@5];
    XCTAssertNotNil(event);
    event = nil;
    
    // Category is empty
    @try {
        event = [[SPTiming alloc] initWithCategory:@"" variable:@"var" timing:@5];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
    // Variable is empty
    @try {
        event = [[SPTiming alloc] initWithCategory:@"cat" variable:@"" timing:@5];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Variable cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testEcommerce {
    // Valid construction
    SPEcommerce *event = [[SPEcommerce alloc] initWithOrderId:@"id" totalValue:@5 items:@[]];
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

- (void)testEcommerceItem {
    // Valid construction
    SPEcommerceItem *event = [[SPEcommerceItem alloc] initWithSku:@"sku" price:@5.3 quantity:@5];
    XCTAssertNotNil(event);
    event = nil;
    
    // Sku is empty
    @try {
        event = [[SPEcommerceItem alloc] initWithSku:@"" price:@5.3 quantity:@5];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"SKU cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testPushNotificationContent {
    // Valid construction
    NSArray *attachments = @[ @{ @"identifier": @"id",
                                 @"url": @"www.test.com",
                                 @"type": @"test"
    },
                              @{ @"identifier": @"id2",
                                 @"url": @"www.test2.com",
                                 @"type": @"test2"
                              }
    ];
    
    NSDictionary *userInfo = @{ @"aps" : @{ @"alert": @"test",
                                            @"sound": @"sound",
                                            @"category": @"category"
    }
    };
    
    SPNotificationContent *event = [[SPNotificationContent alloc] initWithTitle:@"title" body:@"body" badge:@5];
    event.subtitle = @"subtitle";
    event.sound = @"sound";
    event.launchImageName = @"image";
    event.userInfo = userInfo;
    event.attachments = attachments;
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

- (void)testPushNotification {
    // Valid construction
    NSArray *attachments = @[ @{ @"identifier": @"id",
                                 @"url": @"www.test.com",
                                 @"type": @"test"
    },
                              @{ @"identifier": @"id2",
                                 @"url": @"www.test2.com",
                                 @"type": @"test2"
                              }
    ];
    
    NSDictionary *userInfo = @{ @"aps":
                                    @{ @"alert":
                                           @{
                                               @"title": @"test-title",
                                               @"body": @"test-body"
                                           },
                                    }
    };
    
    SPNotificationContent *content = [[SPNotificationContent alloc] initWithTitle:@"title" body:@"body" badge:@5];
    content.subtitle = @"subtitle";
    content.sound = @"sound";
    content.launchImageName = @"image";
    content.userInfo = userInfo;
    content.attachments = attachments;

    SPPushNotification *event = [[SPPushNotification alloc] initWithDate:@"date"
                                                                  action:@"action"
                                                                 trigger:@"PUSH"
                                                                category:@"category"
                                                                  thread:@"thread"
                                                            notification:content];
    XCTAssertNotNil(event);
    event = nil;

    // Action is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"date"
                                                  action:@""
                                                 trigger:@"PUSH"
                                                category:@"category"
                                                  thread:@"thread"
                                            notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Action cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);

    // Trigger is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"date"
                                                  action:@"action"
                                                 trigger:@""
                                                category:@"category"
                                                  thread:@"thread"
                                            notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Trigger cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
    // Date is nil
    @try {
        event = [[SPPushNotification alloc] initWithDate:@""
                                                  action:@"action"
                                                 trigger:@"PUSH"
                                                category:@"category"
                                                  thread:@"thread"
                                            notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Delivery date cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
    // CategoryId is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"date"
                                                  action:@"action"
                                                 trigger:@"PUSH"
                                                category:@""
                                                  thread:@"thread"
                                            notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Category identifier cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
    
    // ThreadId is empty
    @try {
        event = [[SPPushNotification alloc] initWithDate:@"date"
                                                  action:@"action"
                                                 trigger:@"PUSH"
                                                category:@"category"
                                                  thread:@""
                                            notification:content];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Thread identifier cannot be nil or empty.", exception.reason);
    }
    XCTAssertNil(event);
}

- (void)testError {
    // Valid construction
    SNOWError *error = [[[[SNOWError alloc] initWithMessage:@"message"]
                         name:@"name"]
                        stackTrace:@"stacktrace"];
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

- (NSMutableArray<SPSelfDescribingJson *> *)goodCustomContext {
    NSDictionary *data = @{@"snowplow": @"demo-tracker"};
    SPSelfDescribingJson *context = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios/jsonschema/1-0-0"
                                                                          andData:data];
    return [NSMutableArray arrayWithArray:@[context]];
}

- (NSMutableArray<SPSelfDescribingJson *> *)badCustomContext {
    NSDictionary *data = @{@"snowplow": @"demo-tracker"};
    return [NSMutableArray arrayWithArray:@[data]];
}

@end
