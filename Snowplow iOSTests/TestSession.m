//
//  TestSession.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPSession.h"
#import "SPDataPersistence.h"
#import "SPTrackerConstants.h"
#import "SPEmitter.h"

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
    [self cleanSessionFileWithNamespace:@"tracker"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSPInstallationUserId];
}

- (void)tearDown {
    [super tearDown];
}


- (void)testInit {
    SPSession * session = [[SPSession alloc] init];
    XCTAssertNil([session getTracker]);
    XCTAssertTrue(![session getInBackground]);
    XCTAssertNotNil([session getSessionDictWithEventId:@"eventid-1" eventTimestamp:1654496481346]);
    XCTAssertTrue(session.state.sessionIndex >= 1);
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
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481346];
    NSInteger sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(1, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.346Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
}

- (void)testForegroundEventsOnSameSession {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:3 andBackgroundTimeout:3 andTracker:nil];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481346];
    NSInteger sessionIndex = session.state.sessionIndex;
    NSString *sessionId = [sessionContext objectForKey:kSPSessionId];
    XCTAssertEqual(1, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.346Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    
    [NSThread sleepForTimeInterval:1];

    sessionContext = [session getSessionDictWithEventId:@"event_2" eventTimestamp:1654496481347];
    sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(1, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.346Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    
    [NSThread sleepForTimeInterval:1];

    sessionContext = [session getSessionDictWithEventId:@"event_3" eventTimestamp:1654496481348];
    sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(1, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.346Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);

    [NSThread sleepForTimeInterval:3.1];

    sessionContext = [session getSessionDictWithEventId:@"event_4" eventTimestamp:1654496481349];
    sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(2, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_4", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.349Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertNotEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
}

- (void)testBackgroundEventsOnWhenLifecycleEventsDisabled {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@""];
    }];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker"];
        [builder setEmitter:emitter];
        [builder setLifecycleEvents:NO];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:3];
        [builder setBackgroundTimeout:2];
    }];
    SPSession *session = tracker.session;
    
    [session updateInBackground];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481346];
    NSInteger sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(1, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.346Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(0, [session getBackgroundIndex]);
}

- (void)testBackgroundEventsOnSameSession {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@""];
    }];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker"];
        [builder setEmitter:emitter];
        [builder setInstallEvent:NO];
        [builder setLifecycleEvents:YES];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:3];
        [builder setBackgroundTimeout:2];
    }];
    SPSession *session = tracker.session;
    
    [session updateInBackground]; // It sends a background event

    NSString *sessionId = session.state.sessionId;

    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481346];
    NSInteger sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(1, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    
    [NSThread sleepForTimeInterval:1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_2" eventTimestamp:1654496481347];
    sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(1, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    
    [NSThread sleepForTimeInterval:1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_3" eventTimestamp:1654496481348];
    sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(1, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    
    [NSThread sleepForTimeInterval:2.1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_4" eventTimestamp:1654496481349];
    sessionIndex = session.state.sessionIndex;
    XCTAssertEqual(2, sessionIndex);
    XCTAssertEqual(sessionIndex, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_4", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.349Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertNotEqualObjects(sessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
}

- (void)testMixedEventsOnManySessions {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@""];
    }];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker"];
        [builder setEmitter:emitter];
        [builder setLifecycleEvents:YES];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:1];
        [builder setBackgroundTimeout:1];
    }];
    SPSession *session = tracker.session;
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481351];
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.351Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(0, [session getBackgroundIndex]);
    XCTAssertEqual(0, [session getForegroundIndex]);
    NSString *oldSessionId = [sessionContext objectForKey:kSPSessionId];
    
    [session updateInBackground];
    [NSThread sleepForTimeInterval:1.1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_2" eventTimestamp:1654496481352];
    XCTAssertEqualObjects(oldSessionId, [sessionContext objectForKey:kSPSessionPreviousId]);
    XCTAssertEqualObjects(@"event_2", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.352Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    XCTAssertEqual(0, [session getForegroundIndex]);
    oldSessionId = [sessionContext objectForKey:kSPSessionId];

    [session updateInForeground];
    [NSThread sleepForTimeInterval:1.1];
    
    sessionContext = [session getSessionDictWithEventId:@"event_3" eventTimestamp:1654496481353];
    XCTAssertEqualObjects(oldSessionId, [sessionContext objectForKey:kSPSessionPreviousId]);
    XCTAssertEqualObjects(@"event_3", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.353Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    XCTAssertEqual(1, [session getForegroundIndex]);
    oldSessionId = [sessionContext objectForKey:kSPSessionId];

    [session updateInBackground];
    [NSThread sleepForTimeInterval:1.1];

    sessionContext = [session getSessionDictWithEventId:@"event_4" eventTimestamp:1654496481354];
    XCTAssertEqualObjects(oldSessionId, [sessionContext objectForKey:kSPSessionPreviousId]);
    XCTAssertEqualObjects(@"event_4", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.354Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    XCTAssertTrue([session getInBackground]);
    XCTAssertEqual(2, [session getBackgroundIndex]);
    XCTAssertEqual(1, [session getForegroundIndex]);
}

- (void)testTimeoutSessionWhenPauseAndResume {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:1 andBackgroundTimeout:1 andTracker:nil];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481355];
    NSString *prevSessionId = [sessionContext objectForKey:kSPSessionId];
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.355Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    
    [session stopChecker];
    [NSThread sleepForTimeInterval:2];
    
    sessionContext = [session getSessionDictWithEventId:@"event_2" eventTimestamp:1654496481356];
    XCTAssertEqual(1, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(prevSessionId, [sessionContext objectForKey:kSPSessionId]);
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.355Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
    prevSessionId = [sessionContext objectForKey:kSPSessionId];
    
    [session startChecker];
    
    sessionContext = [session getSessionDictWithEventId:@"event_3" eventTimestamp:1654496481357];
    XCTAssertEqual(2, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(prevSessionId, [sessionContext objectForKey:kSPSessionPreviousId]);
    XCTAssertEqualObjects(@"event_3", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertEqualObjects(@"2022-06-06T06:21:21.357Z", [sessionContext objectForKey:kSPSessionFirstEventTimestamp]);
}

- (void)testBackgroundTimeBiggerThanBackgroundTimeoutCausesNewSession {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@""];
    }];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker"];
        [builder setEmitter:emitter];
        [builder setLifecycleEvents:YES];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:100];
        [builder setBackgroundTimeout:2];
    }];
    SPSession *session = tracker.session;
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481361];
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(0, [session getBackgroundIndex]);
    XCTAssertEqual(0, [session getForegroundIndex]);
    NSString *oldSessionId = [sessionContext objectForKey:kSPSessionId];
    
    [NSThread sleepForTimeInterval:1]; // Smaller than background timeout
    [session updateInBackground]; // Sends a background event
    [NSThread sleepForTimeInterval:3]; // Bigger than background timeout
    [session updateInForeground]; // Sends a foreground event

    XCTAssertEqualObjects(oldSessionId, session.state.previousSessionId);
    XCTAssertEqual(2, session.state.sessionIndex);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    XCTAssertEqual(1, [session getForegroundIndex]);
}

