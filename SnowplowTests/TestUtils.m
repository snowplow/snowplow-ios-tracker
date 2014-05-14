//
//  TestUtils.m
//  SnowplowTests
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import <UIKit/UIDevice.h>
#import "SnowplowUtils.h"

@interface TestUtils : XCTestCase

@end

@implementation TestUtils

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGetTimeZone
{
    SnowplowUtils *sample_utils = [[SnowplowUtils alloc] init];
    XCTAssertEqualObjects([sample_utils getTimezone],
                          [[NSTimeZone systemTimeZone] name],
                          @"Incorrect timezone expected");
}

- (void)testGetLanguage {
    SnowplowUtils *sample_utils = [[SnowplowUtils alloc] init];
    XCTAssertEqualObjects([sample_utils getLanguage],
                          @"en",
                          @"Language retrieved is not the same as 'en'");
}

- (void)testGetPlatform {
    // This test is a reminder to add a unit test,
    // if we add some different logic to get the platform
    SnowplowUtils *sample_utils = [[SnowplowUtils alloc] init];
    XCTAssertEqualObjects([sample_utils getPlatform],
                          @"mob",
                          @"How could this fail?");
}

- (void)testGetResolution {
    SnowplowUtils *sample_utils = [[SnowplowUtils alloc] init];
    NSDictionary *sample_res = [sample_utils getResolution];
    NSMutableDictionary *expected_resp = [[NSMutableDictionary alloc] init];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [expected_resp setObject:@"320" forKey:@"width"];
        [expected_resp setObject:@"480" forKey:@"height"];
    } else { //iPad
        [expected_resp setObject:@"768" forKey:@"width"];
        [expected_resp setObject:@"1024" forKey:@"height"];
    }
    
    XCTAssertEqualObjects(sample_res,
                          expected_resp,
                          @"Screen size isn't correct. Maybe tested on an iPhone 5?");
}

- (void)testGetEventId {
    SnowplowUtils *sample_utils = [[SnowplowUtils alloc] init];
    XCTAssertEqual([[sample_utils getEventId] length],
                   36, // 32 + 4 hypens
                   @"UUID generated isn't of expected length");
}

@end
