//
//  TestRequest.m
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
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPRequestCallback.h"
#import "Nocilla.h"

@interface TestRequest : XCTestCase <SPRequestCallback>

@end

@implementation TestRequest {
    NSInteger _successCount;
    NSInteger _failureCount;
}

NSString *const TEST_SERVER_REQUEST = @"http://acme.test.url.com";

- (void)setUp {
    [super setUp];
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    [super tearDown];
    [[LSNocilla sharedInstance] clearStubs];
}

// Tests

- (void)testRequestSendWithPost {
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"%@/com.snowplowanalytics.snowplow/tp2", TEST_SERVER_REQUEST]).andReturn(200);
    
    SPTracker * tracker = [self getTracker:[NSURL URLWithString:TEST_SERVER_REQUEST] requestType:SPRequestPost];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    
    XCTAssertEqual(_successCount, 28);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}


- (void)testRequestSendWithGet {
    stubRequest(@"GET", [[NSString alloc] initWithFormat:@"^%@/i?(.*?)", TEST_SERVER_REQUEST].regex).andReturn(200);
    
    SPTracker * tracker = [self getTracker:[NSURL URLWithString:TEST_SERVER_REQUEST] requestType:SPRequestGet];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_successCount, 28);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithBadUrl {
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"%@/com.snowplowanalytics.snowplow/tp2", TEST_SERVER_REQUEST]).andReturn(404);
    
    // Send all events with a bad URL
    SPTracker * tracker = [self getTracker:[NSURL URLWithString:TEST_SERVER_REQUEST] requestType:SPRequestPost];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_failureCount, 28);
    XCTAssertEqual([tracker.emitter getDbCount], 28);
    
    // Update the URL and flush
    [[tracker emitter] setUrlEndpoint:[NSURL URLWithString:TEST_SERVER_REQUEST]];
    
    [[LSNocilla sharedInstance] clearStubs];
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"%@/com.snowplowanalytics.snowplow/tp2", TEST_SERVER_REQUEST]).andReturn(200);
    
    [[tracker emitter] flushBuffer];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_successCount, 28);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithoutSubject {
    stubRequest(@"GET", [[NSString alloc] initWithFormat:@"^%@/i?(.*?)", TEST_SERVER_REQUEST].regex).andReturn(200);
    
    SPTracker * tracker = [self getTracker:[NSURL URLWithString:TEST_SERVER_REQUEST] requestType:SPRequestGet];
    [tracker setSubject:nil];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_successCount, 28);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithCollectionOff {
    stubRequest(@"POST", [[NSString alloc] initWithFormat:@"%@/com.snowplowanalytics.snowplow/tp2", TEST_SERVER_REQUEST]).andReturn(200);
    
    SPTracker * tracker = [self getTracker:[NSURL URLWithString:TEST_SERVER_REQUEST] requestType:SPRequestPost];
    [tracker pauseEventTracking];
    [self sendAll:tracker];
    [self emitterSleep:[tracker emitter]];
    XCTAssertEqual(_failureCount, 0);
    XCTAssertEqual(_successCount, 0);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

// Helpers

- (SPTracker *)getTracker:(NSURL *)url requestType:(enum SPRequestOptions)type {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:url];
        [builder setCallback:self];
        [builder setHttpMethod:type];
    }];
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES];
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
        [self trackPageViewWithTracker:tracker];
        [self trackScreenViewWithTracker:tracker];
        [self trackTimingWithCategoryWithTracker:tracker];
        [self trackEcommerceTransactionWithTracker:tracker];
    });
}

- (void) trackStructuredEventWithTracker:(SPTracker *)tracker_ {
    [tracker_ trackStructuredEvent:@"DemoCategory" action:@"DemoAction" label:@"DemoLabel" property:@"DemoProperty" value:5];
    [tracker_ trackStructuredEvent:@"DemoCategory" action:@"DemoAction" label:@"DemoLabel" property:@"DemoProperty" value:5 context:[self getCustomContext]];
    [tracker_ trackStructuredEvent:@"DemoCategory" action:@"DemoAction" label:@"DemoLabel" property:@"DemoProperty" value:5 timestamp:1243567890];
    [tracker_ trackStructuredEvent:@"DemoCategory" action:@"DemoAction" label:@"DemoLabel" property:@"DemoProperty" value:5 context:[self getCustomContext] timestamp:1243567890];
}

- (void) trackUnstructuredEventWithTracker:(SPTracker *)tracker_ {
    NSDictionary *event = @{
                            @"schema":@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0",
                            @"data": @{
                                    @"level": @23,
                                    @"score": @56473
                                    }
                            };
    [tracker_ trackUnstructuredEvent:event];
    [tracker_ trackUnstructuredEvent:event context:[self getCustomContext]];
    [tracker_ trackUnstructuredEvent:event timestamp:1243567890];
    [tracker_ trackUnstructuredEvent:event context:[self getCustomContext] timestamp:1243567890];
}