- (void)testBackgroundTimeSmallerThanBackgroundTimeoutDoesntCauseNewSession {
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@""];
    }];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker"];
        [builder setEmitter:emitter];
        [builder setLifecycleEvents:YES];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:100];
        [builder setBackgroundTimeout:2];
    }];
    SPSession *session = tracker.session;
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481358];
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(0, [session getBackgroundIndex]);
    XCTAssertEqual(0, [session getForegroundIndex]);
    NSString *oldSessionId = [sessionContext objectForKey:kSPSessionId];
    
    [NSThread sleepForTimeInterval:3]; // Bigger than background timeout
    [session updateInBackground]; // Sends a background event
    [NSThread sleepForTimeInterval:1]; // Smaller than background timeout
    [session updateInForeground]; // Sends a foreground event

    XCTAssertEqualObjects(oldSessionId, session.state.sessionId);
    XCTAssertEqual(1, session.state.sessionIndex);
    XCTAssertFalse([session getInBackground]);
    XCTAssertEqual(1, [session getBackgroundIndex]);
    XCTAssertEqual(1, [session getForegroundIndex]);
}

- (void)testNoEventsForLongTimeDontIncreaseSessionIndexMultipleTimes {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:1 andBackgroundTimeout:1 andTracker:nil];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481359];
    XCTAssertEqualObjects(@"event_1", [sessionContext objectForKey:kSPSessionFirstEventId]);
    
    [NSThread sleepForTimeInterval:4];
    
    sessionContext = [session getSessionDictWithEventId:@"event_2" eventTimestamp:1654496481360];
    XCTAssertEqual(2, [[sessionContext objectForKey:kSPSessionIndex] intValue]);
    XCTAssertEqualObjects(@"event_2", [sessionContext objectForKey:kSPSessionFirstEventId]);
}

