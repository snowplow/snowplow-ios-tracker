//
//  TestSubject.h
//  Snowplow
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
//  Authors: Matus Tomlein
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPTrackerConstants.h"
#import "SPSubject.h"

@interface TestSubject : XCTestCase

@end

@implementation TestSubject

- (void)testReturnsPlatformContextIfEnabled {
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:NO];
    SPPayload *platformDict = [subject getPlatformDictWithUserAnonymisation:NO];
    XCTAssertNotNil(platformDict);
    XCTAssertNotNil([[platformDict getAsDictionary] objectForKey:kSPPlatformOsType]);
}

- (void)testDoesntReturnPlatformContextIfDisabled {
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:NO andGeoContext:NO];
    SPPayload *platformDict = [subject getPlatformDictWithUserAnonymisation:NO];
    XCTAssertNil(platformDict);
}

- (void)testReturnsGeolocationContextIfEnabled {
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:NO andGeoContext:YES];
    [subject setGeoLatitude:10.0];
    [subject setGeoLongitude:10.0];
    NSDictionary *geoLocationDict = [subject getGeoLocationDict];
    XCTAssertNotNil(geoLocationDict);
    XCTAssertNotNil([geoLocationDict objectForKey:kSPGeoLatitude]);
}

- (void)testDoesntReturnGeolocationContextIfDisabled {
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:NO andGeoContext:NO];
    [subject setGeoLatitude:10.0];
    [subject setGeoLongitude:10.0];
    NSDictionary *geoLocationDict = [subject getGeoLocationDict];
    XCTAssertNil(geoLocationDict);
}

@end
