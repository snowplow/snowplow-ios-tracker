//
//  TestSession.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPSession.h"
#import "SPTrackerConstants.h"

/// Category needed to make the private methods testable.
@interface SPSession (Testing)

- (void)updateInBackground;
- (void)updateInForeground;

@end

@interface TestSession : XCTestCase

@end

@implementation TestSession

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    SPSession * session = [[SPSession alloc] init];
    XCTAssertNil([session getTracker]);
    XCTAssertTrue(![session getInBackground]);
    XCTAssertTrue([session getSessionIndex] >= -1);
    XCTAssertNotNil([session getSessionDictWithEventId:@"eventid-1"]);
    XCTAssertEqual([session getForegroundTimeout], 600000);
    XCTAssertEqual([session getBackgroundTimeout], 300000);
}

- (void)testInitWithOptions {
    SPSession * session = [[SPSession alloc] initWithForegroundTimeout:5 andBackgroundTimeout:300 andTracker:nil];
    XCTAssertEqual([session getForegroundTimeout], 5000);
    XCTAssertEqual([session getBackgroundTimeout], 300000);
    
    [session setBackgroundTimeout:5];
    [session setForegroundTimeout:10];
    
    XCTAssertEqual([session getForegroundTimeout], 10);
    XCTAssertEqual([session getBackgroundTimeout], 5);
}

- (void)testInitInBgThread {
    __block SPSession * session = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        session = [[SPSession alloc] initWithForegroundTimeout:1 andBackgroundTimeout:1 andTracker:nil];
    });
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [NSThread sleepForTimeInterval:1];
    XCTAssertNotNil(session);
}

- (void)testFirstSession {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:3 andBackgroundTimeout:3 andTracker:nil];
    NSInteger oldSessionIndex = [session getSessionIndex];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1"];
    NSInteger sessionIndex = [session getSessionIndex];
    XCTAssertEqual(1, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
}