- (void)testMultipleTrackersUpdateDifferentSessions {
    [self cleanSessionFileWithNamespace:@"tracker1"];
    [self cleanSessionFileWithNamespace:@"tracker2"];

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

    NSInteger initialValue1 = tracker1.session.state.sessionIndex;
    NSString *id1 = tracker1.session.state.sessionId;
    NSInteger initialValue2 = tracker2.session.state.sessionIndex;
    NSString *id2 = tracker2.session.state.sessionId;

    // Retrigger session in tracker1
    [NSThread sleepForTimeInterval:7];
    [tracker1 track:event];
    [NSThread sleepForTimeInterval:5];

    // Send event to force update of session on tracker2
    [tracker2 track:event];
    id2 = tracker2.session.state.sessionId;

    // Check sessions have the correct state
    XCTAssertEqual(0, tracker1.session.state.sessionIndex - initialValue1); // retriggered
    XCTAssertEqual(1, tracker2.session.state.sessionIndex - initialValue2); // timed out
    
    //Recreate tracker2
    SPTracker *tracker2b = [SPTracker build:^(id<SPTrackerBuilder> _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker2"];
        [builder setEmitter:emitter];
        [builder setSessionContext:YES];
        [builder setForegroundTimeout:5];
        [builder setBackgroundTimeout:5];
    }];
    [tracker2b track:event];
    NSInteger initialValue2b = tracker2b.session.state.sessionIndex;
    NSString *previousId2b = tracker2b.session.state.previousSessionId;

    // Check the new tracker session gets the data from the old tracker2 session
    XCTAssertEqual(initialValue2 + 2, initialValue2b);
    XCTAssertEqualObjects(id2, previousId2b);
    XCTAssertNotEqualObjects(id1, previousId2b);
}

- (void)testMigrateSessionFromV3_0 {
    [self cleanSessionFileWithNamespace:@"tracker"];
    [self storeSessionAsV3_0WithNamespace:@"tracker" eventId:@"eventId" sessionId:@"sessionId" sessionIndex:123 userId:@"userId"];

    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setUrlEndpoint:@""];
    }];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder>  _Nonnull builder) {
        [builder setTrackerNamespace:@"tracker"];
        [builder setEmitter:emitter];
        [builder setSessionContext:YES];
    }];
    SPEvent *event = [[SPStructured alloc] initWithCategory:@"c" action:@"a"];
    [tracker track:event];

    SPSessionState *sessionState = tracker.session.state;
    XCTAssertEqualObjects(@"sessionId", sessionState.previousSessionId);
    XCTAssertEqual(124, sessionState.sessionIndex);
    XCTAssertEqualObjects(@"userId", sessionState.userId);
    XCTAssertNotEqualObjects(@"eventId", sessionState.firstEventId);
}

- (void)testIncrementsEventIndex {
    SPSession *session = [[SPSession alloc] initWithForegroundTimeout:3 andBackgroundTimeout:3 andTracker:nil];
    
    NSDictionary *sessionContext = [session getSessionDictWithEventId:@"event_1" eventTimestamp:1654496481346];
    XCTAssertEqualObjects(@1, [sessionContext objectForKey:kSPSessionEventIndex]);
    
    [NSThread sleepForTimeInterval:1];

    sessionContext = [session getSessionDictWithEventId:@"event_2" eventTimestamp:1654496481347];
    XCTAssertEqualObjects(@2, [sessionContext objectForKey:kSPSessionEventIndex]);
    
    [NSThread sleepForTimeInterval:1];

    sessionContext = [session getSessionDictWithEventId:@"event_3" eventTimestamp:1654496481348];
    XCTAssertEqualObjects(@3, [sessionContext objectForKey:kSPSessionEventIndex]);

    [NSThread sleepForTimeInterval:3.1];

    sessionContext = [session getSessionDictWithEventId:@"event_4" eventTimestamp:1654496481349];
    XCTAssertEqualObjects(@1, [sessionContext objectForKey:kSPSessionEventIndex]);
}

// Service methods

- (void)cleanSessionFileWithNamespace:(NSString *)namespace {
    [SPDataPersistence removeDataPersistenceWithNamespace:namespace];
}

// Migration methods

- (void)storeSessionAsV3_0WithNamespace:(NSString *)namespace eventId:(NSString *)eventId sessionId:(NSString *)sessionId sessionIndex:(int)sessionIndex userId:(NSString *)userId {
    SPDataPersistence *dataPersistence = [SPDataPersistence dataPersistenceForNamespace:namespace];
    NSMutableDictionary *newSessionDict = [NSMutableDictionary new];
    [newSessionDict setObject:eventId forKey:kSPSessionFirstEventId];
    [newSessionDict setObject:sessionId forKey:kSPSessionId];
    [newSessionDict setObject:[NSNumber numberWithInt:sessionIndex] forKey:kSPSessionIndex];
    dataPersistence.session = newSessionDict;
    
    //Store userId
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userId forKey:kSPInstallationUserId];
}

@end
