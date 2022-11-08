//
//  TestEvent.m
//  Snowplow
//

#import <XCTest/XCTest.h>
#import "SPEvent.h"
#import "SPTrackerError.h"
#import "SPSelfDescribingJson.h"
#import "SPSelfDescribing.h"
#import "SPMockEventStore.h"

@interface TestEvent : XCTestCase

@end

@implementation TestEvent

- (void)testTrueTimestamp {
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    XCTAssertNil(event.trueTimestamp);

    // Set trueTimestamp
    NSDate *testDate = [NSDate date];
    event.trueTimestamp = testDate;
    XCTAssertEqual(event.trueTimestamp, testDate);
}

- (void)testApplicationInstall {
    // Prepare ApplicationInstall event
    SPSelfDescribingJson *installEvent = [[SPSelfDescribingJson alloc] initWithSchema:kSPApplicationInstallSchema andData:@{}];
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithEventData:installEvent];
    NSDate *currentTimestamp = [NSDate dateWithTimeIntervalSince1970:12345L];
    event.trueTimestamp = currentTimestamp;
    
    // Setup tracker
    SPTrackerConfiguration *trackerConfiguration = [SPTrackerConfiguration new];
    trackerConfiguration.base64Encoding = NO;
    trackerConfiguration.installAutotracking = NO;
    SPMockEventStore *eventStore = [SPMockEventStore new];
    SPNetworkConfiguration *networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:@"fake-url" method:SPHttpMethodPost];
    SPEmitterConfiguration *emitterConfiguration = [[SPEmitterConfiguration alloc] init];
    emitterConfiguration.eventStore = eventStore;
    emitterConfiguration.threadPoolSize = 10;
    id<SPTrackerController> trackerController = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfiguration configurations:@[trackerConfiguration, emitterConfiguration]];

    // Track event
    [trackerController track:event];
    for (int i=0; eventStore.count < 1 && i < 10; i++) {
        [NSThread sleepForTimeInterval:1];
    }
    NSArray<SPEmitterEvent *> *events = [eventStore emittableEventsWithQueryLimit:10];
    [eventStore removeAllEvents];
    XCTAssertEqual(1, events.count);
    SPPayload *payload = [[events firstObject] payload];
    
    // Check v_tracker field
    NSString *deviceTimestamp = (NSString *)[[payload getAsDictionary] objectForKey:@"dtm"];
    NSString *expected = [NSString stringWithFormat:@"%lld", (long long)(currentTimestamp.timeIntervalSince1970 * 1000)];
    XCTAssertEqualObjects(expected, deviceTimestamp);
}

- (void)testWorkaroundForCampaignAttributionEnrichment {
    // Prepare DeepLinkReceived event
    SPDeepLinkReceived *event = [[SPDeepLinkReceived alloc] initWithUrl:@"url"];
    event.referrer = @"referrer";
    
    // Setup tracker
    SPTrackerConfiguration *trackerConfiguration = [SPTrackerConfiguration new];
    trackerConfiguration.base64Encoding = NO;
    trackerConfiguration.installAutotracking = NO;
    SPMockEventStore *eventStore = [SPMockEventStore new];
    SPNetworkConfiguration *networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:@"fake-url" method:SPHttpMethodPost];
    SPEmitterConfiguration *emitterConfiguration = [[SPEmitterConfiguration alloc] init];
    emitterConfiguration.eventStore = eventStore;
    emitterConfiguration.threadPoolSize = 10;
    id<SPTrackerController> trackerController = [SPSnowplow createTrackerWithNamespace:@"namespace" network:networkConfiguration configurations:@[trackerConfiguration, emitterConfiguration]];

    // Track event
    [trackerController track:event];
    for (int i=0; eventStore.count < 1 && i < 10; i++) {
        [NSThread sleepForTimeInterval:1];
    }
    NSArray<SPEmitterEvent *> *events = [eventStore emittableEventsWithQueryLimit:10];
    [eventStore removeAllEvents];
    XCTAssertEqual(1, events.count);
    SPPayload *payload = [[events firstObject] payload];
    
    // Check url and referrer fields
    NSString *url = (NSString *)[[payload getAsDictionary] objectForKey:kSPPageUrl];
    NSString *referrer = (NSString *)[[payload getAsDictionary] objectForKey:kSPPageRefr];
    XCTAssertEqualObjects(url, @"url");
    XCTAssertEqualObjects(referrer, @"referrer");
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

