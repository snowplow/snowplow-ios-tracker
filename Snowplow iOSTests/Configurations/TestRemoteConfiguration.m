//
//  TestRemoteConfiguration.m
//  Snowplow-iOSTests
//
//  Created by Alex Benini on 03/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SPFetchedConfigurationBundle.h"

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

@end
