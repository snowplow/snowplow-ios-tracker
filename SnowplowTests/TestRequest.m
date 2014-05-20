//
//  TestRequest.m
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-18.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SnowplowRequest.h"
#import "SnowplowPayload.h"

@interface TestRequest : XCTestCase
extern NSString * const TEST_SERVER;
@end

@implementation TestRequest

//NSString *const TEST_SERVER = @"http://localhost:3000/events";
NSString *const TEST_SERVER = @"http://segfault.ngrok.com/event";

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testFlushBuffer
{

    NSURL *url = [[NSURL alloc] initWithString:TEST_SERVER];
    SnowplowRequest *sample_req = [[SnowplowRequest alloc] initWithURLRequest:url httpMethod:@"POST"];
    SnowplowPayload *sample_event = [[SnowplowPayload alloc] init];
    
    [sample_event addValueToPayload:@"something" withKey:@"nv"];
    [sample_event addValueToPayload:@"newstuff" withKey:@"pv"];
    
    [sample_req addPayloadToBuffer:sample_event];
    
    [sample_req flushBuffer];
    sleep(2); //Tests fail to send the message if you don't give it sufficient time
}

@end
