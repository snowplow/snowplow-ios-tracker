//
//  TestEmitter.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "Snowplow.h"
#import "SPEmitter.h"
#import "SPLogger.h"


@interface SPBrokenNetworkConnection : NSObject <SPNetworkConnection>
@end

@implementation SPBrokenNetworkConnection

- (NSArray<SPRequestResult *> *)sendRequests:(NSArray<SPRequest *> *)requests {
    [NSException raise:@"BrokenNetworkConnection" format:@"Fake exception on network connection."];
    return nil;
}

- (NSURL *)url {
    [NSException raise:@"BrokenNetworkConnection" format:@"Fake exception on network connection."];
    return nil;
}

- (SPRequestOptions)httpMethod {
    [NSException raise:@"BrokenNetworkConnection" format:@"Fake exception on network connection."];
    return SPRequestGet;
}

@end


@interface SPMockNetworkConnection : NSObject <SPNetworkConnection>

@property (nonatomic) BOOL successfulConnection;
@property (nonatomic) SPRequestOptions httpMethod;
@property (nonatomic) NSMutableArray<NSMutableArray<SPRequestResult *> *> *previousResults;

@end

@implementation SPMockNetworkConnection

- initWithRequestOption:(SPRequestOptions)httpMethod successfulConnection:(BOOL)successfulConnection {
    if (self = [super init]) {
        self.httpMethod = httpMethod;
        self.successfulConnection = successfulConnection;
        self.previousResults = [NSMutableArray new];
    }
    return self;
}

- (nonnull NSArray<SPRequestResult *> *)sendRequests:(nonnull NSArray<SPRequest *> *)requests {
    NSMutableArray<SPRequestResult *> *requestResults = [NSMutableArray new];
    for (SPRequest *request in requests) {
        BOOL isSuccessful = request.oversize || self.successfulConnection;
        SPRequestResult *result = [[SPRequestResult alloc] initWithSuccess:isSuccessful storeIds:request.emitterEventIds];
        SPLogVerbose(@"Sent %@ with success %@", request.emitterEventIds, isSuccessful ? @"YES" : @"NO");
        [requestResults addObject:result];
    }
    [self.previousResults addObject:requestResults];
    return requestResults;
}

- (SPRequestOptions)httpMethod {
    return _httpMethod;
}

- (nonnull NSURL *)url {
    return [NSURL URLWithString:@"http://fake-url.com"];
}

- (NSUInteger)sendingCount {
    return self.previousResults.count;
}

@end


@interface SPMockEventStore : NSObject <SPEventStore>

@property (nonatomic) NSMutableDictionary<NSNumber *, SPPayload *> *db;
@property (nonatomic) long lastInsertedRow;

@end

@implementation SPMockEventStore

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
        SPLogVerbose(@"Add %@", payload);
        [self.db setObject:payload forKey:@(self.lastInsertedRow)];
    }
}

- (BOOL)removeEventWithId:(long long)storeId {
    @synchronized (self) {
        SPLogVerbose(@"Remove %lld", storeId);
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
        SPLogVerbose(@"emittableEventsWithQueryLimit: %@", eventIds);
        return events;
    }
}

@end


@interface TestEmitter : XCTestCase

@end

@implementation TestEmitter

NSString *const TEST_SERVER_EMITTER = @"www.notarealurl.com";

