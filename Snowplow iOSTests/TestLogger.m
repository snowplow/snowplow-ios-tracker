//
//  TestLogger.m
//  Snowplow-iOSTests
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPLogger.h"

@interface MockDiagnosticLogger : NSObject <SPDiagnosticLogger>
@property (nonatomic) void (^callback)(NSString *tag, NSString *message, NSError *error, NSException *exception);
- (void)logWithTag:(NSString *)tag message:(NSString *)message error:(NSError *)error exception:(NSException *)exception;
@end

@implementation MockDiagnosticLogger

- (void)logWithTag:(NSString *)tag message:(NSString *)message error:(NSError *)error exception:(NSException *)exception {
    self.callback(tag, message, error, exception);
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
    MockDiagnosticLogger *diagnostic = [[MockDiagnosticLogger alloc] init];
    diagnostic.callback = ^(NSString *tag, NSString *message, NSError *error, NSException *exception) {
        XCTAssertEqualObjects(tag, NSStringFromClass(self.class));
        NSString *expectedMessage = [NSString stringWithFormat:@"Error test %d %@", 1, @12.3];
        XCTAssertEqualObjects(message, expectedMessage);
    };
    [SPLogger setDiagnosticLogger:diagnostic];

    SPLogTrack(nil, @"Error test %d %@", 1, @12.3);
}

- (void)testDiagnosticTrackingWithError {
    NSError *raisedError = [NSError errorWithDomain:NSURLErrorDomain code:400 userInfo:nil];

    MockDiagnosticLogger *diagnostic = [[MockDiagnosticLogger alloc] init];
    diagnostic.callback = ^(NSString *tag, NSString *message, NSError *error, NSException *exception) {
        XCTAssertEqualObjects(tag, NSStringFromClass(self.class));
        XCTAssertEqualObjects(message, @"Error test");
        XCTAssertEqual(error, raisedError);
    };
    [SPLogger setDiagnosticLogger:diagnostic];

    SPLogTrack(raisedError, @"Error test");
}

- (void)testDiagnosticTrackingWithException {
    NSException *raisedException = [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];

    MockDiagnosticLogger *diagnostic = [[MockDiagnosticLogger alloc] init];
    diagnostic.callback = ^(NSString *tag, NSString *message, NSError *error, NSException *exception) {
        XCTAssertEqualObjects(tag, NSStringFromClass(self.class));
        XCTAssertEqualObjects(message, @"Exception test");
        XCTAssertEqual(exception, raisedException);
    };
    [SPLogger setDiagnosticLogger:diagnostic];

    SPLogTrack(raisedException, @"Exception test");
}

@end
