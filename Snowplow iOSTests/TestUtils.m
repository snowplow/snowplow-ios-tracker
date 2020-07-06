//
//  TestUtils.m
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import <AdSupport/AdSupport.h>
#import "SPUtilities.h"
#import "Snowplow.h"

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
    XCTAssertEqualObjects([SPUtilities getTimezone],
                          [[NSTimeZone systemTimeZone] name],
                          @"Incorrect timezone expected");
}

- (void)testGetLanguage {
#if TARGET_OS_IPHONE
    if (SNOWPLOW_iOS_9_OR_LATER) {
        NSArray *options = [NSArray arrayWithObjects:@"en", @"en-US", nil];
        XCTAssertTrue([options containsObject:[SPUtilities getLanguage]]);
    }
#else
    XCTAssertEqualObjects([SPUtilities getLanguage],
                          @"en",
                          @"Language retrieved is not the same as 'en'");
#endif
}

- (void)testGetPlatform {
#if TARGET_OS_IPHONE
    XCTAssertEqual([SPUtilities getPlatform], SPDevicePlatformMobile);
#else
    XCTAssertEqual([SPUtilities getPlatform], SPDevicePlatformDesktop);
#endif
}

- (void)testGetResolution {
    NSString *actualResolution = [SPUtilities getResolution];
    XCTAssertTrue(actualResolution != nil);
}

- (void)testGetEventId {
    NSString *sample_uuid = [SPUtilities getUUIDString];

    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}";
    NSRange searchRange = NSMakeRange(0, [sample_uuid length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_uuid options:0 range:searchRange];
    
    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"UUID generated doesn't match the type 4 UUID RFC");
}

- (void)testGetAppleIdfa {
    // The simulator running the test must have "limit ad tracking" disabled.
    // (You can find it in the Simulator: Settings > Privacy > Advertising > Limit Ad Tracking > Set to False)
    NSString *sample_uuid = [SPUtilities getAppleIdfa];
    
    // For regex pattern matching to verify if it's of UUID type 4
    NSString *pattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";
    NSRange searchRange = NSMakeRange(0, [sample_uuid length]);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:sample_uuid options:0 range:searchRange];
    
    XCTAssertEqual([matches count], (NSUInteger)1,
                   @"UUID generated doesn't match the type 4 UUID RFC");
}

- (void)testGetOpenIdfa {
    NSString *sample_uuid = [SPUtilities getOpenIdfa];
#if TARGET_OS_IPHONE
    if (SNOWPLOW_iOS_9_OR_LATER) {
        XCTAssertNil(sample_uuid);
    } else {
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
#else
    XCTAssertNil(sample_uuid);
#endif
}

- (void)testGetTransactionId {
    // Supressing deprecated warning only for tests
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    int sample_rand = [SPUtilities getTransactionId];
    XCTAssertTrue((sample_rand > 100000 && sample_rand < 999999), @"Transaction ID doesn't exist between our range of 999,999 and 100,000.");
#pragma clang diagnostic pop
}

- (void)testGetTimestamp {
    NSString *sample_rand = [NSString stringWithFormat:@"%lld", [[SPUtilities getTimestamp] longLongValue]];
    
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
    NSLog(@"appId: %@", [SPUtilities getAppId]);
}

- (void)testUrlEncodingString {
    XCTAssertEqualObjects([SPUtilities urlEncodeString:@""], @"");
    XCTAssertEqualObjects([SPUtilities urlEncodeString:nil], @"");
    XCTAssertEqualObjects([SPUtilities urlEncodeString:@"a"], @"a");
    XCTAssertEqualObjects([SPUtilities urlEncodeString:@"a b"], @"a%20b");
    XCTAssertEqualObjects([SPUtilities urlEncodeString:@"a=&"], @"a%3D%26");
}

- (void)testUrlEncodingDictionary {
    XCTAssertEqualObjects([SPUtilities urlEncodeDictionary:nil], @"");
    XCTAssertEqualObjects([SPUtilities urlEncodeDictionary:@{@"a": @"b"}], @"a=b");
    
    id twoKeys = @{@"a" : @"b", @"c" : @"d" };
    XCTAssertEqualObjects([SPUtilities urlEncodeDictionary:twoKeys], @"a=b&c=d");
    
    id intValues = @{@"a" : @(-5), @"c" : @(3) };
    XCTAssertEqualObjects([SPUtilities urlEncodeDictionary:intValues], @"a=-5&c=3");
    
    id boolValues = @{@"a" : @(NO), @"c" : @(YES) };
    XCTAssertEqualObjects([SPUtilities urlEncodeDictionary:boolValues], @"a=0&c=1");

    id encodedValues = @{@"a" : @" ", @"c" : @"=" };
    XCTAssertEqualObjects([SPUtilities urlEncodeDictionary:encodedValues], @"a=%20&c=%3D");
}

- (void)testEscapedQueryString {
    id testValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     [NSNull null], @"null_value_key",
                     @"Not null", @"string_value_key",
                     @"|!\" £$%&/()=?^ì§°ç*éùàò+{}◊∞Ç±¿≈ ⁄›‰¢’”»ıè¶#@][ˆ¡≠`´÷‹~~¥‘“«`", @"characters_key",
                     nil];
    NSString *now = [SPUtilities urlEncodeDictionary:testValues];
    NSString *then = @"string_value_key=Not%20null&characters_key=%7C%21%22%20%C2%A3%24%25%26%2F%28%29%3D%3F%5E%C3%AC%C2%A7%C2%B0%C3%A7%2A%C3%A9%C3%B9%C3%A0%C3%B2%2B%7B%7D%E2%97%8A%E2%88%9E%C3%87%C2%B1%C2%BF%E2%89%88%20%EF%A3%BF%E2%81%84%E2%80%BA%E2%80%B0%C2%A2%E2%80%99%E2%80%9D%C2%BB%C4%B1%C3%A8%C2%B6%23%40%5D%5B%CB%86%C2%A1%E2%89%A0%60%C2%B4%C3%B7%E2%80%B9~~%C2%A5%E2%80%98%E2%80%9C%C2%AB%60&null_value_key=%3Cnull%3E";
    XCTAssertEqualObjects(now, then);
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", @"http://www.snowplow.com", now];
    NSURL *url = [NSURL URLWithString:urlString];
    XCTAssertNotNil(url);
}

- (void)testCheckArgument {
    @try {
        [SPUtilities checkArgument:NO withMessage:@"This will throw an exception."];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(NSInvalidArgumentException, exception.name);
        XCTAssertEqualObjects(@"This will throw an exception.", exception.reason);
    }
}

- (void)testDictionaryNullRemover {
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSNull null], @"a_null_value",
                                  @"Not null!", @"a_string_value", nil];
    XCTAssertEqual(dict.count, 2);
    NSDictionary * result = [SPUtilities removeNullValuesFromDictWithDict:dict];
    XCTAssertEqual(result.count, 1);
}

@end
