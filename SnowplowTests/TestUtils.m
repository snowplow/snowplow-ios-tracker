//
//  TestUtils.m
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIDevice.h>
#endif

#import "SPUtils.h"

#define HC_SHORTHAND


@interface TestUtils : XCTestCase

@end

@implementation TestUtils

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetTimeZone {
    XCTAssertEqualObjects([SPUtils getTimezone],
                          [[NSTimeZone systemTimeZone] name],
                          @"Incorrect timezone expected");
}

- (void)testGetLanguage {
    XCTAssertEqualObjects([SPUtils getLanguage],
                          @"en",
                          @"Language retrieved is not the same as 'en'");
}

- (void)testGetPlatform {
#if TARGET_OS_IPHONE
    XCTAssertEqualObjects([SPUtils getPlatform],
                          @"mob",
                          @"How could this fail?");
#else
    XCTAssertEqualObjects([SPUtils getPlatform],
                          @"pc",
                          @"How could this fail?");
#endif
}

- (void)testGetResolution {
    NSString *actualResolution = [SPUtils getResolution];
    XCTAssertTrue(actualResolution != nil);
}

- (void)testGetEventId {
    NSString *sample_uuid = [SPUtils getEventId];

    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}";
    NSRange searchRange = NSMakeRange(0, [sample_uuid length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_uuid options:0 range:searchRange];
    
    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"UUID generated doesn't match the type 4 UUID RFC");
}

/**

 This is always NULL as we do not have the AdSupport imported
 
- (void)testGetAppleIdfa {
    NSString *sample_uuid = [SPUtils getAppleIdfa];
    
    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";
    NSRange searchRange = NSMakeRange(0, [sample_uuid length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_uuid options:0 range:searchRange];
    
    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"UUID generated doesn't match the type 4 UUID RFC");
}
*/

- (void)testGetOpenIdfa {
    NSString *sample_uuid = [SPUtils getOpenIdfa];
#if TARGET_OS_IPHONE
    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";
    NSRange searchRange = NSMakeRange(0, [sample_uuid length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_uuid options:0 range:searchRange];

    NSLog(@"UUID generated: %@", sample_uuid);

    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"UUID generated doesn't match the type 4 UUID RFC");
#else
    XCTAssertNil(sample_uuid);
#endif
}

- (void)testGetCarrierName {
    NSLog(@"Carrier: %@", [SPUtils getCarrierName]);
    // No way to fake carrier in Travis simulator
}

- (void)testGetTransactionId {
    // Supressing deprecated warning only for tests
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    int sample_rand = [SPUtils getTransactionId];
    XCTAssertTrue((sample_rand > 100000 && sample_rand < 999999), @"Transaction ID doesn't exist between our range of 999,999 and 100,000.");
#pragma clang diagnostic pop
}

- (void)testGetTimestamp {
    NSString *sample_rand = [NSString stringWithFormat:@"%.0f", [SPUtils getTimestamp]];
    
    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9]+";
    NSRange searchRange = NSMakeRange(0, [sample_rand length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_rand options:0 range:searchRange];
    
    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"Timestamp generated doesn't match the correct format 1234.567");

}

- (void)testAppId {
    // This is always NULL in a test environment
    NSLog(@"appId: %@", [SPUtils getAppId]);
}

- (void)testUrlEncodingString {
    XCTAssertEqualObjects([SPUtils urlEncodeString:@""], @"");
    XCTAssertEqualObjects([SPUtils urlEncodeString:nil], @"");
    XCTAssertEqualObjects([SPUtils urlEncodeString:@"a"], @"a");
    XCTAssertEqualObjects([SPUtils urlEncodeString:@"a b"], @"a%20b");
    XCTAssertEqualObjects([SPUtils urlEncodeString:@"a=&"], @"a%3D%26");
}

- (void)testUrlEncodingDictionary {
    XCTAssertEqualObjects([SPUtils urlEncodeDictionary:nil], @"");
    XCTAssertEqualObjects([SPUtils urlEncodeDictionary:@{@"a": @"b"}], @"a=b");
    
    id twoKeys = @{@"a" : @"b", @"c" : @"d" };
    XCTAssertEqualObjects([SPUtils urlEncodeDictionary:twoKeys], @"a=b&c=d");
    
    id intValues = @{@"a" : @(-5), @"c" : @(3) };
    XCTAssertEqualObjects([SPUtils urlEncodeDictionary:intValues], @"a=-5&c=3");
    
    id boolValues = @{@"a" : @(NO), @"c" : @(YES) };
    XCTAssertEqualObjects([SPUtils urlEncodeDictionary:boolValues], @"a=0&c=1");

    id encodedValues = @{@"a" : @" ", @"c" : @"=" };
    XCTAssertEqualObjects([SPUtils urlEncodeDictionary:encodedValues], @"a=%20&c=%3D");
}

- (void)testIsOnline {
    XCTAssertEqual([SPUtils isOnline], YES);
}

@end
