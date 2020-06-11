//
//  TestTracker.m
//  Snowplow
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPPayload.h"
#import "SPSubject.h"
#import "SPDevicePlatform.h"
#import "SPTrackerEvent.h"


/// Category needed to make the private methods testable.
@interface SPTracker (Testing)
- (SPPayload *)payloadWithEvent:(SPTrackerEvent *)event;
@end


@interface TestTracker : XCTestCase
@end

@implementation TestTracker

NSString *const TEST_SERVER_TRACKER = @"http://www.notarealurl.com";

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testTrackerBuilderAndOptions {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:TEST_SERVER_TRACKER];
    }];
    
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:YES];
    
    SPTracker * tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:@"anAppId"];
        [builder setBase64Encoded:NO];
        [builder setTrackerNamespace:@"aNamespace"];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:300];
        [builder setBackgroundTimeout:150];
        [builder setCheckInterval:10];
    }];
    
    // Test builder setting properly
    
    XCTAssertNotNil([tracker emitter]);
    XCTAssertEqual([tracker emitter], emitter);
    XCTAssertNotNil([tracker subject]);
    XCTAssertEqual([tracker subject], subject);
    XCTAssertEqual([tracker devicePlatform], [SPUtilities getPlatform]);
    XCTAssertTrue([tracker getSessionIndex] >= 1);
    XCTAssertEqual([tracker appId], @"anAppId");
    XCTAssertEqual([tracker trackerNamespace], @"aNamespace");
    XCTAssertEqual([tracker base64Encoded], NO);
    XCTAssertEqual([tracker getInBackground], NO);
    XCTAssertEqual([tracker getIsTracking], YES);
    
    // Test Pause/Resume logic
    
    [tracker pauseEventTracking];
    XCTAssertEqual([tracker getIsTracking], NO);
    [tracker resumeEventTracking];
    XCTAssertEqual([tracker getIsTracking], YES);
    
    // Test setting variables to new values
    
    [tracker setAppId:@"newAppId"];
    XCTAssertEqual([tracker appId], @"newAppId");
    [tracker setTrackerNamespace:@"newNamespace"];
    XCTAssertEqual([tracker trackerNamespace], @"newNamespace");
    [tracker setBase64Encoded:YES];
    XCTAssertEqual([tracker base64Encoded], YES);
    [tracker setDevicePlatform:SPDevicePlatformGeneral];
    XCTAssertEqual([tracker devicePlatform], SPDevicePlatformGeneral);
    
    SPSubject * subject2 = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:YES];
    [tracker setSubject:subject2];
    XCTAssertNotEqual([tracker subject], subject);
    XCTAssertEqual([tracker subject], subject2);
    
    SPEmitter * emitter2 = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:TEST_SERVER_TRACKER];
    }];
    [tracker setEmitter:emitter2];
    XCTAssertNotEqual([tracker emitter], emitter);
    XCTAssertEqual([tracker emitter], emitter2);
    
    // Test Session Switch on/off
    
    [tracker setSessionContext:NO];
    XCTAssertTrue([tracker getSessionIndex] == 0);
    
    [tracker setSessionContext:YES];
    XCTAssertTrue([tracker getSessionIndex] > 0);
    
    [tracker setForegroundTimeout:10];
    [tracker setBackgroundTimeout:20];
    [tracker setCheckInterval:15];
    
    @try {
        tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
            [builder setSubject:subject];
            [builder setAppId:@"anAppId"];
            [builder setBase64Encoded:NO];
            [builder setTrackerNamespace:@"aNamespace"];
            [builder setSessionContext:YES];
            [builder setForegroundTimeout:300];
            [builder setBackgroundTimeout:150];
            [builder setCheckInterval:10];
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(@"Emitter cannot be nil.", exception.reason);
    }
}

- (void)testTrackerPayload {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:TEST_SERVER_TRACKER];
    }];
    
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:YES];
    
    SPTracker * tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setDevicePlatform: SPDevicePlatformGeneral];
        [builder setAppId:@"anAppId"];
        [builder setBase64Encoded:NO];
        [builder setTrackerNamespace:@"aNamespace"];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:300];
        [builder setBackgroundTimeout:150];
        [builder setCheckInterval:10];
    }];
    
    SPPrimitive *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"Category"];
        [builder setAction:@"Action"];
        [builder setLabel:@"Label"];
    }];
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    SPPayload *payload = [tracker payloadWithEvent:trackerEvent];
    NSDictionary *payloadDict = [payload getAsDictionary];

    XCTAssertEqual(payloadDict[kSPPlatform], SPDevicePlatformToString(SPDevicePlatformGeneral));
    XCTAssertEqual(payloadDict[kSPAppId], @"anAppId");
    XCTAssertEqual(payloadDict[kSPNamespace], @"aNamespace");

    // Test setting variables to new values

    [tracker setDevicePlatform:-13];
    [tracker setAppId:@"newAppId"];
    [tracker setTrackerNamespace:@"newNamespace"];

    payload = [tracker payloadWithEvent:trackerEvent];
    payloadDict = [payload getAsDictionary];

    XCTAssertEqual(payloadDict[kSPPlatform], nil);
    XCTAssertEqual(payloadDict[kSPAppId], @"newAppId");
    XCTAssertEqual(payloadDict[kSPNamespace], @"newNamespace");
}

- (void)testEventIdNotDuplicated {
    SPPrimitive *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
        [builder setCategory:@"Category"];
        [builder setAction:@"Action"];
        [builder setLabel:@"Label"];
    }];
    NSUUID *eventId = [[SPTrackerEvent alloc] initWithEvent:event].eventId;
    XCTAssertNotNil(eventId);
    NSUUID *newEventId = [[SPTrackerEvent alloc] initWithEvent:event].eventId;
    XCTAssertNotNil(newEventId);
    XCTAssertNotEqualObjects(eventId, newEventId);
}

@end
