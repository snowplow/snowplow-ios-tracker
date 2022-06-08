//
//  LegacyTestEmitter.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPTrackerConstants.h"
#import "SPEmitter.h"
#import "SPLogger.h"
#import "SPMockEventStore.h"
#import "SPMockNetworkConnection.h"


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

- (SPHttpMethod)httpMethod {
    [NSException raise:@"BrokenNetworkConnection" format:@"Fake exception on network connection."];
    return SPHttpMethodGet;
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface LegacyTestEmitter : XCTestCase

@end

@implementation LegacyTestEmitter

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
        [builder setHttpMethod:SPHttpMethodPost];
        [builder setEmitRange:500];
        [builder setEmitThreadPoolSize:30];
        [builder setByteLimitGet:30000];
        [builder setByteLimitPost:35000];
        [builder setProtocol:SPProtocolHttps];
    }];
    
    NSString * url = [[NSString alloc] initWithFormat:@"%@://%@/com.snowplowanalytics.snowplow/tp2", protocol, TEST_SERVER_EMITTER];
    
    // Test builder setting properly
    
    XCTAssertNil([emitter callback]);
    XCTAssertTrue([[[emitter urlEndpoint] absoluteString] isEqualToString:url]);
    XCTAssertEqual([emitter httpMethod], SPHttpMethodPost);
    XCTAssertEqual([emitter emitRange], 500);
    XCTAssertEqual([emitter emitThreadPoolSize], 30);
    XCTAssertEqual([emitter byteLimitGet], 30000);
    XCTAssertEqual([emitter byteLimitPost], 35000);
    XCTAssertEqual([emitter protocol], SPProtocolHttps);
    
    SPEmitter * customPathEmitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:TEST_SERVER_EMITTER];
        [builder setHttpMethod:SPHttpMethodPost];
        [builder setCustomPostPath:@"/com.acme.company/tpx"];
        [builder setEmitRange:500];
        [builder setEmitThreadPoolSize:30];
        [builder setByteLimitGet:30000];
        [builder setByteLimitPost:35000];
        [builder setProtocol:SPProtocolHttps];
    }];
    
    NSString * customUrl = [[NSString alloc] initWithFormat:@"%@://%@/com.acme.company/tpx", protocol, TEST_SERVER_EMITTER];
    XCTAssertTrue([[[customPathEmitter urlEndpoint] absoluteString] isEqualToString:customUrl]);
    
    // Test setting variables to new values
    
    [emitter setUrlEndpoint:@"www.test.com"];
    url = [[NSString alloc] initWithFormat:@"%@://www.test.com/com.snowplowanalytics.snowplow/tp2", protocol];
    XCTAssertTrue([[[emitter urlEndpoint] absoluteString] isEqualToString:url]);
    [emitter setHttpMethod:SPHttpMethodGet];
    XCTAssertEqual([emitter httpMethod], SPHttpMethodGet);
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
    [emitter resumeTimer];
}

// MARK: - Emitting tests

- (void)testEmitEventWithBrokenNetworkConnectionDoesntFreezeEmitterStatus {
    id<SPNetworkConnection> networkConnection = [SPBrokenNetworkConnection new];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    [NSThread sleepForTimeInterval:1];
    
    XCTAssertFalse([emitter getSendingStatus]);
    
    [emitter flush];
}

- (void)testEmitSingleGetEventWithSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodGet statusCode:200];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(1, networkConnection.previousResults.count);
    XCTAssertEqual(1, networkConnection.previousResults.firstObject.count);
    XCTAssertTrue([networkConnection.previousResults.firstObject.firstObject isSuccessful]);
    XCTAssertEqual(0, [emitter getDbCount]);
    
    [emitter flush];
}

- (void)testEmitSingleGetEventWithNoSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodGet statusCode:500];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(1, networkConnection.previousResults.count);
    XCTAssertEqual(1, networkConnection.previousResults.firstObject.count);
    XCTAssertFalse([networkConnection.previousResults.firstObject.firstObject isSuccessful]);
    XCTAssertEqual(1, [emitter getDbCount]);
    
    [emitter flush];
}

- (void)testEmitTwoGetEventsWithSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodGet statusCode:200];
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
    
    [emitter flush];
}

- (void)testEmitTwoGetEventsWithNoSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodGet statusCode:500];
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
    
    [emitter flush];
}

- (void)testEmitSinglePostEventWithSuccess {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodPost statusCode:200];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    
    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(1, networkConnection.previousResults.count);
    XCTAssertEqual(1, networkConnection.previousResults.firstObject.count);
    XCTAssertTrue([networkConnection.previousResults.firstObject.firstObject isSuccessful]);
    XCTAssertEqual(0, [emitter getDbCount]);
    
    [emitter flush];
}

- (void)testEmitEventsPostAsGroup {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodPost statusCode:500];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionDefaultGroup];
    
    NSArray<SPPayload *> *payloads = [self generatePayloads:15];
    for (int i = 0; i < 14; i++) {
        [emitter addPayloadToBuffer:payloads[i]];
    }
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(14, [emitter getDbCount]);
    networkConnection.statusCode = 200;
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
    
    [emitter flush];
}

- (void)testEmitOversizeEventsPostAsGroup {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodPost statusCode:500];
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
    networkConnection.statusCode = 200;
    NSUInteger prevSendingCount = [networkConnection sendingCount];
    [emitter addPayloadToBuffer:payloads[14]];
    
    for (int i = 0; i < 10 && ([networkConnection sendingCount] - prevSendingCount < 1 || [emitter getSendingStatus]); i++) {
        [NSThread sleepForTimeInterval:1];
    }

    XCTAssertEqual(0, [emitter getDbCount]);
    
    [emitter flush];
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

- (void)testRemovesEventsFromQueueOnNoRetryStatus {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodGet statusCode:403];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];

    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    [NSThread sleepForTimeInterval:1];

    XCTAssertEqual(0, [emitter getDbCount]);
    for (NSArray<SPRequestResult *> *results in networkConnection.previousResults) {
        for (SPRequestResult *result in results) {
            XCTAssertFalse(result.isSuccessful);
        }
    }

    [emitter flush];
}

- (void)testFollowCustomRetryRules {
    SPMockNetworkConnection *networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodGet statusCode:500];
    SPEmitter *emitter = [self emitterWithNetworkConnection:networkConnection bufferOption:SPBufferOptionSingle];
    
    NSMutableDictionary *customRules = [[NSMutableDictionary alloc] init];
    [customRules setObject:@YES forKey:@403];
    [customRules setObject:@NO forKey:@500];
    [emitter setCustomRetryForStatusCodes:customRules];

    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    [NSThread sleepForTimeInterval:1];

    // no events in queue since they were dropped because retrying is disabled for 500
    XCTAssertEqual(0, [emitter getDbCount]);
    
    networkConnection.statusCode = 403;

    [emitter addPayloadToBuffer:[self generatePayloads:1].firstObject];
    
    [NSThread sleepForTimeInterval:1];

    // event still in queue because retrying is enabled for 403
    XCTAssertEqual(1, [emitter getDbCount]);

    [emitter flush];
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

#pragma clang diagnostic pop
