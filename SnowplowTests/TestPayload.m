//
//  TestPayload.m
//  Snowplow
//
//  Created by Jonathan Almeida on 2014-05-12.
//  Copyright (c) 2014 Snowplow Analytics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SnowplowPayload.h"

@interface TestPayload : XCTestCase

@end

@implementation TestPayload

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInit
{
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] init];
   
    XCTAssertEqualObjects(sample_payload.payload,
                          [[NSDictionary alloc] init],
                          @"Payload is not initilized to null on init");

}

- (void)testInitWithNSDictionary
{
    NSDictionary *sample_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Value1", @"Key1",
                                 @"Value2", @"Key2", nil];
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] initWithNSDictionary:sample_dict];

    XCTAssertEqualObjects(sample_payload.payload,
                          sample_dict,
                          @"Payload is not initialized with the correct JSON or NSDictionary");

}

- (void)testInitWithWrongDictionary
{
    NSDictionary *sample_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Value1", @"Key1",
                                 @"Value2", @"Key2", nil];
    NSDictionary *sample_dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"Value1", @"Key2",
                                  @"Value2", @"Key1", nil];
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] initWithNSDictionary:sample_dict];
    
    XCTAssertNotEqualObjects(sample_payload.payload,
                             sample_dict2,
                             @"Payload is not initialized with the correct JSON or NSDictionary");
}

- (void)testInitWithNullDictionary
{
    NSDictionary *sample_dict = nil;
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] initWithNSDictionary:sample_dict];
    
    XCTAssertEqualObjects(sample_payload.payload,
                          [[NSDictionary alloc] init],
                          @"Payload should be initialized to an empty NSDictionary");
}

- (void)testAddValueToPayload
{
    NSDictionary *sample_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Value1", @"Key1", nil];
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] init];
    [sample_payload addValueToPayload:@"Value1" withKey:@"Key1"];
    
    
    XCTAssertEqualObjects(sample_payload.payload,
                          sample_dict,
                          @"Payload should have the correctly added payload");
}

- (void)testAddValueToPayload2
{
    NSDictionary *sample_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Value2", @"Key2", nil];
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] init];
    [sample_payload addValueToPayload:@"Value1" withKey:@"Key1"];
    
    
    XCTAssertNotEqualObjects(sample_payload.payload,
                          sample_dict,
                          @"Payload should not be the same as sample_dict");
}

- (void)testAddValueToPayload3
{
    NSDictionary *sample_dict_init = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Value1", @"Key1", nil];
    NSDictionary *sample_dict_final = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Value1", @"Key1",
                                 @"Value2", @"Key2", nil];
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] initWithNSDictionary:sample_dict_init];
    [sample_payload addValueToPayload:@"Value2" withKey:@"Key2"];
    
    XCTAssertEqualObjects(sample_payload.payload,
                          sample_dict_final,
                          @"Payload should have the same data as sample_dict_final");
}

- (void)testAddDictToPayload
{
    NSDictionary *sample_dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"Value1", @"Key1", nil];
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] init];
    [sample_payload addDictionaryToPayload:sample_dic];
    
    XCTAssertEqualObjects(sample_payload.payload,
                          sample_dic,
                          @"Payload should contain the exact same contents added from sample_dic");
}

- (void)testAddDictToPayload2
{
    NSDictionary *sample_dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"Value1", @"Key1", nil];
    NSDictionary *sample_dic2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"Value2", @"Key2", nil];
    NSDictionary *sample_dict_final = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       @"Value1", @"Key1",
                                       @"Value2", @"Key2", nil];
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] initWithNSDictionary:sample_dic];
    [sample_payload addDictionaryToPayload:sample_dic2];
    
    XCTAssertEqualObjects(sample_payload.payload,
                          sample_dict_final,
                          @"Payload should contain the exact same contents added from sample_dic_final");
}

- (void)testGetPayload
{
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] init];
    
    XCTAssertEqualObjects(sample_payload.getPayload,
                          [[NSDictionary alloc] init],
                          @"Payload should be initialized to an empty dictionary");
}

- (void)testGetPayload2
{
    NSDictionary *sample_dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Value1", @"Key1", nil];
    SnowplowPayload *sample_payload = [[SnowplowPayload alloc] initWithNSDictionary:@{@"Key1": @"Value1"}];
    
    XCTAssertEqualObjects(sample_payload.getPayload,
                          sample_dict,
                          @"Payload should be initialized to an empty dictionary");
}

@end
