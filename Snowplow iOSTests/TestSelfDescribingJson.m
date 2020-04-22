//
//  TestSelfDescribingJson.m
//  SnowplowTests
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
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@interface TestSelfDescribingJson : XCTestCase

@end

@implementation TestSelfDescribingJson

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitWithBadSchema {
    SPSelfDescribingJson * sdj;
    @try {
        sdj = [[SPSelfDescribingJson alloc] initWithSchema:nil andData:nil];
    }
    @catch (NSException *exception) {
        // formally this function would generate an exception, now only emits a log line
    }
    
    @try {
        sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"" andData:nil];
    }
    @catch (NSException *exception) {
        // formally this function would generate an exception, now only emits a log line
    }
}

- (void)testInitWithObject {
    NSDictionary * expected = @{
                                @"schema":@"iglu:acme.com/test_event/jsonschema/1-0-0",
                                @"data":@{
                                        @"hello":@"world"
                                        }
                                };
    NSDictionary * data = @{@"hello":@"world"};
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/test_event/jsonschema/1-0-0"
                                                                      andData:data];
    XCTAssertEqualObjects(expected, [sdj getAsDictionary]);
    XCTAssertEqualObjects([expected description], [sdj description]);
}

- (void)testInitWithSPPayload {
    NSDictionary * expected = @{
                                @"schema":@"iglu:acme.com/test_event/jsonschema/1-0-0",
                                @"data":@{
                                        @"hello":@"world"
                                        }
                                };
    SPPayload * data = [[SPPayload alloc] init];
    [data addValueToPayload:@"world" forKey:@"hello"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/test_event/jsonschema/1-0-0"
                                                                      andPayload:data];
    XCTAssertEqualObjects(expected, [sdj getAsDictionary]);
}

- (void)testInitWithSPSelfDescribingJson {
    NSDictionary * expected = @{
                                @"schema":@"iglu:acme.com/test_event/jsonschema/1-0-0",
                                @"data":@{
                                        @"schema":@"iglu:acme.com/nested_event/jsonschema/1-0-0",
                                        @"data":@{
                                                @"hello":@"world"
                                                }
                                        }
                                };
    NSDictionary * nestedData = @{@"hello":@"world"};
    SPSelfDescribingJson * data = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/nested_event/jsonschema/1-0-0"
                                                                       andData:nestedData];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/test_event/jsonschema/1-0-0"
                                                        andSelfDescribingJson:data];
    XCTAssertEqualObjects(expected, [sdj getAsDictionary]);
}

- (void)testUpdateSchema {
    NSDictionary * expected = @{
                                @"schema":@"iglu:acme.com/test_event_2/jsonschema/1-0-0",
                                @"data":@{
                                        @"hello":@"world"
                                        }
                                };
    NSDictionary * data = @{@"hello":@"world"};
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/test_event/jsonschema/1-0-0"
                                                                      andData:data];
    [sdj setSchema:@"iglu:acme.com/test_event_2/jsonschema/1-0-0"];
    XCTAssertEqualObjects(expected, [sdj getAsDictionary]);
}

- (void)testUpdateDataWithObject {
    NSDictionary * expected = @{
                                @"schema":@"iglu:acme.com/test_event/jsonschema/1-0-0",
                                @"data":@{
                                        @"world":@"hello"
                                        }
                                };
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/test_event/jsonschema/1-0-0"
                                                                      andData:@{@"hello":@"world"}];
    [sdj setDataWithObject:@{@"world":@"hello"}];
    XCTAssertEqualObjects(expected, [sdj getAsDictionary]);
}

- (void)testUpdateDataWithSPPayload {
    NSDictionary * expected = @{
                                @"schema":@"iglu:acme.com/test_event/jsonschema/1-0-0",
                                @"data":@{
                                        @"world":@"hello"
                                        }
                                };
    SPPayload * data = [[SPPayload alloc] init];
    [data addValueToPayload:@"hello" forKey:@"world"];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/test_event/jsonschema/1-0-0"
                                                                      andData:@{@"hello":@"world"}];
    [sdj setDataWithPayload:data];
    XCTAssertEqualObjects(expected, [sdj getAsDictionary]);
}

- (void)testUpdateDataWithSPSelfDescribingJson {
    NSDictionary * expected = @{
                                @"schema":@"iglu:acme.com/test_event/jsonschema/1-0-0",
                                @"data":@{
                                        @"schema":@"iglu:acme.com/nested_event/jsonschema/1-0-0",
                                        @"data":@{
                                                @"hello":@"world"
                                                }
                                        }
                                };
    NSDictionary * nestedData = @{@"hello":@"world"};
    SPSelfDescribingJson * data = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/nested_event/jsonschema/1-0-0"
                                                                       andData:nestedData];
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:acme.com/test_event/jsonschema/1-0-0"
                                                                      andData:@{@"hello":@"world"}];
    [sdj setDataWithSelfDescribingJson:data];
    XCTAssertEqualObjects(expected, [sdj getAsDictionary]);
}

@end