- (void)testEventsOnSameSession {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:3 andBackgroundTimeout:3 andTracker:nil];
    NSInteger oldSessionIndex = [session getSessionIndex];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1"];
    NSInteger sessionIndex = [session getSessionIndex];
    NSString *sessionId = [sessionContext objectForKey:kSPSessionId];
    XCTAssertEqual(1, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    oldSessionIndex = sessionIndex;
    
    [NSThread sleepForTimeInterval:1];

    sessionContext = [session getSessionDictWithEventId:@"event_2"];
    sessionIndex = [session getSessionIndex];
    XCTAssertEqual(0, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    oldSessionIndex = sessionIndex;
    
    [NSThread sleepForTimeInterval:1];

    sessionContext = [session getSessionDictWithEventId:@"event_3"];
    sessionIndex = [session getSessionIndex];
    XCTAssertEqual(0, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    oldSessionIndex = sessionIndex;

    [NSThread sleepForTimeInterval:3.1];

    sessionContext = [session getSessionDictWithEventId:@"event_4"];
    sessionIndex = [session getSessionIndex];
    XCTAssertEqual(1, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_4", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertNotEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
}

- (void)testBackgroundEventsOnSameSession {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:3 andBackgroundTimeout:2 andTracker:nil];
    NSInteger oldSessionIndex = [session getSessionIndex];
    
    [session updateInBackground];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1"];
    NSInteger sessionIndex = [session getSessionIndex];
    NSString *sessionId = [sessionContext objectForKey:kSPSessionId];
    XCTAssertEqual(1, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    oldSessionIndex = sessionIndex;
    
    [NSThread sleepForTimeInterval:1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_2"];
    sessionIndex = [session getSessionIndex];
    XCTAssertEqual(0, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    oldSessionIndex = sessionIndex;
    
    [NSThread sleepForTimeInterval:1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_3"];
    sessionIndex = [session getSessionIndex];
    XCTAssertEqual(0, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    oldSessionIndex = sessionIndex;
    
    [NSThread sleepForTimeInterval:2.1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_4"];
    sessionIndex = [session getSessionIndex];
    XCTAssertEqual(1, sessionIndex - oldSessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_4", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertNotEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
}

- (void)testMixedEventsOnManySessions {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:1 andBackgroundTimeout:1 andTracker:nil];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1"];
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(0, [session getBackgroundIndex]);
    XCTAssertEqual(0, [session getForegroundIndex]);
    NSString *oldSessionId = [sessionContext objectForKey:kSPSessionId];
    
    [session updateInBackground];
    [NSThread sleepForTimeInterval:1.1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_2"];
    XCTAssertEqualObjects(oldSessionId, [sessionContext objectForKey:kSPSessionPreviousId]);
    XCTAssertEqualObjects(@"event_2", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    XCTAssertEqual(0, [session getForegroundIndex]);
    oldSessionId = [sessionContext objectForKey:kSPSessionId];

    [session updateInForeground];
    [NSThread sleepForTimeInterval:1.1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_3"];
    XCTAssertEqualObjects(oldSessionId, [sessionContext objectForKey:kSPSessionPreviousId]);
    XCTAssertEqualObjects(@"event_3", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    XCTAssertEqual(1, [session getForegroundIndex]);
    oldSessionId = [sessionContext objectForKey:kSPSessionId];

    [session updateInBackground];
    [NSThread sleepForTimeInterval:1.1];

    sessionContext = [session getSessionDictWithEventId:@"event_4"];
    XCTAssertEqualObjects(oldSessionId, [sessionContext objectForKey:kSPSessionPreviousId]);
    XCTAssertEqualObjects(@"event_4", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(2, [session getBackgroundIndex]);
    XCTAssertEqual(1, [session getForegroundIndex]);
}

- (void)testTimeoutSessionWhenPauseAndResume {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:1 andBackgroundTimeout:1 andTracker:nil];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1"];
    NSInteger oldSessionIndex = [session getSessionIndex];
    NSString *prevSessionId = [sessionContext objectForKey:kSPSessionId];
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    
    [session stopChecker];
    [NSThread sleepForTimeInterval:2];
    
    sessionContext = [session getSessionDictWithEventId:@"event_2"];
    XCTAssertEqual(oldSessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(prevSessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    oldSessionIndex = [session getSessionIndex];
    prevSessionId = [sessionContext objectForKey:kSPSessionId];
    
    [session startChecker];
    
    sessionContext = [session getSessionDictWithEventId:@"event_3"];
    XCTAssertEqual(oldSessionIndex + 1, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(prevSessionId, [sessionContext objectForKey:kSPSessionPreviousId]);
    XCTAssertEqualObjects(@"event_3", [sessionContext objectForKey:kSPSessionFirstEventId]);
}

- (void)testNoEventsForLongTimeDontIncreaseSessionIndexMultipleTimes {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:1 andBackgroundTimeout:1 andTracker:nil];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1"];
    NSInteger oldSessionIndex = [session getSessionIndex];
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    
    [NSThread sleepForTimeInterval:4];
    
    sessionContext = [session getSessionDictWithEventId:@"event_2"];
    XCTAssertEqual(oldSessionIndex + 1, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_2", [sessionContext objectForKey:kSPSessionFirstEventId]);
}

- (void)testMultipleTrackersUpdateDifferentSessions {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@""];
    }];
    SPTracker *tracker1 = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker1"];
        [builder setEmitter:emitter];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:10];
        [builder setBackgroundTimeout:10];
    }];
    SPTracker *tracker2 = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker2"];
        [builder setEmitter:emitter];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:10];
        [builder setBackgroundTimeout:10];
    }];
    SPEvent *event = [[SPStructured alloc] initWithCategory:@"c" action:@"a"];
    [tracker1 track:event];
    [tracker2 track:event];

    NSInteger initialValue1 = [tracker1.session getSessionIndex];
    NSString *id1 = [tracker1.session getSessionId];
    NSInteger initialValue2 = [tracker2.session getSessionIndex];
    NSString *id2 = [tracker2.session getSessionId];

    // Retrigger session in tracker1
    [NSThread sleepForTimeInterval:7];
    [tracker1 track:event];
    [NSThread sleepForTimeInterval:5];

    // Send event to force update of session on tracker2
    [tracker2 track:event];
    id2 = [tracker2.session getSessionId];

    // Check sessions have the correct state
    XCTAssertEqual(0, [tracker1.session getSessionIndex] - initialValue1); // retriggered
    XCTAssertEqual(1, [tracker2.session getSessionIndex] - initialValue2); // timed out
    
    //Recreate tracker2
    SPTracker *tracker2b = [SPTracker build:^(id<SPTrackerBuilder> _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker2"];
        [builder setEmitter:emitter];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:5];
        [builder setBackgroundTimeout:5];
    }];
    [tracker2b track:event];
    NSInteger initialValue2b = [tracker2b.session getSessionIndex];
    NSString *previousId2b = [tracker2b.session getPreviousSessionId];

    // Check the new tracker session gets the data from the old tracker2 session
    XCTAssertEqual(initialValue2 + 2, initialValue2b);
    XCTAssertEqualObjects(id2, previousId2b);
    XCTAssertNotEqualObjects(id1, previousId2b);
}

@end
