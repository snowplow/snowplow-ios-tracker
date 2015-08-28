//
//  TestSession.m
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
#import "SPSession.h"

@interface TestSession : XCTestCase

@end

@implementation TestSession

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    SPSession * session = [[SPSession alloc] init];
    XCTAssertTrue(![session getInBackground]);
    XCTAssertTrue([session getSessionIndex] >= 1);
    XCTAssertNotNil([session getSessionDict]);
    XCTAssertEqual([session foregroundTimeout], 600000);
    XCTAssertEqual([session backgroundTimeout], 300000);
    XCTAssertEqual([session checkInterval], 15);
}

- (void)testInitWithOptions {
    SPSession * session = [[SPSession alloc] initWithForegroundTimeout:5 andBackgroundTimeout:300 andCheckInterval:2];
    XCTAssertEqual([session foregroundTimeout], 5000);
    XCTAssertEqual([session backgroundTimeout], 300000);
    XCTAssertEqual([session checkInterval], 2);
}

- (void)testInitInBgThread {
    __block SPSession * session = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        session = [[SPSession alloc] initWithForegroundTimeout:1 andBackgroundTimeout:1 andCheckInterval:1];
    });
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [NSThread sleepForTimeInterval:1];
    XCTAssertNotNil(session);
}

- (void)testSessionFunction {
    SPSession * session = [[SPSession alloc] initWithForegroundTimeout:5 andBackgroundTimeout:1 andCheckInterval:2];
    NSInteger count = [session getSessionIndex];
    XCTAssertTrue(count > 0);
    
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:6]];
    [NSThread sleepForTimeInterval:1];
    
    XCTAssertEqual(count + 1, [session getSessionIndex]);
}

@end
