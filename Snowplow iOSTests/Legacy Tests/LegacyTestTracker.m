//
//  LegacyTestTracker.m
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPPayload.h"
#import "SPSubject.h"
#import "SPDevicePlatform.h"
#import "SPTrackerEvent.h"
#import "SPUtilities.h"
#import "SPStructured.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/// Category needed to make the private methods testable.
@interface SPTracker (Testing)
- (SPPayload *)payloadWithEvent:(SPTrackerEvent *)event;
@end


@interface LegacyTestTracker : XCTestCase
@end

@implementation LegacyTestTracker

NSString *const TEST_SERVER_TRACKER = @"http://www.notarealurl.com";

- (void)testTrackerSetup {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@"not-real.com"];
    }];
    
    SPSubject * subject = [[SPSubject alloc] initWithPlatformContext:YES andGeoContext:YES];
    
    SPTracker * tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:@"anAppId"];
        [builder setBase64Encoded:NO];
        [builder setTrackerNamespace:@"aNamespace"];
        [builder setSessionContext:YES];
    }];
    
    XCTAssertNotNil(subject);
    XCTAssertNotNil(emitter);
    XCTAssertNotNil(tracker);
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
    }];
    
    // Test builder setting properly
    
    XCTAssertNotNil([tracker emitter]);
    XCTAssertEqual([tracker emitter], emitter);
    XCTAssertNotNil([tracker subject]);
    XCTAssertEqual([tracker subject], subject);
    XCTAssertEqual([tracker devicePlatform], [SPUtilities getPlatform]);
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
    
    SPSession *oldSessionManager = tracker.session;
    [tracker setSessionContext:NO];
    XCTAssertNil(tracker.session);
    
    [tracker setSessionContext:YES];
    XCTAssertNotNil(tracker.session);
    XCTAssertNotEqual(oldSessionManager, tracker.session);

    // Test Emitter nil
    
    @try {
        tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
            [builder setSubject:subject];
            [builder setAppId:@"anAppId"];
            [builder setBase64Encoded:NO];
            [builder setTrackerNamespace:@"aNamespace"];
            [builder setSessionContext:YES];
            [builder setForegroundTimeout:300];
            [builder setBackgroundTimeout:150];
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
    }];
    
    SPPrimitiveAbstract *event = [[SPStructured alloc] initWithCategory:@"Category" action:@"Action"];
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
    SPPrimitiveAbstract *event = [[SPStructured alloc] initWithCategory:@"Category" action:@"Action"];
    NSUUID *eventId = [[SPTrackerEvent alloc] initWithEvent:event].eventId;
    XCTAssertNotNil(eventId);
    NSUUID *newEventId = [[SPTrackerEvent alloc] initWithEvent:event].eventId;
    XCTAssertNotNil(newEventId);
    XCTAssertNotEqualObjects(eventId, newEventId);
}

@end

#pragma clang diagnostic pop
