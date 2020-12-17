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

// MARK: - Mocks

@interface SPMockStore : NSObject <SPEventStore>

@property (nonatomic) NSMutableDictionary<NSNumber *, SPPayload *> *db;
@property (nonatomic) long lastInsertedRow;

@end

@implementation SPMockStore

- (instancetype)init {
    if (self = [super init]) {
        self.db = [NSMutableDictionary new];
        self.lastInsertedRow = -1;
    }
    return self;
}

- (void)addEvent:(nonnull SPPayload *)payload {
    @synchronized (self) {
        self.lastInsertedRow++;
        [self.db setObject:payload forKey:@(self.lastInsertedRow)];
    }
}

- (BOOL)removeEventWithId:(long long)storeId {
    @synchronized (self) {
        BOOL exist = [self.db objectForKey:@(storeId)];
        [self.db removeObjectForKey:@(storeId)];
        return exist;
    }
}

- (BOOL)removeEventsWithIds:(nonnull NSArray<NSNumber *> *)storeIds {
    BOOL result = YES;
    for (NSNumber *storeId in storeIds) {
        result = [self.db objectForKey:storeId];
        [self.db removeObjectForKey:storeId];
    }
    return result;
}

- (BOOL)removeAllEvents {
    @synchronized (self) {
        [self.db removeAllObjects];
        self.lastInsertedRow = -1;
    }
    return YES;
}

- (NSUInteger)count {
    return self.db.count;
}

- (nonnull NSArray<SPEmitterEvent *> *)emittableEventsWithQueryLimit:(NSUInteger)queryLimit {
    @synchronized (self) {
        NSMutableArray<NSNumber *> *eventIds = [NSMutableArray new];
        NSMutableArray<SPEmitterEvent *> *events = [NSMutableArray new];
        [self.db enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, SPPayload *obj, BOOL *stop) {
            SPPayload *payloadCopy = [[SPPayload alloc] initWithNSDictionary:[obj getAsDictionary]];
            SPEmitterEvent *event = [[SPEmitterEvent alloc] initWithPayload:payloadCopy storeId:key.longLongValue];
            [events addObject:event];
            [eventIds addObject:@(event.storeId)];
        }];
        if (queryLimit < events.count) {
            events = [events subarrayWithRange:NSMakeRange(0, queryLimit)].mutableCopy;
        }
        return events;
    }
}

@end


@interface SPMockConnection: NSObject <SPNetworkConnection>

@property NSInteger resultCode;
@property SPRequestOptions httpMethod;
@property NSURL *url;

- (instancetype)initWithResultCode:(NSInteger)resultCode method:(SPRequestOptions)httpMethod url:(NSString *)url;

@end

@implementation SPMockConnection

- (instancetype)initWithResultCode:(NSInteger)resultCode method:(SPRequestOptions)httpMethod url:(NSString *)url {
    if (self = [super init]) {
        self.resultCode = resultCode;
        self.httpMethod = httpMethod;
        self.url = [NSURL URLWithString:url];
    }
    return self;
}

- (NSArray<SPRequestResult *> *)sendRequests:(NSArray<SPRequest *> *)requests {
    BOOL isSuccess = self.resultCode == 200;
    NSMutableArray<SPRequestResult *> *results = [NSMutableArray new];
    for (SPRequest *request in requests) {
        SPRequestResult *result = [[SPRequestResult alloc] initWithSuccess:isSuccess storeIds:request.emitterEventIds];
        [results addObject:result];
    }
    return results;
}

@end

// MARK: - Tests

@interface TestRequest : XCTestCase <SPRequestCallback>

@end

@implementation TestRequest {
    NSInteger _successCount;
    NSInteger _failureCount;
}

- (void)setUp {
    [super setUp];
    _successCount = 0;
    _failureCount = 0;
}

- (void)tearDown {
    [super tearDown];
}

// Tests

