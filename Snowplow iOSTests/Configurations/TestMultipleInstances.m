//
//  TestMultipleInstances.m
//  Snowplow-iOSTests
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPServiceProvider.h"

@interface TestMultipleInstances : XCTestCase

@end

@implementation TestMultipleInstances

- (void)setUp {
    [SPSnowplow removeAllTrackers];
}

- (void)tearDown {
    [SPSnowplow removeAllTrackers];
}

- (void)testSingleInstanceIsReconfigurable {
    id<SPTrackerController> t1 = [SPSnowplow createTrackerWithNamespace:@"t1"network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake"]];
    XCTAssertEqualObjects(t1.network.endpoint, @"https://snowplowanalytics.fake/com.snowplowanalytics.snowplow/tp2");
    id<SPTrackerController> t2 = [SPSnowplow createTrackerWithNamespace:@"t1" network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake2"]];
    XCTAssertEqualObjects(t2.network.endpoint, @"https://snowplowanalytics.fake2/com.snowplowanalytics.snowplow/tp2");
    XCTAssertEqualObjects(@[@"t1"], [SPSnowplow instancedTrackerNamespaces]);
    XCTAssertEqual(t1, t2);
}

- (void)testMultipleInstances {
    id<SPTrackerController> t1 = [SPSnowplow createTrackerWithNamespace:@"t1"network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake"]];
    XCTAssertEqualObjects(t1.network.endpoint, @"https://snowplowanalytics.fake/com.snowplowanalytics.snowplow/tp2");
    id<SPTrackerController> t2 = [SPSnowplow createTrackerWithNamespace:@"t2" network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake2"]];
    XCTAssertEqualObjects(t2.network.endpoint, @"https://snowplowanalytics.fake2/com.snowplowanalytics.snowplow/tp2");
    XCTAssertNotEqual(t1, t2);
    NSSet<NSString *> *expectedNamespaces = [NSSet setWithArray:@[@"t1", @"t2"]];
    XCTAssertEqualObjects(expectedNamespaces, [NSSet setWithArray:[SPSnowplow instancedTrackerNamespaces]]);
}

- (void)testDefaultTracker {
    id<SPTrackerController> t1 = [SPSnowplow createTrackerWithNamespace:@"t1"network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake"]];
    [SPSnowplow createTrackerWithNamespace:@"t2" network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake2"]];
    id<SPTrackerController> td = [SPSnowplow defaultTracker];
    XCTAssertEqual(t1, td);
}

- (void)testUpdateDefaultTracker {
    [SPSnowplow createTrackerWithNamespace:@"t1"network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake"]];
    id<SPTrackerController> t2 = [SPSnowplow createTrackerWithNamespace:@"t2" network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake2"]];
    [SPSnowplow setTrackerAsDefault:t2];
    id<SPTrackerController> td = [SPSnowplow defaultTracker];
    XCTAssertEqual(t2, td);
}

- (void)testRemoveTracker {
    id<SPTrackerController> t1 = [SPSnowplow createTrackerWithNamespace:@"t1"network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake"]];
    id<SPTrackerController> t2 = [SPSnowplow createTrackerWithNamespace:@"t2" network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake2"]];
    [SPSnowplow removeTracker:t1];
    XCTAssertNotNil(t2);
    XCTAssertEqualObjects(@[@"t2"], [SPSnowplow instancedTrackerNamespaces]);
}

- (void)testRecreateTrackerWhichWasRemovedWithSameNamespace {
    id<SPTrackerController> t1 = [SPSnowplow createTrackerWithNamespace:@"t1"network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake"]];
    [SPSnowplow removeTracker:t1];
    id<SPTrackerController> t2 = [SPSnowplow createTrackerWithNamespace:@"t1" network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake2"]];
    XCTAssertNotEqual(t1, t2);
    XCTAssertEqualObjects(@[@"t1"], [SPSnowplow instancedTrackerNamespaces]);
}

- (void)testRemoveDefaultTracker {
    id<SPTrackerController> t1 = [SPSnowplow createTrackerWithNamespace:@"t1"network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake"]];
    [SPSnowplow removeTracker:t1];
    id<SPTrackerController> td = [SPSnowplow defaultTracker];
    XCTAssertNil(td);
    XCTAssertEqualObjects(@[], [SPSnowplow instancedTrackerNamespaces]);
}

- (void)testRemoveAllTrackers {
    [SPSnowplow createTrackerWithNamespace:@"t1"network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake"]];
    [SPSnowplow createTrackerWithNamespace:@"t2" network:[[SPNetworkConfiguration alloc] initWithEndpoint:@"snowplowanalytics.fake2"]];
    [SPSnowplow removeAllTrackers];
    XCTAssertEqualObjects(@[], [SPSnowplow instancedTrackerNamespaces]);
}

@end