- (void) trackPageViewWithTracker:(SPTracker *)tracker_ {
    [tracker_ trackPageView:@"DemoPageUrl" title:@"DemoPageTitle" referrer:@"DemoPageReferrer"];
    [tracker_ trackPageView:@"DemoPageUrl" title:@"DemoPageTitle" referrer:@"DemoPageReferrer" context:[self getCustomContext]];
    [tracker_ trackPageView:@"DemoPageUrl" title:@"DemoPageTitle" referrer:@"DemoPageReferrer" timestamp:1243567890];
    [tracker_ trackPageView:@"DemoPageUrl" title:@"DemoPageTitle" referrer:@"DemoPageReferrer" context:[self getCustomContext] timestamp:1243567890];
}

- (void) trackScreenViewWithTracker:(SPTracker *)tracker_ {
    [tracker_ trackScreenView:@"DemoScreenName" id:@"DemoScreenId"];
    [tracker_ trackScreenView:@"DemoScreenName" id:@"DemoScreenId" context:[self getCustomContext]];
    [tracker_ trackScreenView:@"DemoScreenName" id:@"DemoScreenId" timestamp:1243567890];
    [tracker_ trackScreenView:@"DemoScreenName" id:@"DemoScreenId" context:[self getCustomContext] timestamp:1243567890];
}

- (void) trackTimingWithCategoryWithTracker:(SPTracker *)tracker_ {
    [tracker_ trackTimingWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:5 label:@"DemoTimingLabel"];
    [tracker_ trackTimingWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:5 label:@"DemoTimingLabel" context:[self getCustomContext]];
    [tracker_ trackTimingWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:5 label:@"DemoTimingLabel" timestamp:1243567890];
    [tracker_ trackTimingWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:5 label:@"DemoTimingLabel" context:[self getCustomContext] timestamp:1243567890];
}

- (void) trackEcommerceTransactionWithTracker:(SPTracker *)tracker_ {
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    
    SPPayload * item1 = [tracker_ trackEcommerceTransactionItem:transactionID
                                                            sku:@"DemoItemSku"
                                                           name:@"DemoItemName"
                                                       category:@"DemoItemCategory"
                                                          price:0.75F
                                                       quantity:1
                                                       currency:@"USD"];
    SPPayload * item2 = [tracker_ trackEcommerceTransactionItem:transactionID
                                                            sku:@"DemoItemSku"
                                                           name:@"DemoItemName"
                                                       category:@"DemoItemCategory"
                                                          price:0.75F
                                                       quantity:1
                                                       currency:@"USD"
                                                        context:[self getCustomContext]];
    SPPayload * item3 = [tracker_ trackEcommerceTransactionItem:transactionID
                                                            sku:@"DemoItemSku"
                                                           name:@"DemoItemName"
                                                       category:@"DemoItemCategory"
                                                          price:0.75F
                                                       quantity:1
                                                       currency:@"USD"
                                                      timestamp:1243567890];
    
    [itemArray addObject:item1];
    [tracker_ trackEcommerceTransaction:transactionID
                             totalValue:350
                            affiliation:@"DemoTranAffiliation"
                               taxValue:10
                               shipping:15
                                   city:@"Boston"
                                  state:@"Massachusetts"
                                country:@"USA"
                               currency:@"USD"
                                  items:itemArray];
    
    [tracker_ trackEcommerceTransaction:transactionID
                             totalValue:350
                            affiliation:@"DemoTranAffiliation"
                               taxValue:10
                               shipping:15
                                   city:@"Boston"
                                  state:@"Massachusetts"
                                country:@"USA"
                               currency:@"USD"
                                  items:itemArray
                                context:[self getCustomContext]];
    
    [itemArray removeAllObjects];
    [itemArray addObject:item2];
    [tracker_ trackEcommerceTransaction:transactionID
                             totalValue:350
                            affiliation:@"DemoTranAffiliation"
                               taxValue:10
                               shipping:15
                                   city:@"Boston"
                                  state:@"Massachusetts"
                                country:@"USA"
                               currency:@"USD"
                                  items:itemArray
                              timestamp:1243567890];
    
    [itemArray removeAllObjects];
    [itemArray addObject:item3];
    [tracker_ trackEcommerceTransaction:transactionID
                             totalValue:350
                            affiliation:@"DemoTranAffiliation"
                               taxValue:10
                               shipping:15
                                   city:@"Boston"
                                  state:@"Massachusetts"
                                country:@"USA"
                               currency:@"USD"
                                  items:itemArray
                                context:[self getCustomContext]
                              timestamp:1243567890];
}

- (NSMutableArray *) getCustomContext {
    NSDictionary *context = @{
                              @"schema":@"iglu:com.acme_company/demo_ios/jsonschema/1-0-0",
                              @"data": @{
                                      @"snowplow": @"demo-tracker"
                                      }
                              };
    return [NSMutableArray arrayWithArray:@[context]];
}

@end
