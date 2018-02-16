//
//  TestRequestResponse.m
//  Snowplow
//
//  Copyright (c) 2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "Snowplow.h"
#import "SPRequestResponse.h"

@interface TestRequestResponse : XCTestCase

@end

@implementation TestRequestResponse

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithInteger:1]];
    SPRequestResponse * response = [[SPRequestResponse alloc] initWithBool:YES withIndex:array];
    
    XCTAssertNotNil(response);
    XCTAssertEqual([response getSuccess], YES);
    XCTAssertEqual([response getIndexArray], array);
    
    response = [[SPRequestResponse alloc] init];
    
    XCTAssertNotNil(response);
    XCTAssertEqual([response getSuccess], NO);
    XCTAssertNil([response getIndexArray]);
}

@end
