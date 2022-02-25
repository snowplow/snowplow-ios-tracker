//
//  TestLogger.m
//  Snowplow-iOSTests
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
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPLogger.h"

@interface MockDiagnosticLogger : NSObject
@property (nonatomic) void (^callback)(NSString *tag, NSString *message, NSError *error, NSException *exception);
@end

@implementation MockDiagnosticLogger

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logDiagnosticError:) name:@"SPTrackerDiagnostic" object:nil];
    }
    return self;
}

- (void)logDiagnosticError:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *tag = [userInfo objectForKey:@"tag"];
    NSString *message = [userInfo objectForKey:@"message"];
    NSError *error = [userInfo objectForKey:@"error"];
    NSException *exception = [userInfo objectForKey:@"exception"];
    self.callback(tag, message, error, exception);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@interface TestLogger : XCTestCase

@end

@implementation TestLogger

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDiagnosticTracking {
    XCTestExpectation *expectation = [XCTestExpectation new];
    MockDiagnosticLogger *diagnostic = [[MockDiagnosticLogger alloc] init];
    diagnostic.callback = ^(NSString *tag, NSString *message, NSError *error, NSException *exception) {
        XCTAssertEqualObjects(tag, NSStringFromClass(self.class));
        NSString *expectedMessage = [NSString stringWithFormat:@"Error test %d %@", 1, @12.3];
        XCTAssertEqualObjects(message, expectedMessage);
        [expectation fulfill];
    };

    SPLogTrack(nil, @"Error test %d %@", 1, @12.3);
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testDiagnosticTrackingWithError {
    XCTestExpectation *expectation = [XCTestExpectation new];
    NSError *raisedError = [NSError errorWithDomain:NSURLErrorDomain code:400 userInfo:nil];

    MockDiagnosticLogger *diagnostic = [[MockDiagnosticLogger alloc] init];
    diagnostic.callback = ^(NSString *tag, NSString *message, NSError *error, NSException *exception) {
        XCTAssertEqualObjects(tag, NSStringFromClass(self.class));
        XCTAssertEqualObjects(message, @"Error test");
        XCTAssertEqual(error, raisedError);
        [expectation fulfill];
    };

    SPLogTrack(raisedError, @"Error test");
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testDiagnosticTrackingWithException {
    XCTestExpectation *expectation = [XCTestExpectation new];
    NSException *raisedException = [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];

    MockDiagnosticLogger *diagnostic = [[MockDiagnosticLogger alloc] init];
    diagnostic.callback = ^(NSString *tag, NSString *message, NSError *error, NSException *exception) {
        XCTAssertEqualObjects(tag, NSStringFromClass(self.class));
        XCTAssertEqualObjects(message, @"Exception test");
        XCTAssertEqual(exception, raisedException);
        [expectation fulfill];
    };

    SPLogTrack(raisedException, @"Exception test");
    [self waitForExpectations:@[expectation] timeout:10];
}

@end
