//
//  TestEventStore.m
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-06-17.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SnowplowEventStore.h"

@interface TestEventStore : XCTestCase

@end

@implementation TestEventStore

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    SnowplowEventStore *sampleEventStore = [[SnowplowEventStore alloc] init];
}

@end
