//
//  TestRequest.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPTrackerConstants.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPRequestCallback.h"
#import "SPEvent.h"
#import "SPServiceProvider.h"

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
    @synchronized (self) {
        return self.db.count;
    }
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
@property SPHttpMethod httpMethod;
@property NSURL *url;

- (instancetype)initWithResultCode:(NSInteger)resultCode method:(SPHttpMethod)httpMethod url:(NSString *)url;

@end

@implementation SPMockConnection

- (instancetype)initWithResultCode:(NSInteger)resultCode method:(SPHttpMethod)httpMethod url:(NSString *)url {
    if (self = [super init]) {
        self.resultCode = resultCode;
        self.httpMethod = httpMethod;
        self.url = [NSURL URLWithString:url];
    }
    return self;
}

- (NSArray<SPRequestResult *> *)sendRequests:(NSArray<SPRequest *> *)requests {
    NSMutableArray<SPRequestResult *> *results = [NSMutableArray new];
    for (SPRequest *request in requests) {
        SPRequestResult *result = [[SPRequestResult alloc] initWithStatusCode:self.resultCode oversize:request.oversize storeIds:request.emitterEventIds];
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
    SPMockStore *mockStore = [[SPMockStore alloc] init];
    SPTracker * tracker = [self getTrackerWithRequestType:SPHttpMethodPost resultCode:200 eventStore:mockStore];
    int sentEventsCount = [self sendAll:tracker];
    [self forceFlushes:5 emitter:tracker.emitter];

    XCTAssertEqual(_successCount, sentEventsCount);
    XCTAssertEqual([tracker.emitter getDbCount], 0, @"Error on mockStore db: %@", mockStore.db);
}


- (void)testRequestSendWithGet {
    SPMockStore *mockStore = [[SPMockStore alloc] init];
    SPTracker * tracker = [self getTrackerWithRequestType:SPHttpMethodGet resultCode:200 eventStore:mockStore];
    int sentEventsCount = [self sendAll:tracker];
    [self forceFlushes:5 emitter:tracker.emitter];
    XCTAssertEqual(_successCount, sentEventsCount);
    XCTAssertEqual([tracker.emitter getDbCount], 0, @"Error on mockStore db: %@", mockStore.db);
}

- (void)testRequestSendWithBadUrl {
    SPMockConnection *mockConnection = [[SPMockConnection alloc] initWithResultCode:404
                                                                             method:SPHttpMethodPost
                                                                                url:@"https://acme.test.url.com/tp2"];
    SPMockStore *mockStore = [[SPMockStore alloc] init];

    // Send all events with a bad URL
    SPTracker *tracker = [self getTrackerWithConnection:mockConnection eventStore:mockStore];
    int sentEventsCount = [self sendAll:tracker];
    [self forceFlushes:5 emitter:tracker.emitter];
    XCTAssertGreaterThan(_failureCount, 0);
    XCTAssertEqual(_successCount, 0);
    XCTAssertEqual([tracker.emitter getDbCount], sentEventsCount, @"Error on mockStore db: %@", mockStore.db);
    
    // Update the URL and flush
    [tracker pauseEventTracking];
    [NSThread sleepForTimeInterval:5];
    mockConnection.resultCode = 200;
    [tracker resumeEventTracking];
    
    [self forceFlushes:5 emitter:tracker.emitter];
    XCTAssertEqual(_successCount, 7);
    XCTAssertEqual([tracker.emitter getDbCount], 0, @"Error on mockStore db: %@", mockStore.db);
}

- (void)testRequestSendWithoutSubject {
    SPMockStore *mockStore = [[SPMockStore alloc] init];
    SPTracker * tracker = [self getTrackerWithRequestType:SPHttpMethodGet resultCode:200 eventStore:mockStore];
    [tracker setSubject:nil];
    int sentEventsCount = [self sendAll:tracker];
    [self forceFlushes:5 emitter:tracker.emitter];
    XCTAssertEqual(_successCount, sentEventsCount);
    XCTAssertEqual([tracker.emitter getDbCount], 0, @"Error on mockStore db: %@", mockStore.db);
}

- (void)testRequestSendWithCollectionOff {
    SPMockStore *mockStore = [[SPMockStore alloc] init];
    SPTracker * tracker = [self getTrackerWithRequestType:SPHttpMethodPost resultCode:200 eventStore:mockStore];
    [tracker pauseEventTracking];
    [self sendAll:tracker];
    [self forceFlushes:5 emitter:tracker.emitter];
    XCTAssertEqual(_failureCount, 0);
    XCTAssertEqual(_successCount, 0);
    XCTAssertEqual([tracker.emitter getDbCount], 0, @"Error on mockStore db: %@", mockStore.db);
}

// Helpers

- (SPTracker *)getTrackerWithConnection:(id<SPNetworkConnection>)mockNetworkConnection eventStore:(id<SPEventStore>)mockEventStore {
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithNetworkConnection:mockNetworkConnection];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration new] appId:@"anAppId"];
    trackerConfig.platformContext = YES;
    trackerConfig.geoLocationContext = YES;
    trackerConfig.base64Encoding = NO;
    trackerConfig.sessionContext = YES;
    SPEmitterConfiguration *emitterConfig = [[SPEmitterConfiguration alloc] init];
    emitterConfig.requestCallback = self;
    emitterConfig.eventStore = mockEventStore;
    SPServiceProvider *serviceProvider = [[SPServiceProvider alloc] initWithNamespace:@"aNamespace" network:networkConfig configurations:@[trackerConfig, emitterConfig]];
    return serviceProvider.tracker;
}