- (void)testMessageNotification {
    SPMessageNotification *event = [[SPMessageNotification alloc] initWithTitle:@"title" body:@"body" trigger:SPMessageNotificationTriggerPush];
    event.notificationTimestamp = @"2020-12-31T15:59:60-08:00";
    event.action = @"action";
    event.bodyLocKey = @"loc key";
    event.bodyLocArgs = @[@"loc arg1", @"loc arg2"];
    event.sound = @"chime.mp3";
    event.notificationCount = @9;
    event.category = @"category1";
    event.attachments = @[[[SPMessageNotificationAttachment alloc] initWithIdentifier:@"id" type:@"type" url:@"url"]];

    NSDictionary<NSString *, NSObject *> *payload = event.payload;
    XCTAssertEqualObjects(@"title", payload[kSPMessageNotificationParamTitle]);
    XCTAssertEqualObjects(@"body", payload[kSPMessageNotificationParamBody]);
    XCTAssertEqualObjects(@"2020-12-31T15:59:60-08:00", payload[kSPMessageNotificationParamNotificationTimestamp]);
    XCTAssertEqualObjects(@"push", payload[kSPMessageNotificationParamTrigger]);
    XCTAssertEqualObjects(@"action", payload[kSPMessageNotificationParamAction]);
    XCTAssertEqualObjects(@"loc key", payload[kSPMessageNotificationParamBodyLocKey]);
    NSArray<NSString *> *locArgs = (NSArray<NSString *> *)(payload[kSPMessageNotificationParamBodyLocArgs]);
    XCTAssertNotNil(locArgs);
    XCTAssertEqual(2, locArgs.count);
    XCTAssertEqualObjects(@"loc arg1", locArgs[0]);
    XCTAssertEqualObjects(@"loc arg2", locArgs[1]);
    XCTAssertEqualObjects(@"chime.mp3", payload[kSPMessageNotificationParamSound]);
    XCTAssertEqualObjects(@9, payload[kSPMessageNotificationParamNotificationCount]);
    XCTAssertEqualObjects(@"category1", payload[kSPMessageNotificationParamCategory]);
    NSArray<NSDictionary<NSString *, NSObject *> *> *attachments = (NSArray<NSDictionary<NSString *, NSObject *> *> *)(payload[kSPMessageNotificationParamMessageNotificationAttachments]);
    XCTAssertNotNil(attachments);
    XCTAssertEqual(1, attachments.count);
    NSDictionary<NSString *, NSObject *> *attachment = attachments[0];
    XCTAssertEqualObjects(@"id", attachment[kSPMessageNotificationAttachmentParamIdentifier]);
    XCTAssertEqualObjects(@"type", attachment[kSPMessageNotificationAttachmentParamType]);
    XCTAssertEqualObjects(@"url", attachment[kSPMessageNotificationAttachmentParamUrl]);
}

- (void)testMessageNotificationWithUserInfo {
    NSDictionary *userInfo = @{ @"aps":
                                    @{ @"alert":
                                           @{
                                               @"title": @"test-title",
                                               @"body": @"test-body",
                                               @"loc-key": @"loc key",
                                               @"loc-args": @[@"loc arg1", @"loc arg2"]
                                           },
                                       @"sound": @"chime.aiff",
                                       @"badge": @9,
                                       @"category": @"category1",
                                       @"content-available": @1
                                    },
                                @"custom-element": @1
    };
    SPMessageNotification *event = [SPMessageNotification messageNotificationWithUserInfo:userInfo defaultTitle:nil defaultBody:nil];
    XCTAssertNotNil(event);
    NSDictionary<NSString *, NSObject *> *payload = event.payload;
    XCTAssertEqualObjects(@"test-title", payload[kSPMessageNotificationParamTitle]);
    XCTAssertEqualObjects(@"test-body", payload[kSPMessageNotificationParamBody]);
    XCTAssertEqualObjects(@"loc key", payload[kSPMessageNotificationParamBodyLocKey]);
    NSArray *locArgs = (NSArray *)payload[kSPMessageNotificationParamBodyLocArgs];
    XCTAssertEqual(2, locArgs.count);
    XCTAssertEqualObjects(@"loc arg1", locArgs[0]);
    XCTAssertEqualObjects(@"loc arg2", locArgs[1]);
    XCTAssertEqualObjects(@9, payload[kSPMessageNotificationParamNotificationCount]);
    XCTAssertEqualObjects(@"chime.aiff", payload[kSPMessageNotificationParamSound]);
    XCTAssertEqualObjects(@"category1", payload[kSPMessageNotificationParamCategory]);
    XCTAssertEqualObjects(@YES, payload[kSPMessageNotificationParamContentAvailable]);
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

@end
