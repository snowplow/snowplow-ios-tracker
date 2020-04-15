//
//  TestSubject.m
//  Snowplow
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "Snowplow.h"
#import "SPSubject.h"
#import "SPPayload.h"

@interface TestSubject : XCTestCase

@end

@implementation TestSubject

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSubjectInit {
    SPSubject * subject = [[SPSubject alloc] init];
    XCTAssertNil([subject getPlatformDict]);
    XCTAssertNotNil([subject getStandardDict]);
}

- (void)testSubjectInitWithOptions {
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:YES];
    XCTAssertNotNil([subject getPlatformDict]);
    XCTAssertNotNil([subject getStandardDict]);
}

- (void)testSubjectSetterFunctions {
    SPSubject * subject = [[SPSubject alloc] init];
    [subject setUserId:@"aUserId"];
    [subject setResolutionWithWidth:1920 andHeight:1080];
    [subject setViewPortWithWidth:1080 andHeight:1920];
    [subject setColorDepth:20];
    [subject setTimezone:@"UTC"];
    [subject setLanguage:@"EN"];
    [subject setIpAddress:@"127.0.0.1"];
    [subject setUseragent:@"aUseragent"];
    [subject setNetworkUserId:@"aNuid"];
    [subject setDomainUserId:@"aDuid"];
    
    NSDictionary * values = [[subject getStandardDict] getAsDictionary];
    
    XCTAssertEqual([values valueForKey:kSPUid], @"aUserId");
    XCTAssertTrue([[values valueForKey:kSPResolution] isEqualToString:@"1920x1080" ]);
    XCTAssertTrue([[values valueForKey:kSPViewPort] isEqualToString:@"1080x1920"]);
    XCTAssertTrue([[values valueForKey:kSPColorDepth] isEqualToString:@"20"]);
    XCTAssertEqual([values valueForKey:kSPTimezone], @"UTC");
    XCTAssertEqual([values valueForKey:kSPLanguage], @"EN");
    XCTAssertEqual([values valueForKey:kSPIpAddress], @"127.0.0.1");
    XCTAssertEqual([values valueForKey:kSPUseragent], @"aUseragent");
    XCTAssertEqual([values valueForKey:kSPNetworkUid], @"aNuid");
    XCTAssertEqual([values valueForKey:kSPDomainUid], @"aDuid");
    
    // Setup GeoLocation
    [subject setGeoDict];
    [subject setGeoLongitude:5];
    [subject setGeoLatitude:89.2];
    [subject setGeoTimestamp:@5];
    [subject setGeoLatitudeLongitudeAccuracy:5.5];
    [subject setGeoSpeed:6.2];
    [subject setGeoBearing:82.3];
    [subject setGeoAltitude:62.3];
    [subject setGeoAltitudeAccuracy:16.3];
    
    values = [subject getGeoLocationDict];
    
    XCTAssertEqualObjects([NSNumber numberWithFloat:5], [values objectForKey:kSPGeoLongitude]);
    XCTAssertEqualObjects([NSNumber numberWithFloat:89.2], [values objectForKey:kSPGeoLatitude]);
    XCTAssertEqualObjects([NSNumber numberWithFloat:5.5], [values objectForKey:kSPGeoLatLongAccuracy]);
    XCTAssertEqualObjects([NSNumber numberWithFloat:6.2], [values objectForKey:kSPGeoSpeed]);
    XCTAssertEqualObjects([NSNumber numberWithFloat:82.3], [values objectForKey:kSPGeoBearing]);
    XCTAssertEqualObjects([NSNumber numberWithFloat:62.3], [values objectForKey:kSPGeoAltitude]);
    XCTAssertEqualObjects([NSNumber numberWithFloat:16.3], [values objectForKey:kSPGeoAltitudeAccuracy]);
    XCTAssertEqualObjects([NSNumber numberWithInt:5], [values objectForKey:kSPGeoTimestamp]);
}

- (void) testGeoLocationGetWithoutNeededKeys {
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:NO andGeoContext:YES];
    XCTAssertNil([subject getGeoLocationDict]);
    
    [subject setGeoLongitude:5];
    [subject setGeoLatitude:89.2];
    
    XCTAssertNotNil([subject getGeoLocationDict]);
}

@end
