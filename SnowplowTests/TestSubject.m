//
//  TestSubject.m
//  Snowplow
//
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
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
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES];
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
    
    NSDictionary * values = [[subject getStandardDict] getPayloadAsDictionary];
    
    NSLog(@"Weird value: %@", [values valueForKey:kResolution]);
    
    XCTAssertEqual([values valueForKey:kUid], @"aUserId");
    XCTAssertTrue([[values valueForKey:kResolution] isEqualToString:@"1920x1080" ]);
    XCTAssertTrue([[values valueForKey:kViewPort] isEqualToString:@"1080x1920"]);
    XCTAssertTrue([[values valueForKey:kColorDepth] isEqualToString:@"20"]);
    XCTAssertEqual([values valueForKey:kTimezone], @"UTC");
    XCTAssertEqual([values valueForKey:kLanguage], @"EN");
    XCTAssertEqual([values valueForKey:kIpAddress], @"127.0.0.1");
    XCTAssertEqual([values valueForKey:kUseragent], @"aUseragent");
    XCTAssertEqual([values valueForKey:kNetworkUid], @"aNuid");
    XCTAssertEqual([values valueForKey:kDomainUid], @"aDuid");
}

@end