- (void)setUp {
    [super setUp];
    [SPLogger setLogLevel:SPLogLevelVerbose];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEmitterBuilderAndOptions {
    NSString * protocol = @"https";
    
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:TEST_SERVER_EMITTER];
        [builder setHttpMethod:SPRequestPost];
        [builder setEmitRange:500];
        [builder setEmitThreadPoolSize:30];
        [builder setByteLimitGet:30000];
        [builder setByteLimitPost:35000];
        [builder setProtocol:SPHttps];
    }];
    
    NSString * url = [[NSString alloc] initWithFormat:@"%@://%@/com.snowplowanalytics.snowplow/tp2", protocol, TEST_SERVER_EMITTER];
    
    // Test builder setting properly
    
    XCTAssertNil([emitter callback]);
    XCTAssertTrue([[[emitter urlEndpoint] absoluteString] isEqualToString:url]);
    XCTAssertEqual([emitter httpMethod], SPRequestPost);
    XCTAssertEqual([emitter emitRange], 500);
    XCTAssertEqual([emitter emitThreadPoolSize], 30);
    XCTAssertEqual([emitter byteLimitGet], 30000);
    XCTAssertEqual([emitter byteLimitPost], 35000);
    XCTAssertEqual([emitter protocol], SPHttps);
    
    SPEmitter * customPathEmitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:TEST_SERVER_EMITTER];
        [builder setHttpMethod:SPRequestPost];
        [builder setCustomPostPath:@"/com.acme.company/tpx"];
        [builder setEmitRange:500];
        [builder setEmitThreadPoolSize:30];
        [builder setByteLimitGet:30000];
        [builder setByteLimitPost:35000];
        [builder setProtocol:SPHttps];
    }];
    
    NSString * customUrl = [[NSString alloc] initWithFormat:@"%@://%@/com.acme.company/tpx", protocol, TEST_SERVER_EMITTER];
    XCTAssertTrue([[[customPathEmitter urlEndpoint] absoluteString] isEqualToString:customUrl]);
    
    // Test setting variables to new values
    
    [emitter setUrlEndpoint:@"www.test.com"];
    url = [[NSString alloc] initWithFormat:@"%@://www.test.com/com.snowplowanalytics.snowplow/tp2", protocol];
    XCTAssertTrue([[[emitter urlEndpoint] absoluteString] isEqualToString:url]);
    [emitter setHttpMethod:SPRequestGet];
    XCTAssertEqual([emitter httpMethod], SPRequestGet);
    url = [[NSString alloc] initWithFormat:@"%@://www.test.com/i", protocol];
    XCTAssertTrue([[[emitter urlEndpoint] absoluteString] isEqualToString:url]);
    [emitter setEmitRange:1000];
    XCTAssertEqual([emitter emitRange], 1000);
    [emitter setEmitThreadPoolSize:50];
    XCTAssertEqual([emitter emitThreadPoolSize], 50);
    [emitter setByteLimitGet:1000];
    XCTAssertEqual([emitter byteLimitGet], 1000);
    [emitter setByteLimitPost:50];
    XCTAssertEqual([emitter byteLimitPost], 50);
    
    // Test extra functions
    XCTAssertTrue(![emitter getSendingStatus]);
    XCTAssertTrue([emitter getDbCount] >= 0);
    
    // Allow timer to be set
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [emitter startTimerFlush];
}

// MARK: - Emitting tests

- (void)testEmitEventWithBrokenNetworkConnectionDoesntFreezeEmitterStatus {
    id<SPNetworkConnection> networkConnection = [SPBrokenNetworkConnection new];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    [NSThread sleepForTimeInterval:1];
    
    XCTAssertFalse([emitter getSendingStatus]);
    
    [emitter flushBuffer];
}

- (void)testEmitSingleGetEventWithSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPRequestGet successfulConnection:YES];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(1, networkConnection.previousResults.count);
    XCTAssertEqual(1, networkConnection.previousResults.firstObject.count);
    XCTAssertTrue([networkConnection.previousResults.firstObject.firstObject isSuccessful]);
    XCTAssertEqual(0, [emitter getDbCount]);
    
    [emitter flushBuffer];
}

- (void)testEmitSingleGetEventWithNoSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPRequestGet successfulConnection:NO];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(1, networkConnection.previousResults.count);
    XCTAssertEqual(1, networkConnection.previousResults.firstObject.count);
    XCTAssertFalse([networkConnection.previousResults.firstObject.firstObject isSuccessful]);
    XCTAssertEqual(1, [emitter getDbCount]);
    
    [emitter flushBuffer];
}

- (void)testEmitTwoGetEventsWithSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPRequestGet successfulConnection:YES];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    
    for (SPPayload *payload in [self generatePayloads:2]) {
        [emitter addPayloadToBuffer:payload];
    }
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 2 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(0, [emitter getDbCount]);
    int totEvents = 0;
    for (NSArray<SPRequestResult *> *results in networkConnection.previousResults) {
        for (SPRequestResult *result in results) {
            XCTAssertTrue(result.isSuccessful);
            totEvents += result.storeIds.count;
        }
    }
    XCTAssertEqual(2, totEvents);
    
    [emitter flushBuffer];
}

- (void)testEmitTwoGetEventsWithNoSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPRequestGet successfulConnection:NO];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];

    for (SPPayload *payload in [self generatePayloads:2]) {
        [emitter addPayloadToBuffer:payload];
    }
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 2 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(2, [emitter getDbCount]);
    for (NSArray<SPRequestResult *> *results in networkConnection.previousResults) {
        for (SPRequestResult *result in results) {
            XCTAssertFalse(result.isSuccessful);
        }
    }
    
    [emitter flushBuffer];
}

- (void)testEmitSinglePostEventWithSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPRequestPost successfulConnection:YES];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    
    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(1, networkConnection.previousResults.count);
    XCTAssertEqual(1, networkConnection.previousResults.firstObject.count);
    XCTAssertTrue([networkConnection.previousResults.firstObject.firstObject isSuccessful]);
    XCTAssertEqual(0, [emitter getDbCount]);
    
    [emitter flushBuffer];
}

- (void)testEmitEventsPostAsGroup {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPRequestPost successfulConnection:NO];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionDefaultGroup];
    
    NSArray<SPPayload *> *payloads = [self generatePayloads:15];
    for (int i = 0; i < 14; i++) {
        [emitter addPayloadToBuffer:payloads[i]];
    }
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(14, [emitter getDbCount]);
    networkConnection.successfulConnection = YES;
    NSUInteger prevSendingCount = [networkConnection sendingCount];
    [emitter addPayloadToBuffer:payloads[14]];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] - prevSendingCount < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(0, [emitter getDbCount]);
    int totEvents = 0;
    BOOL areGrouped = NO;
    NSArray<NSArray<SPRequestResult *> *> *prevResults =
    [networkConnection.previousResults subarrayWithRange:NSMakeRange(prevSendingCount, networkConnection.previousResults.count - prevSendingCount)];
    for (NSArray<SPRequestResult *> *results in prevResults) {
        for (SPRequestResult *result in results) {
            XCTAssertTrue(result.isSuccessful);
            NSUInteger ids = result.storeIds.count;
            totEvents += ids;
            areGrouped = areGrouped || ids > 1;
        }
    }
    XCTAssertEqual(15, totEvents);
    XCTAssertTrue(areGrouped);
    
    [emitter flushBuffer];
}

- (void)testEmitOversizeEventsPostAsGroup {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPRequestPost successfulConnection:NO];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection build:^(id<SPEmitterBuilder> builder) {
        [builder setBufferOption:SPBufferOptionDefaultGroup];
        [builder setByteLimitPost:5];
    }];
    
    NSArray<SPPayload *> *payloads = [self generatePayloads:15];
    for (int i = 0; i < 14; i++) {
        [emitter addPayloadToBuffer:payloads[i]];
    }
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(0, [emitter getDbCount]);
    networkConnection.successfulConnection = YES;
    NSUInteger prevSendingCount = [networkConnection sendingCount];
    [emitter addPayloadToBuffer:payloads[14]];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] - prevSendingCount < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(0, [emitter getDbCount]);
    
    [emitter flushBuffer];
}

// MARK: - Emitter builder

- (SPEmitter *)emitterWithNetworkConnection:(id<SPNetworkConnection>)networkConnection bufferOption:(SPBufferOption)bufferOption {
    return [self emitterWithNetworkConnection:networkConnection build:^(id<SPEmitterBuilder> builder) {
        [builder setBufferOption:bufferOption];
    }];
}

- (SPEmitter *)emitterWithNetworkConnection:(id<SPNetworkConnection>)networkConnection build:(void(^)(id<SPEmitterBuilder>builder))buildBlock {
    return [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setNetworkConnection:networkConnection];
        [builder setBufferOption:SPBufferOptionSingle];
        [builder setEmitRange:200];
        [builder setByteLimitGet:20000];
        [builder setByteLimitPost:25000];
        [builder setEventStore:[SPMockEventStore new]];
        buildBlock(builder);
    }];
}

// MARK: - Service methods

- (NSArray<SPPayload *> *)generatePayloads:(int)count {
    NSMutableArray<SPPayload *> *payloads = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        SPPayload *payload = [SPPayload new];
        [payload addValueToPayload:@(i).description forKey:@"a"];
        [payloads addObject:payload];
    }
    return payloads;
}

@end
