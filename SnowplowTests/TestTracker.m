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
#import "SnowplowEmitter.h"
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
    SnowplowEmitter *collector = [[SnowplowEmitter alloc] initWithURLRequest:[NSURL URLWithString:@"http://segfault.ngrok.com"] httpMethod:@"POST" bufferOption:SnowplowBufferInstant];
    SnowplowTracker *tracker = [[SnowplowTracker alloc] initWithCollector:collector appId:@"foo" base64Encoded:false namespace:@"myname"];
    
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"foo", @"bar", nil];
    NSMutableArray *contextArray = [NSMutableArray arrayWithObject:context];
    [tracker trackPageView:@"foo1.com" title:@"This is my foo1" referrer:@"myreferrer1" context:contextArray timestamp:0];
    [tracker trackPageView:@"foo2.com" title:@"This is my foo2" referrer:@"myreferrer2" context:nil timestamp:0];
//    [tracker trackPageView:@"foo1.com" title:@"This is my foo3" referrer:@"myreferrer3" context:nil timestamp:0];
    
    sleep(2);
}

- (void)testInit
{
    // Basic test to see if init values are set
}

- (void)testInitPropertySet
{
    // Force setting of init values that were not set if using initUsingCollector:appId:base64Encoded:namespace:
}

- (void)testInitUsingCollector
{
    // Basic test to see if initUsingCollector are set
}

- (void)testSetSchemaTag
{
    // Self-explanatory
}

- (void)testTrackPageViewWithoutContext {
    // Test page view tracker WITHOUT a context set
}

- (void)testTrackPageViewWithContext {
    // Test page view tracker WITH a context set
}

- (void)testTrackPageViewWithTimestamp {
    // Test page view tracker WITH a timestamp set
}

- (void)testTrackPageViewWithoutTimestamp {
    // Test page view tracker WITHOUT a timestamp set
}


@end