- (void)testRequestSendWithPost {
    SPTracker * tracker = [self getTrackerWithRequestType:SPRequestOptionsPost resultCode:200];
    [self sendAll:tracker];
    [self forceFlushes:2 emitter:tracker.emitter];

    XCTAssertEqual(_successCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}


- (void)testRequestSendWithGet {
    SPTracker * tracker = [self getTrackerWithRequestType:SPRequestOptionsGet resultCode:200];
    [self sendAll:tracker];
    [self forceFlushes:2 emitter:tracker.emitter];
    XCTAssertEqual(_successCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithBadUrl {
    SPMockConnection *mockConnection = [[SPMockConnection alloc] initWithResultCode:404
                                                                             method:SPRequestOptionsPost
                                                                                url:@"https://acme.test.url.com/tp2"];
    SPMockStore *mockStore = [[SPMockStore alloc] init];

    // Send all events with a bad URL
    SPTracker *tracker = [self getTrackerWithConnection:mockConnection eventStore:mockStore];
    [self sendAll:tracker];
    [self forceFlushes:2 emitter:tracker.emitter];
    XCTAssertGreaterThan(_failureCount, 0);
    XCTAssertEqual(_successCount, 0);
    XCTAssertEqual([tracker.emitter getDbCount], 8);
    
    // Update the URL and flush
    [tracker pauseEventTracking];
    [NSThread sleepForTimeInterval:5];
    mockConnection.resultCode = 200;
    [tracker resumeEventTracking];
    
    [self forceFlushes:2 emitter:tracker.emitter];
    XCTAssertEqual(_successCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithoutSubject {
    SPTracker * tracker = [self getTrackerWithRequestType:SPRequestOptionsGet resultCode:200];
    [tracker setSubject:nil];
    [self sendAll:tracker];
    [self forceFlushes:2 emitter:tracker.emitter];
    XCTAssertEqual(_successCount, 8);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

- (void)testRequestSendWithCollectionOff {
    SPTracker * tracker = [self getTrackerWithRequestType:SPRequestOptionsPost resultCode:200];
    [tracker pauseEventTracking];
    [self sendAll:tracker];
    [self forceFlushes:2 emitter:tracker.emitter];
    XCTAssertEqual(_failureCount, 0);
    XCTAssertEqual(_successCount, 0);
    XCTAssertEqual([tracker.emitter getDbCount], 0);
}

// Helpers

- (SPTracker *)getTrackerWithConnection:(id<SPNetworkConnection>)mockNetworkConnection eventStore:(id<SPEventStore>)mockEventStore {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithNetworkConnection:mockNetworkConnection];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] initWithNamespace:@"aNamespace" appId:@"anAppId"];
    trackerConfig.platformContext = YES;
    trackerConfig.geoLocationContext = YES;
    trackerConfig.base64Encoding = NO;
    trackerConfig.sessionContext = YES;
    SPEmitterConfiguration *emitterConfig = [[SPEmitterConfiguration alloc] init];
    emitterConfig.requestCallback = self;
    emitterConfig.eventStore = mockEventStore;
    SPServiceProvider *serviceProvider = [[SPServiceProvider alloc] initWithNetwork:networkConfig tracker:trackerConfig configurations:@[emitterConfig]];
    return serviceProvider.tracker;
}

- (SPTracker *)getTrackerWithRequestType:(SPRequestOptions)type resultCode:(NSInteger)resultCode {
    SPMockConnection *mockConnection = [[SPMockConnection alloc] initWithResultCode:resultCode method:type url:@"https://acme.test.url.com/tp2"];
    SPMockStore *mockStore = [[SPMockStore alloc] init];

    return [self getTrackerWithConnection:mockConnection eventStore:mockStore];
}

- (void)forceFlushes:(NSInteger)count emitter:(SPEmitter *)emitter {
    [NSThread sleepForTimeInterval:3];
    for (int i = 0; i < count; i++) {
        [emitter flush];
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

- (void)sendAll:(SPTracker *)tracker {
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

- (void)trackStructuredEventWithTracker:(SPTracker *)tracker_ {
    SPStructured *event = [[SPStructured alloc] initWithCategory:@"DemoCategory" action:@"DemoAction"];
    event.label = @"DemoLabel";
    event.property = @"DemoProperty";
    event.value = @5;
    event.contexts = self.customContext;
    [tracker_ track:event];
}

- (void)trackUnstructuredEventWithTracker:(SPTracker *)tracker_ {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@23 forKey:@"level"];
    [data setObject:@56473 forKey:@"score"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    SPUnstructured *event = [[SPUnstructured alloc] initWithEventData:sdj];
    event.contexts = self.customContext;
    [tracker_ track:event];
}

- (void)trackSelfDescribingJsonEventWithTracker:(SPTracker *)tracker_ {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@23 forKey:@"level"];
    [data setObject:@56473 forKey:@"score"];
    SPSelfDescribingJson *sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                     andData:data];
    [tracker_ trackSelfDescribingEvent:sdj];
}

- (void)trackPageViewWithTracker:(SPTracker *)tracker_ {
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    event.pageTitle = @"DemoPageTitle";
    event.referrer = @"DemoPageReferrer";
    event.contexts = self.customContext;
    [tracker_ track:event];
}

- (void)trackScreenViewWithTracker:(SPTracker *)tracker_ {
    SPScreenView *event = [[SPScreenView alloc] initWithName:@"DemoScreenName" screenId:nil];
    event.contexts = self.customContext;
    [tracker_ track:event];
}

- (void)trackTimingWithCategoryWithTracker:(SPTracker *)tracker_ {
    SPTiming *event = [[SPTiming alloc] initWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:@5];
    event.label = @"DemoTimingLabel";
    event.contexts = self.customContext;
    [tracker_ track:event];
}

- (void)trackEcommerceTransactionWithTracker:(SPTracker *)tracker_ {
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    
    SPEcommerceItem *item = [[SPEcommerceItem alloc] initWithItemId:transactionID sku:@"DemoItemSku" price:@0.75F quantity:@1];
    [item name:@"DemoItemName"];
    [item category:@"DemoItemCategory"];
    [item currency:@"USD"];
    [item contexts:self.customContext];

    [itemArray addObject:item];
    
    SPEcommerce *event = [[SPEcommerce alloc] initWithOrderId:transactionID totalValue:@350 items:itemArray];
    [event affiliation:@"DemoTranAffiliation"];
    [event taxValue:@10];
    [event shipping:@15];
    [event city:@"Boston"];
    [event state:@"Massachusetts"];
    [event country:@"USA"];
    [event currency:@"USD"];
    [event contexts:self.customContext];
    [tracker_ track:event];
}

- (NSMutableArray *)customContext {
    NSDictionary *data = @{@"snowplow": @"demo-tracker"};
    SPSelfDescribingJson *context = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios/jsonschema/1-0-0"
                                                                         andData:data];
    return [NSMutableArray arrayWithArray:@[context]];
}

@end
