//
//  TestMemoryEventStore.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPMemoryEventStore.h"
#import "SPPayload.h"

@interface TestMemoryEventStore : XCTestCase
@end

@implementation TestMemoryEventStore

- (void)testInit {
    SPMemoryEventStore * eventStore = [[SPMemoryEventStore alloc] init];
    XCTAssertNotNil(eventStore);
}

- (void)testInsertPayload {
    SPMemoryEventStore * eventStore = [[SPMemoryEventStore alloc] init];
    [eventStore removeAllEvents];
    
    // Build an event
    SPPayload * payload = [[SPPayload alloc] init];
    [payload addValueToPayload:@"pv"                 forKey:@"e"];
    [payload addValueToPayload:@"www.foobar.com"     forKey:@"url"];
    [payload addValueToPayload:@"Welcome to foobar!" forKey:@"page"];
    [payload addValueToPayload:@"MEEEE"              forKey:@"refr"];
    
    // Insert an event
    [eventStore addEvent:payload];
    
    XCTAssertEqual([eventStore count], 1);
    NSArray<SPEmitterEvent *> *events = [eventStore emittableEventsWithQueryLimit:1];
    XCTAssertEqualObjects([events[0].payload getAsDictionary], [payload getAsDictionary]);
    [eventStore removeEventWithId:0];
    
    XCTAssertEqual([eventStore count], 0);
}

- (void)testInsertManyPayloads {
    SPMemoryEventStore * eventStore = [[SPMemoryEventStore alloc] init];
    [eventStore removeAllEvents];
    
    // Build an event
    SPPayload * payload = [[SPPayload alloc] init];
    [payload addValueToPayload:@"pv"                 forKey:@"e"];
    [payload addValueToPayload:@"www.foobar.com"     forKey:@"url"];
    [payload addValueToPayload:@"Welcome to foobar!" forKey:@"page"];
    [payload addValueToPayload:@"MEEEE"              forKey:@"refr"];
    
    for (int i = 0; i < 250; i++) {
        [eventStore addEvent:payload];
    }
    
    XCTAssertEqual([eventStore count], 250);
    XCTAssertEqual([eventStore emittableEventsWithQueryLimit:600].count, 250);
    XCTAssertEqual([eventStore emittableEventsWithQueryLimit:150].count, 150);
    
    [eventStore removeAllEvents];
    XCTAssertEqual([eventStore count], 0);
}

@end
