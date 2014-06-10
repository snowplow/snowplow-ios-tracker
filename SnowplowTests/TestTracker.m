//
//  TestTracker.m
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

#import <XCTest/XCTest.h>
#import "SnowplowRequest.h"
#import "SnowplowPayload.h"
#import "SnowplowTracker.h"

@interface TestTracker : XCTestCase

@end

@implementation TestTracker

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{
    SnowplowRequest *collector = [[SnowplowRequest alloc] initWithURLRequest:[NSURL URLWithString:@"http://segfault.ngrok.com/events"] httpMethod:@"POST"];
    SnowplowTracker *tracker = [[SnowplowTracker alloc] initUsingCollector:collector appId:@"foo" base64Encoded:false namespace:@"myname"];
    
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"foo", @"bar", nil];
    
    [tracker trackPageView:@"foo2.com" title:@"This is my foo2" referrer:@"myreferrer2" context:context timestamp:124];
    
    [collector flushBuffer];
    
    sleep(2);
}

@end
