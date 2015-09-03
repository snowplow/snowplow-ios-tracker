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
#import "SPEmitter.h"

@interface TestEmitter : XCTestCase

@end

@implementation TestEmitter

NSString *const TEST_SERVER_EMITTER = @"http://www.notarealurl.com";

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEmitterBuilderAndOptions {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:[NSURL URLWithString:TEST_SERVER_EMITTER]];
        [builder setBufferOption:SPBufferDefault];
        [builder setHttpMethod:SPRequestPost];
        [builder setEmitRange:500];
        [builder setEmitThreadPoolSize:30];
    }];
    
    NSString * url = [[NSString alloc] initWithFormat:@"%@/com.snowplowanalytics.snowplow/tp2", TEST_SERVER_EMITTER];
    
    // Test builder setting properly
    
    XCTAssertNil([emitter callback]);
    XCTAssertTrue([[[emitter urlEndpoint] absoluteString] isEqualToString:url]);
    XCTAssertEqual([emitter bufferOption], SPBufferDefault);
    XCTAssertEqual([emitter httpMethod], SPRequestPost);
    XCTAssertEqual([emitter emitRange], 500);
    XCTAssertEqual([emitter emitThreadPoolSize], 30);
    
    // Test setting variables to new values
    
    [emitter setUrlEndpoint:[NSURL URLWithString:@"http://www.test.com"]];
    url = [[NSString alloc] initWithFormat:@"http://www.test.com/com.snowplowanalytics.snowplow/tp2"];
    XCTAssertTrue([[[emitter urlEndpoint] absoluteString] isEqualToString:url]);
    [emitter setBufferOption:SPBufferInstant];
    XCTAssertEqual([emitter bufferOption], SPBufferInstant);
    [emitter setHttpMethod:SPRequestGet];
    XCTAssertEqual([emitter httpMethod], SPRequestGet);
    url = [[NSString alloc] initWithFormat:@"http://www.test.com/i"];
    XCTAssertTrue([[[emitter urlEndpoint] absoluteString] isEqualToString:url]);
    [emitter setEmitRange:1000];
    XCTAssertEqual([emitter emitRange], 1000);
    [emitter setEmitThreadPoolSize:50];
    XCTAssertEqual([emitter emitThreadPoolSize], 50);
    
    // Test extra functions
    XCTAssertTrue(![emitter getSendingStatus]);
    XCTAssertTrue([emitter getDbCount] >= 0);
    
    // Allow timer to be set
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [emitter setFutureBufferFlushWithTime:5];
}

- (void)testEmitterBuilderWithBadUrl {
    SPEmitter * emitter = nil;
    @try {
        emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
            [builder setUrlEndpoint:[NSURL URLWithString:@"this-is-a-bad-url"]];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"An invalid Emitter URL was found: this-is-a-bad-url"]);
    }
    @finally {
        XCTAssertNil(emitter);
    }
}

@end