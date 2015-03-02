//
//  TestUtils.m
//  Snowplow
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

#import <UIKit/UIDevice.h>

#import "SnowplowUtils.h"

#import <XCTest/XCTest.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

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
    XCTAssertEqualObjects([SnowplowUtils getTimezone],
                          [[NSTimeZone systemTimeZone] name],
                          @"Incorrect timezone expected");
}

- (void)testGetLanguage
{
    XCTAssertEqualObjects([SnowplowUtils getLanguage],
                          @"en",
                          @"Language retrieved is not the same as 'en'");
}

- (void)testGetPlatform
{
    // This test is a reminder to add a unit test,
    // if we add some different logic to get the platform

    XCTAssertEqualObjects([SnowplowUtils getPlatform],
                          @"mob",
                          @"How could this fail?");
}

- (void)testGetResolution
{
    NSString *actualResolution = [SnowplowUtils getResolution];

    // iPhone (maybe Retina or not)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        assertThat(actualResolution, anyOf(equalTo(@"750x1334"),
                                           equalTo(@"320x480"), nil));
    // iPad
    } else {
        assertThat(actualResolution, equalTo(@"1536x2048"));
    }
}

- (void)testGetEventId
{
    // Probably an unneccessary test, but this verifies for a proper UUID

    NSString *sample_uuid = [SnowplowUtils getEventId];

    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}";
    NSRange searchRange = NSMakeRange(0, [sample_uuid length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_uuid options:0 range:searchRange];
    
    //NSLog(@"UUID generated: %@", sample_uuid);
    
    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"UUID generated doesn't match the type 4 UUID RFC");
}

// This test is causing xctool problems for some unknown reason
//
//- (void)testGetAppleIdfa
//{
//    NSString *sample_uuid = [SnowplowUtils getAppleIdfa];
//    
//    // For regex pattern matching to verify if it's of UUID type 4
//    NSString *pattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";
//    NSRange searchRange = NSMakeRange(0, [sample_uuid length]);
//    NSError *error = NULL;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
//    NSArray *matches = [regex matchesInString:sample_uuid options:0 range:searchRange];
//    
//    //NSLog(@"UUID generated: %@", sample_uuid);
//    
//    XCTAssertEqual([matches count], (NSUInteger)1,
//                   @"UUID generated doesn't match the type 4 UUID RFC");
//
//}

- (void)testGetOpenIdfa
{
    NSString *sample_uuid = [SnowplowUtils getOpenIdfa];

    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";
    NSRange searchRange = NSMakeRange(0, [sample_uuid length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_uuid options:0 range:searchRange];

    NSLog(@"UUID generated: %@", sample_uuid);

    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"UUID generated doesn't match the type 4 UUID RFC");

}

- (void)testGetCarrierName
{
    NSLog(@"Carrier: %@", [SnowplowUtils getCarrierName]);
    // No way to fake carrier in Travis simulator
}

- (void)testGetTransactionId
{
    // Supressing deprecated warning only for tests
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    int sample_rand = [SnowplowUtils getTransactionId];
    XCTAssertTrue((100000 < sample_rand < 999999), @"Transaction ID doesn't exist between our range of 999,999 and 100,000.");
#pragma clang diagnostic pop
}

- (void)testGetTimestamp
{
    NSString *sample_rand = [NSString stringWithFormat:@"%.0f", [SnowplowUtils getTimestamp]];
    
    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9]+";
    NSRange searchRange = NSMakeRange(0, [sample_rand length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_rand options:0 range:searchRange];
    
    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"Timestamp generated doesn't match the correct format 1234.567");

}

- (void)testAppId
{
    // TODO Write proper test
    NSLog(@"appId: %@", [SnowplowUtils getAppId]);
}

- (void)testUrlEncodingString
{
    XCTAssertEqualObjects([SnowplowUtils urlEncodeString:@""], @"");
    XCTAssertEqualObjects([SnowplowUtils urlEncodeString:nil], @"");
    XCTAssertEqualObjects([SnowplowUtils urlEncodeString:@"a"], @"a");
    XCTAssertEqualObjects([SnowplowUtils urlEncodeString:@"a b"], @"a%20b");
    XCTAssertEqualObjects([SnowplowUtils urlEncodeString:@"a=&"], @"a%3D%26");
}

- (void)testUrlEncodingDictionary
{
    XCTAssertEqualObjects([SnowplowUtils urlEncodeDictionary:nil], @"");
    XCTAssertEqualObjects([SnowplowUtils urlEncodeDictionary:@{@"a": @"b"}], @"a=b");
    
    id twoKeys = @{@"a" : @"b", @"c" : @"d" };
    XCTAssertEqualObjects([SnowplowUtils urlEncodeDictionary:twoKeys], @"a=b&c=d");
    
    id intValues = @{@"a" : @(-5), @"c" : @(3) };
    XCTAssertEqualObjects([SnowplowUtils urlEncodeDictionary:intValues], @"a=-5&c=3");
    
    id boolValues = @{@"a" : @(NO), @"c" : @(YES) };
    XCTAssertEqualObjects([SnowplowUtils urlEncodeDictionary:boolValues], @"a=0&c=1");

    id encodedValues = @{@"a" : @" ", @"c" : @"=" };
    XCTAssertEqualObjects([SnowplowUtils urlEncodeDictionary:encodedValues], @"a=%20&c=%3D");
}

@end
