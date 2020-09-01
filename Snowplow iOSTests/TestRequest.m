//
//  TestRequest.m
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
#import "Snowplow.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPRequestCallback.h"
#import "SPEvent.h"
#import <Nocilla/Nocilla.h>

@interface TestRequest : XCTestCase <SPRequestCallback>

@end

@implementation TestRequest {
    NSInteger _successCount;
    NSInteger _failureCount;
}

NSString *const TEST_SERVER_REQUEST = @"acme.test.url.com";
NSString *protocol = @"https";

- (void)setUp {
    [super setUp];
    [[LSNocilla sharedInstance] start];
#if TARGET_OS_IPHONE
    if (SNOWPLOW_iOS_9_OR_LATER) {
        protocol = @"https";
    }
#else
    protocol = @"https";
#endif
}

- (void)tearDown {
    [super tearDown];
    [[LSNocilla sharedInstance] clearStubs];
}

// Tests

- (void)testRequestSendWithPost {
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"%@://%@/com.snowplowanalytics.snowplow/tp2", protocol, TEST_SERVER_REQUEST]).andReturn(200);
    
    SPTracker * tracker = [self getTracker:TEST_SERVER_REQUEST requestType:SPRequestPost];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    
    XCTAssertEqual(_successCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}


- (void)testRequestSendWithGet {
    stubRequest(@"GET", [[NSString alloc] initWithFormat:@"^%@://%@/i?(.*?)", protocol, TEST_SERVER_REQUEST].regex).andReturn(200);
    
    SPTracker * tracker = [self getTracker:TEST_SERVER_REQUEST requestType:SPRequestGet];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_successCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithBadUrl {
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"%@://%@/com.snowplowanalytics.snowplow/tp2", protocol, TEST_SERVER_REQUEST]).andReturn(404);
    
    // Send all events with a bad URL
    SPTracker * tracker = [self getTracker:TEST_SERVER_REQUEST requestType:SPRequestPost];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_failureCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 8);
    
    // Update the URL and flush
    [[tracker emitter] setUrlEndpoint:TEST_SERVER_REQUEST];
    
    [[LSNocilla sharedInstance] clearStubs];
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"%@://%@/com.snowplowanalytics.snowplow/tp2", protocol, TEST_SERVER_REQUEST]).andReturn(200);
    
    [[tracker emitter] flushBuffer];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_successCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithoutSubject {
    stubRequest(@"GET", [[NSString alloc] initWithFormat:@"^%@://%@/i?(.*?)", protocol, TEST_SERVER_REQUEST].regex).andReturn(200);
    
    SPTracker * tracker = [self getTracker:TEST_SERVER_REQUEST requestType:SPRequestGet];
    [tracker setSubject:nil];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_successCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithCollectionOff {
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"%@://%@/com.snowplowanalytics.snowplow/tp2", protocol, TEST_SERVER_REQUEST]).andReturn(200);
    
    SPTracker * tracker = [self getTracker:TEST_SERVER_REQUEST requestType:SPRequestPost];
    [tracker pauseEventTracking];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_failureCount, 0);
    XCTAssertEqual(_successCount, 0);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

// Helpers

- (SPTracker *)getTracker:(NSString *)url requestType:(enum SPRequestOptions)type {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:url];
        [builder setCallback:self];
        [builder setHttpMethod:type];
    }];
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:YES];
    SPTracker * tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:@"anAppId"];
        [builder setBase64Encoded:NO];
        [builder setTrackerNamespace:@"aNamespace"];
        [builder setSessionContext:YES];
    }];
    return tracker;
}

- (void)emitterSleep:(SPEmitter *)emitter {
    [NSThread sleepForTimeInterval:3];
    while ([emitter getSendingStatus]) {
        [NSThread sleepForTimeInterval:5];
    }
    [NSThread sleepForTimeInterval:3];
}

// Callback

- (void)onSuccessWithCount:(NSInteger)successCount {
    _successCount += successCount;
}

- (void)onFailureWithCount:(NSInteger)failureCount successCount:(NSInteger)successCount {
    _successCount += successCount;
    _failureCount += failureCount;
}

// Pre-Built Events for sending!

- (void) sendAll:(SPTracker *)tracker {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self trackStructuredEventWithTracker:tracker];
        [self trackUnstructuredEventWithTracker:tracker];
        [self trackSelfDescribingJsonEventWithTracker:tracker];
        [self trackPageViewWithTracker:tracker];
        [self trackScreenViewWithTracker:tracker];
        [self trackTimingWithCategoryWithTracker:tracker];
        [self trackEcommerceTransactionWithTracker:tracker];
    });
}

