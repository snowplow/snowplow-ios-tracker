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
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];

    [pb addValueToPayload:@"pv"      forKey:@"e"];
    [pb addValueToPayload:@"www.foobar.com"   forKey:@"url"];
    [pb addValueToPayload:@"Welcome to foobar!" forKey:@"page"];
    [pb addValueToPayload:@"MEEEE"   forKey:@"refr"];
    
    [sampleEventStore createTable];
    [sampleEventStore insertEvent:pb];
//    [sampleEventStore deleteEventWithId:2];
    [sampleEventStore getAllEvents];
}

- (void)testGetLastInsertedRowId
{
    SnowplowEventStore *sampleEventStore = [[SnowplowEventStore alloc] init];
    SnowplowPayload *pb = [[SnowplowPayload alloc] init];
    
    [pb addValueToPayload:@"pv"      forKey:@"e"];
    [pb addValueToPayload:@"www.apple.com"   forKey:@"url"];
    [pb addValueToPayload:@"Welcome to Apple!" forKey:@"page"];
    [pb addValueToPayload:@"Jobs"   forKey:@"refr"];
    
    [sampleEventStore insertEvent:pb];
    NSLog(@"Inserted row ID: %lld", [sampleEventStore getLastInsertedRowId]);
}

- (void) testInit
{
    // Verify all init variables including table created
}

- (void) testInsertEvent
{
    // Verify basic insert
}

- (void) testDictionaryData
{
    // Same as above
}

@end
