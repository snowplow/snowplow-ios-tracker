//
//  TestLogger.m
//  Snowplow-iOSTests
//
//  Created by Alex Benini on 16/07/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
