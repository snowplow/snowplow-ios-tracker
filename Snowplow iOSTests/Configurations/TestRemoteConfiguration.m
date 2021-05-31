//
//  TestRemoteConfiguration.m
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
#import <Nocilla/Nocilla.h>

#import "SPFetchedConfigurationBundle.h"
#import "SPConfigurationFetcher.h"
#import "SPConfigurationCache.h"
#import "SPConfigurationProvider.h"

@interface TestRemoteConfiguration : XCTestCase
@end

@implementation TestRemoteConfiguration

- (void)testJSONToConfigurations {
    NSString *config = @"{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0\",\"configurationVersion\":12,\"configurationBundle\": [\
    {\"namespace\": \"default1\",\
    \"networkConfiguration\": {\"endpoint\":\"https://fake.snowplowanalytics.com\",\"method\":\"get\"},\
    \"trackerConfiguration\": {\"applicationContext\":false,\"screenContext\":false,},\
    \"sessionConfiguration\": {\"backgroundTimeout\":60,\"foregroundTimeout\":60}\
    },\
    {\"namespace\": \"default2\",\
    \"subjectConfiguration\": {\"userId\":\"testUserId\"}\
    }\
    ]}";
    NSError *jsonError = nil;
    NSData *jsonData = [config dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    
    SPFetchedConfigurationBundle *fetchedConfigurationBundle = [[SPFetchedConfigurationBundle alloc] initWithDictionary:dictionary];
    XCTAssertEqualObjects(@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", fetchedConfigurationBundle.schema);
    XCTAssertEqual(12, fetchedConfigurationBundle.configurationVersion);
    XCTAssertEqual(2, fetchedConfigurationBundle.configurationBundle.count);

    // Regular setup
    SPConfigurationBundle *configurationBundle = fetchedConfigurationBundle.configurationBundle[0];
    XCTAssertEqualObjects(@"default1", configurationBundle.namespace);
    XCTAssertNotNil(configurationBundle.networkConfiguration);
    XCTAssertNotNil(configurationBundle.trackerConfiguration);
    XCTAssertNotNil(configurationBundle.sessionConfiguration);
    XCTAssertNil(configurationBundle.subjectConfiguration);
    SPNetworkConfiguration *networkConfiguration = configurationBundle.networkConfiguration;
    XCTAssertEqual(SPHttpMethodGet, networkConfiguration.method);
    SPTrackerConfiguration *trackerConfiguration = configurationBundle.trackerConfiguration;
    XCTAssertFalse(trackerConfiguration.applicationContext);
    SPSessionConfiguration *sessionConfiguration = configurationBundle.sessionConfiguration;
    XCTAssertEqual(60, sessionConfiguration.backgroundTimeoutInSeconds);

    // Regular setup without NetworkConfiguration
    configurationBundle = fetchedConfigurationBundle.configurationBundle[1];
    XCTAssertEqualObjects(@"default2", configurationBundle.namespace);
    XCTAssertNil(configurationBundle.networkConfiguration);
    XCTAssertNotNil(configurationBundle.subjectConfiguration);
    SPSubjectConfiguration *subjectConfiguration = configurationBundle.subjectConfiguration;
    XCTAssertEqualObjects(@"testUserId", subjectConfiguration.userId);
}

- (void)testDownloadConfiguration {
    NSString *endpoint = @"https://fake-snowplowanalytics.com/config.json";

    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0\",\"configurationVersion\":12,\"configurationBundle\":[]}");
    XCTestExpectation *expectation = [XCTestExpectation new];

    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    [[SPConfigurationFetcher alloc] initWithRemoteSource:remoteConfig onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        XCTAssertNotNil(fetchedConfigurationBundle);
        XCTAssertEqualObjects(@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0", fetchedConfigurationBundle.schema);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:10];
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationCache {
    SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] initWithNamespace:@"namespace" networkConfiguration:[[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"]];
    SPFetchedConfigurationBundle *expected = [[SPFetchedConfigurationBundle alloc] init];
    expected.schema = @"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0";
    expected.configurationVersion = 12;
    expected.configurationBundle = @[bundle];
    
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    [cache writeCache:expected];
    
    [NSThread sleepForTimeInterval:5]; // wait the config is written on cache.
    
    cache = [SPConfigurationCache new];
    SPFetchedConfigurationBundle *config = [cache readCache];
    
    XCTAssertEqual(expected.configurationVersion, config.configurationVersion);
    XCTAssertEqualObjects(expected.schema, config.schema);
    XCTAssertEqual(expected.configurationBundle.count, config.configurationBundle.count);
    SPConfigurationBundle *expectedBundle = expected.configurationBundle[0];
    SPConfigurationBundle *configBundle = config.configurationBundle[0];
    XCTAssertEqualObjects(expectedBundle.networkConfiguration.endpoint, configBundle.networkConfiguration.endpoint);
    XCTAssertNil(configBundle.trackerConfiguration);
}

- (void)testConfigurationProvider_notDownloading_fails {
    // prepare test
    NSString *endpoint = @"https://fake-snowplowanalytics.com/config.json";
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(404);
    
    // test
    XCTestExpectation *expectation = [XCTestExpectation new];
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    [provider retrieveConfigurationOnlyRemote:NO onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        XCTFail();
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);

    // close test
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationProvider_downloadOfWrongSchema_fails {
    // prepare test
    NSString *endpoint = @"https://fake-snowplowanalytics.com/config.json";
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/2-0-0\",\"configurationVersion\":12,\"configurationBundle\":[]}");
    
    // test
    XCTestExpectation *expectation = [XCTestExpectation new];
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    [provider retrieveConfigurationOnlyRemote:NO onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        XCTFail();
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);

    // close test
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationProvider_downloadSameConfigVersionThanCached_dontUpdate {
    // prepare test
    NSString *endpoint = @"https://fake-snowplowanalytics.com/config.json";
    
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] initWithNamespace:@"namespace" networkConfiguration:[[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"]];
    SPFetchedConfigurationBundle *cached = [[SPFetchedConfigurationBundle alloc] init];
    cached.schema = @"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0";
    cached.configurationVersion = 1;
    cached.configurationBundle = @[bundle];
    [cache writeCache:cached];
    [NSThread sleepForTimeInterval:5]; // wait to write on cache
    
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":1,\"configurationBundle\":[]}");
    
    // test
    XCTestExpectation *expectation = [XCTestExpectation new];
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    __block int i = 0;
    [provider retrieveConfigurationOnlyRemote:NO onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        if (i == 1 || [fetchedConfigurationBundle.schema isEqualToString:@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0"]) {
            XCTFail();
        }
        if (i == 0 && [fetchedConfigurationBundle.schema isEqualToString:@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0"]) {
            i++;
        }
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);
    XCTAssertEqual(1, i);

    // close test
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationProvider_downloadHigherConfigVersionThanCached_doUpdate {
    // prepare test
    NSString *endpoint = @"https://fake-snowplowanalytics.com/config.json";
    
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] initWithNamespace:@"namespace" networkConfiguration:[[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"]];
    SPFetchedConfigurationBundle *cached = [[SPFetchedConfigurationBundle alloc] init];
    cached.schema = @"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0";
    cached.configurationVersion = 1;
    cached.configurationBundle = @[bundle];
    [cache writeCache:cached];
    [NSThread sleepForTimeInterval:5]; // wait to write on cache
    
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":2,\"configurationBundle\":[]}");
    
    // test
    XCTestExpectation *expectation = [XCTestExpectation new];
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    __block int i = 0;
    [provider retrieveConfigurationOnlyRemote:NO onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        if (i == 1 && [fetchedConfigurationBundle.schema isEqualToString:@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0"]) {
            i++;
        }
        if (i == 0 && [fetchedConfigurationBundle.schema isEqualToString:@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0"]) {
            i++;
        }
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);
    XCTAssertEqual(2, i);

    // close test
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationProvider_justRefresh_downloadSameConfigVersionThanCached_dontUpdate {
    // prepare test
    NSString *endpoint = @"https://fake-snowplowanalytics.com/config.json";
    
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] initWithNamespace:@"namespace" networkConfiguration:[[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"]];
    SPFetchedConfigurationBundle *cached = [[SPFetchedConfigurationBundle alloc] init];
    cached.schema = @"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0";
    cached.configurationVersion = 1;
    cached.configurationBundle = @[bundle];
    [cache writeCache:cached];
    [NSThread sleepForTimeInterval:5]; // wait to write on cache
    
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    XCTestExpectation *expectation = [XCTestExpectation new];
    [provider retrieveConfigurationOnlyRemote:NO onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:5];
    
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":1,\"configurationBundle\":[]}");
    
    // test
    expectation = [XCTestExpectation new];
    [provider retrieveConfigurationOnlyRemote:YES onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        XCTFail();
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);

    // close test
    [[LSNocilla sharedInstance] stop];
}

// TODO: Replace LSNocilla as it's unreliable and unsupported. It causes this test failure.
/*
- (void)testConfigurationProvider_justRefresh_downloadHigherConfigVersionThanCached_doUpdate {
    // prepare test
    NSString *endpoint = @"https://fake-snowplowanalytics.com/config.json";

    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] init];
    bundle.networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"];
    SPFetchedConfigurationBundle *cached = [[SPFetchedConfigurationBundle alloc] init];
    cached.schema = @"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0";
    cached.configurationVersion = 1;
    cached.configurationBundle = @[bundle];
    [cache writeCache:cached];
    [NSThread sleepForTimeInterval:5]; // wait to write on cache
    
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    XCTestExpectation *expectation = [XCTestExpectation new];
    [provider retrieveConfigurationOnlyRemote:NO onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:5];

    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"$schema\":\"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0\",\"configurationVersion\":2,\"configurationBundle\":[]}");

    // test
    expectation = [XCTestExpectation new];
    __block int i = 0;
    [provider retrieveConfigurationOnlyRemote:YES onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        if ([fetchedConfigurationBundle.schema isEqualToString:@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-1-0"]) {
            i++;
        }
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);
    XCTAssertEqual(1, i);

    // close test
    [[LSNocilla sharedInstance] stop];
}
*/

@end
