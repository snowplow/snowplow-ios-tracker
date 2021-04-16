//
//  TestRemoteConfiguration.m
//  Snowplow-iOSTests
//
//  Created by Alex Benini on 03/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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
    NSString *config = @"{\"formatVersion\":\"1.2\",\"configurationVersion\":12,\"configurationBundle\": [\
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
    XCTAssertEqualObjects(@"1.2", fetchedConfigurationBundle.formatVersion);
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
    NSString *endpoint = @"https://snowplowanalytics.com/config.json";

    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"formatVersion\":\"1.2\",\"configurationVersion\":12,\"configurationBundle\":[]}");
    XCTestExpectation *expectation = [XCTestExpectation new];

    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    [[SPConfigurationFetcher alloc] initWithRemoteSource:remoteConfig onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        XCTAssertNotNil(fetchedConfigurationBundle);
        XCTAssertEqualObjects(@"1.2", fetchedConfigurationBundle.formatVersion);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:10];
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationCache {
    SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] init];
    bundle.networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"];
    SPFetchedConfigurationBundle *expected = [[SPFetchedConfigurationBundle alloc] init];
    expected.formatVersion = @"1.2";
    expected.configurationVersion = 12;
    expected.configurationBundle = @[bundle];
    
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    [cache writeCache:expected];
    
    [NSThread sleepForTimeInterval:5]; // wait the config is written on cache.
    
    cache = [SPConfigurationCache new];
    SPFetchedConfigurationBundle *config = [cache readCache];
    
    XCTAssertEqual(expected.configurationVersion, config.configurationVersion);
    XCTAssertEqualObjects(expected.formatVersion, config.formatVersion);
    XCTAssertEqual(expected.configurationBundle.count, config.configurationBundle.count);
    SPConfigurationBundle *expectedBundle = expected.configurationBundle[0];
    SPConfigurationBundle *configBundle = config.configurationBundle[0];
    XCTAssertEqualObjects(expectedBundle.networkConfiguration.endpoint, configBundle.networkConfiguration.endpoint);
    XCTAssertNil(configBundle.trackerConfiguration);
}

- (void)testConfigurationProvider_notDownloading_fails {
    // prepare test
    NSString *endpoint = @"https://snowplowanalytics.com/config.json";
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(404);
    
    // test
    XCTestExpectation *expectation = [XCTestExpectation new];
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    [provider retrieveConfiguration:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        XCTFail();
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);

    // close test
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationProvider_downloadOfWrongFormatVersion_fails {
    // prepare test
    NSString *endpoint = @"https://snowplowanalytics.com/config.json";
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"formatVersion\":\"2.0\",\"configurationVersion\":12,\"configurationBundle\":[]}");
    
    // test
    XCTestExpectation *expectation = [XCTestExpectation new];
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    [provider retrieveConfiguration:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        XCTFail();
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);

    // close test
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationProvider_downloadSameConfigVersionThanCached_dontUpdate {
    // prepare test
    NSString *endpoint = @"https://snowplowanalytics.com/config.json";
    
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] init];
    bundle.networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"];
    SPFetchedConfigurationBundle *cached = [[SPFetchedConfigurationBundle alloc] init];
    cached.formatVersion = @"1.0";
    cached.configurationVersion = 1;
    cached.configurationBundle = @[bundle];
    [cache writeCache:cached];
    [NSThread sleepForTimeInterval:5]; // wait to write on cache
    
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"formatVersion\":\"1.1\",\"configurationVersion\":1,\"configurationBundle\":[]}");
    
    // test
    XCTestExpectation *expectation = [XCTestExpectation new];
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    __block int i = 0;
    [provider retrieveConfiguration:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        if (i == 1 || [fetchedConfigurationBundle.formatVersion isEqualToString:@"1.1"]) {
            XCTFail();
        }
        if (i == 0 && [fetchedConfigurationBundle.formatVersion isEqualToString:@"1.0"]) {
            i++;
        }
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);
    XCTAssertEqual(1, i);

    // close test
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
}

- (void)testConfigurationProvider_downloadHigherConfigVersionThanCached_doUpdate {
    // prepare test
    NSString *endpoint = @"https://snowplowanalytics.com/config.json";
    
    SPConfigurationCache *cache = [SPConfigurationCache new];
    [cache clearCache];
    SPConfigurationBundle *bundle = [[SPConfigurationBundle alloc] init];
    bundle.networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:@"endpoint"];
    SPFetchedConfigurationBundle *cached = [[SPFetchedConfigurationBundle alloc] init];
    cached.formatVersion = @"1.0";
    cached.configurationVersion = 1;
    cached.configurationBundle = @[bundle];
    [cache writeCache:cached];
    [NSThread sleepForTimeInterval:5]; // wait to write on cache
    
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", endpoint)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"formatVersion\":\"1.1\",\"configurationVersion\":2,\"configurationBundle\":[]}");
    
    // test
    XCTestExpectation *expectation = [XCTestExpectation new];
    SPRemoteConfiguration *remoteConfig = [[SPRemoteConfiguration alloc] initWithEndpoint:endpoint method:SPHttpMethodGet];
    SPConfigurationProvider *provider = [[SPConfigurationProvider alloc] initWithRemoteConfiguration:remoteConfig];
    __block int i = 0;
    [provider retrieveConfiguration:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
        if (i == 1 && [fetchedConfigurationBundle.formatVersion isEqualToString:@"1.1"]) {
            i++;
        }
        if (i == 0 && [fetchedConfigurationBundle.formatVersion isEqualToString:@"1.0"]) {
            i++;
        }
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(XCTWaiterResultTimedOut, result);
    XCTAssertEqual(2, i);

    // close test
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
}

@end
