//
//  TestEmitter.m
//  Snowplow
//
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "Snowplow.h"
#import "SPEmitter.h"

@interface TestEmitter : XCTestCase

@end

@implementation TestEmitter

NSString *const TEST_SERVER_EMITTER = @"www.notarealurl.com";

- (void)setUp {
    [super setUp];
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

@end