- (SPTracker *)getTrackerWithRequestType:(SPHttpMethod)type resultCode:(NSInteger)resultCode eventStore:(id<SPEventStore>)mockEventStore {
    SPMockConnection *mockConnection = [[SPMockConnection alloc] initWithResultCode:resultCode method:type url:@"https://acme.test.url.com/tp2"];
    return [self getTrackerWithConnection:mockConnection eventStore:mockEventStore];
}

- (void)forceFlushes:(NSInteger)count emitter:(SPEmitter *)emitter {
    [NSThread sleepForTimeInterval:3];
    for (int i = 0; i < count; i++) {
        if ([emitter getDbCount] == 0) {
            break;
        }
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

- (int)sendAll:(SPTracker *)tracker {
    return  [self trackStructuredEventWithTracker:tracker]
    + [self trackUnstructuredEventWithTracker:tracker]
    + [self trackPageViewWithTracker:tracker]
    + [self trackScreenViewWithTracker:tracker]
    + [self trackTimingWithCategoryWithTracker:tracker]
    + [self trackEcommerceTransactionWithTracker:tracker];
}

- (int)trackStructuredEventWithTracker:(SPTracker *)tracker_ {
    SPStructured *event = [[SPStructured alloc] initWithCategory:@"DemoCategory" action:@"DemoAction"];
    event.label = @"DemoLabel";
    event.property = @"DemoProperty";
    event.value = @5;
    event.contexts = self.customContext;
    [tracker_ track:event];
    return 1;
}

- (int)trackUnstructuredEventWithTracker:(SPTracker *)tracker_ {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@23 forKey:@"level"];
    [data setObject:@56473 forKey:@"score"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios_event/jsonschema/1-0-0"
                                                                      andData:data];
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithEventData:sdj];
    event.contexts = self.customContext;
    [tracker_ track:event];
    return 1;
}

- (int)trackPageViewWithTracker:(SPTracker *)tracker_ {
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
    event.pageTitle = @"DemoPageTitle";
    event.referrer = @"DemoPageReferrer";
    event.contexts = self.customContext;
    [tracker_ track:event];
    return 1;
}

- (int)trackScreenViewWithTracker:(SPTracker *)tracker_ {
    SPScreenView *event = [[SPScreenView alloc] initWithName:@"DemoScreenName" screenId:nil];
    event.contexts = self.customContext;
    [tracker_ track:event];
    return 1;
}

- (int)trackTimingWithCategoryWithTracker:(SPTracker *)tracker_ {
    SPTiming *event = [[SPTiming alloc] initWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:@5];
    event.label = @"DemoTimingLabel";
    event.contexts = self.customContext;
    [tracker_ track:event];
    return 1;
}

- (int)trackEcommerceTransactionWithTracker:(SPTracker *)tracker_ {
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    
    SPEcommerceItem *item = [[SPEcommerceItem alloc] initWithSku:@"DemoItemSku" price:@0.75F quantity:@1];
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
    return 2;
}

- (NSMutableArray *)customContext {
    NSDictionary *data = @{@"snowplow": @"demo-tracker"};
    SPSelfDescribingJson *context = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.acme_company/demo_ios/jsonschema/1-0-0"
                                                                         andData:data];
    return [NSMutableArray arrayWithArray:@[context]];
}

@end
