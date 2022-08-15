//
//  TestWebViewMessageHandler.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Matus Tomlein
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>

#import "SPSnowplow.h"
#import "SPWebViewMessageHandler.h"
#import "Utils/SPMockNetworkConnection.h"
#import "Utils/SPMockWKScriptMessage.h"

@interface TestWebViewMessageHandler : XCTestCase

@property (nonatomic) SPWebViewMessageHandler *webViewMessageHandler;
@property (nonatomic) SPMockNetworkConnection *networkConnection;

@end

@implementation TestWebViewMessageHandler

- (void)setUp {
    self.webViewMessageHandler = [[SPWebViewMessageHandler alloc] init];
    self.networkConnection = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodPost statusCode:200];
    
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithNetworkConnection:self.networkConnection];
    SPTrackerConfiguration *trackerConfig = [[SPTrackerConfiguration alloc] init];
    [trackerConfig base64Encoding:NO];
    [trackerConfig sessionContext:NO];
    [trackerConfig platformContext:NO];

    [SPSnowplow removeAllTrackers];
    [SPSnowplow createTrackerWithNamespace:[[NSUUID UUID] UUIDString] network:networkConfig configurations:@[trackerConfig]];
}

- (void)tearDown {
    [SPSnowplow removeAllTrackers];
}

- (void)testTracksStructuredEventWithAllProperties {
    SPMockWKScriptMessage *message = [[SPMockWKScriptMessage alloc] initWithBody:@{
        @"command": @"trackStructEvent",
        @"event": @{
            @"category": @"cat",
            @"action": @"act",
            @"label": @"lbl",
            @"property": @"prop",
            @"value": @10.0,
        }
    }];
    [self.webViewMessageHandler userContentController:nil didReceiveScriptMessage:message];
    
    for (int i = 0; i < 10 && [self.networkConnection sendingCount] == 0; i++) {
        [NSThread sleepForTimeInterval:0.5];
    }
    
    XCTAssertEqual(1, [self.networkConnection sendingCount]);
    XCTAssertEqual(1, [[self.networkConnection.previousRequests objectAtIndex:0] count]);
    SPRequest *request = [[self.networkConnection.previousRequests objectAtIndex:0] objectAtIndex:0];
    NSDictionary *payload = [(NSArray *)[[[request payload] getAsDictionary] objectForKey:@"data"] objectAtIndex:0];
    XCTAssert([[payload objectForKey:@"se_ca"] isEqualToString:@"cat"]);
    XCTAssert([[payload objectForKey:@"se_ac"] isEqualToString:@"act"]);
    XCTAssert([[payload objectForKey:@"se_pr"] isEqualToString:@"prop"]);
    XCTAssert([[payload objectForKey:@"se_la"] isEqualToString:@"lbl"]);
    XCTAssert([[payload objectForKey:@"se_va"] isEqualToString:@"10"]);
}

- (void)testTracksEventWithCorrectTracker {
    // create the second tracker
    SPMockNetworkConnection *networkConnection2 = [[SPMockNetworkConnection alloc] initWithRequestOption:SPHttpMethodPost statusCode:200];
    SPNetworkConfiguration *networkConfig = [[SPNetworkConfiguration alloc] initWithNetworkConnection:networkConnection2];
    [SPSnowplow createTrackerWithNamespace:@"ns2" network:networkConfig configurations:@[]];

    // track an event using the second tracker
    SPMockWKScriptMessage *message = [[SPMockWKScriptMessage alloc] initWithBody:@{
        @"command": @"trackPageView",
        @"event": @{
            @"url": @"http://localhost"
        },
        @"trackers": @[@"ns2"]
    }];
    [self.webViewMessageHandler userContentController:nil didReceiveScriptMessage:message];

    // wait and check for the event
    for (int i = 0; i < 10 && [networkConnection2 sendingCount] == 0; i++) {
        [NSThread sleepForTimeInterval:0.5];
    }

    XCTAssertEqual(0, [self.networkConnection sendingCount]);
    XCTAssertEqual(1, [networkConnection2 sendingCount]);
    XCTAssertEqual(1, [[[networkConnection2 previousRequests] objectAtIndex:0] count]);
}

- (void)testTracksEventWithContext {
    SPMockWKScriptMessage *message = [[SPMockWKScriptMessage alloc] initWithBody:@{
        @"command": @"trackSelfDescribingEvent",
        @"event": @{
            @"schema": @"http://schema.com",
            @"data": @{
                @"key": @"val"
            }
        },
        @"context": @[
            @{
                @"schema": @"http://context-schema.com",
                @"data": @{
                    @"a": @"b"
                }
            }
        ]
    }];
    [self.webViewMessageHandler userContentController:nil didReceiveScriptMessage:message];

    for (int i = 0; i < 10 && [self.networkConnection sendingCount] == 0; i++) {
        [NSThread sleepForTimeInterval:0.5];
    }

    XCTAssertEqual(1, [self.networkConnection sendingCount]);
    XCTAssertEqual(1, [[self.networkConnection.previousRequests objectAtIndex:0] count]);
    SPRequest *request = [[self.networkConnection.previousRequests objectAtIndex:0] objectAtIndex:0];
    NSDictionary *payload = [(NSArray *)[[[request payload] getAsDictionary] objectForKey:@"data"] objectAtIndex:0];

    NSString *context = [payload objectForKey:@"co"];
    XCTAssert([context containsString:@"{\"a\":\"b\"}"]);
}

@end