- (void) trackStructuredEventWithTracker:(SPTracker *)tracker_ {
    NSString *uuid = [NSUUID UUID].UUIDString;
    SPStructured *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"DemoCategory"];
        [builder setAction:@"DemoAction"];
        [builder setLabel:@"DemoLabel"];
        [builder setProperty:@"DemoProperty"];
        [builder setValue:5];
        [builder setContexts:[self getCustomContext]];
        [builder setTimestamp:@1243567890];
        [builder setEventId:uuid];
    }];
    [tracker_ track:event];
}

- (void) trackUnstructuredEventWithTracker:(SPTracker *)tracker_ {
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSNumber numberWithInt:23] forKey:@"level"];
    [data setObject:[NSNumber numberWithInt:56473] forKey:@"score"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    SPUnstructured *event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:sdj];
        [builder setContexts:[self getCustomContext]];
        [builder setTimestamp:@1243567890];
        [builder setEventId:uuid];
    }];
    [tracker_ track:event];
}

- (void) trackSelfDescribingJsonEventWithTracker:(SPTracker *)tracker_ {
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSNumber numberWithInt:23] forKey:@"level"];
    [data setObject:[NSNumber numberWithInt:56473] forKey:@"score"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    [tracker_ trackSelfDescribingEvent:sdj];
}

- (void) trackPageViewWithTracker:(SPTracker *)tracker_ {
    NSString *uuid = [NSUUID UUID].UUIDString;
    SPPageView *event = [SPPageView build:^(id<SPPageViewBuilder> builder) {
        [builder setPageUrl:@"DemoPageUrl"];
        [builder setPageTitle:@"DemoPageTitle"];
        [builder setReferrer:@"DemoPageReferrer"];
        [builder setContexts:[self getCustomContext]];
        [builder setTimestamp:@1243567890];
        [builder setEventId:uuid];
    }];
    [tracker_ track:event];
}

- (void) trackScreenViewWithTracker:(SPTracker *)tracker_ {
    NSString *eventId = [NSUUID UUID].UUIDString;
    NSString *screenId = [NSUUID UUID].UUIDString;
    SPScreenView *event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
        [builder setName:@"DemoScreenName"];
        [builder setScreenId:screenId];
        [builder setContexts:[self getCustomContext]];
        [builder setTimestamp:@1243567890];
        [builder setEventId:eventId];
    }];
    [tracker_ track:event];
}

- (void) trackTimingWithCategoryWithTracker:(SPTracker *)tracker_ {
    NSString *uuid = [NSUUID UUID].UUIDString;
    SPTiming *event = [SPTiming build:^(id<SPTimingBuilder> builder) {
        [builder setCategory:@"DemoTimingCategory"];
        [builder setVariable:@"DemoTimingVariable"];
        [builder setTiming:5];
        [builder setLabel:@"DemoTimingLabel"];
        [builder setContexts:[self getCustomContext]];
        [builder setTimestamp:@1243567890];
        [builder setEventId:uuid];
    }];
    [tracker_ track:event];
}

- (void) trackEcommerceTransactionWithTracker:(SPTracker *)tracker_ {
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    
    SPEcommerceItem * item = [SPEcommerceItem build:^(id<SPEcommTransactionItemBuilder> builder) {
        [builder setItemId:transactionID];
        [builder setSku:@"DemoItemSku"];
        [builder setName:@"DemoItemName"];
        [builder setCategory:@"DemoItemCategory"];
        [builder setPrice:0.75F];
        [builder setQuantity:1];
        [builder setCurrency:@"USD"];
        [builder setContexts:[self getCustomContext]];
        [builder setTimestamp:@1234657890];
        [builder setEventId:uuid];
    }];
    
    [itemArray addObject:item];
    
    SPEcommerce *event = [SPEcommerce build:^(id<SPEcommTransactionBuilder> builder) {
        [builder setOrderId:transactionID];
        [builder setTotalValue:350];
        [builder setAffiliation:@"DemoTranAffiliation"];
        [builder setTaxValue:10];
        [builder setShipping:15];
        [builder setCity:@"Boston"];
        [builder setState:@"Massachusetts"];
        [builder setCountry:@"USA"];
        [builder setCurrency:@"USD"];
        [builder setItems:itemArray];
        [builder setContexts:[self getCustomContext]];
        [builder setTimestamp:@1243567890];
        [builder setEventId:uuid];
    }];
    [tracker_ track:event];
}

- (NSMutableArray *) getCustomContext {
    NSDictionary * data = @{@"snowplow": @"demo-tracker"};
    SPSelfDescribingJson * context = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios/jsonschema/1-0-0"
                                                                          andData:data];
    return [NSMutableArray arrayWithArray:@[context]];
}

@end
