//
//  TestDataPersistence.m
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
#import "SPDataPersistence.h"

@interface TestDataPersistence : XCTestCase

@end

@implementation TestDataPersistence

- (void)setUp {
    [SPDataPersistence removeDataPersistenceWithNamespace:@"namespace"];
    [SPDataPersistence removeDataPersistenceWithNamespace:@"namespace1"];
    [SPDataPersistence removeDataPersistenceWithNamespace:@"namespace2"];
}

- (void)testStringFromNamespace {
    XCTAssertEqualObjects(@"abc-1_2_3", [SPDataPersistence stringFromNamespace:@"abc 1_2_3"]);
}

- (void)testDataPersistenceForNamespaceWithDifferentNamespaces {
    SPDataPersistence *dp1 = [SPDataPersistence dataPersistenceForNamespace:@"namespace1"];
    SPDataPersistence *dp2 = [SPDataPersistence dataPersistenceForNamespace:@"namespace2"];
    XCTAssertNotEqual(dp1, dp2);
}

- (void)testDataPersistenceForNamespaceWithSameNamespaces {
    SPDataPersistence *dp1 = [SPDataPersistence dataPersistenceForNamespace:@"namespace"];
    SPDataPersistence *dp2 = [SPDataPersistence dataPersistenceForNamespace:@"namespace"];
    XCTAssertEqual(dp1, dp2);
}

- (void)testRemoveDataPersistenceForNamespace {
    SPDataPersistence *dp1 = [SPDataPersistence dataPersistenceForNamespace:@"namespace"];
    [SPDataPersistence removeDataPersistenceWithNamespace:@"namespace"];
    SPDataPersistence *dp2 = [SPDataPersistence dataPersistenceForNamespace:@"namespace"];
    XCTAssertNotEqual(dp1, dp2);
}

- (void)testDataIsCorrectlyStored {
    [self commonTestDataIsCorrectlyStoredOnFile:YES];
}

- (void)testDataIsCorrectlyStoredWhenNotStoredOnFile {
    [self commonTestDataIsCorrectlyStoredOnFile:NO];
}

- (void)commonTestDataIsCorrectlyStoredOnFile:(BOOL)isStoredOnFile {
    SPDataPersistence *dp = [SPDataPersistence dataPersistenceForNamespace:@"namespace" storedOnFile:isStoredOnFile];
    NSDictionary<NSString *, NSObject *> *session = @{@"key": @"value"};
    dp.session = session;
    XCTAssertEqualObjects(session, dp.session);
    XCTAssertEqualObjects(session, dp.data[@"session"]);
    // Override session
    session = @{@"key2": @"value2"};
    dp.session = session;
    XCTAssertEqualObjects(session, dp.session);
    XCTAssertEqualObjects(session, dp.data[@"session"]);
}

- (void)testDataIsStoredWithoutInterference {
    [self commonTestDataIsStoredWithoutInterferenceStoredOnFile:YES];
}

- (void)testDataIsStoredWithoutInterferenceWhenNotStoredOnFile {
    [self commonTestDataIsStoredWithoutInterferenceStoredOnFile:NO];
}

- (void)commonTestDataIsStoredWithoutInterferenceStoredOnFile:(BOOL)isStoredOnFile {
    SPDataPersistence *dp1 = [SPDataPersistence dataPersistenceForNamespace:@"namespace1" storedOnFile:isStoredOnFile];
    SPDataPersistence *dp2 = [SPDataPersistence dataPersistenceForNamespace:@"namespace2" storedOnFile:isStoredOnFile];
    NSDictionary<NSString *, NSObject *> *session = @{@"key": @"value"};
    dp1.session = session;
    // Check dp1
    XCTAssertEqualObjects(session, dp1.session);
    XCTAssertEqualObjects(session, dp1.data[@"session"]);
    // Check dp2
    XCTAssertNotEqualObjects(session, dp2.session);
    XCTAssertNotEqualObjects(session, dp2.data[@"session"]);
}

@end
