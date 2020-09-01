//
//  SPSession.m
//  Snowplow
//
//  Copyright (c) 2020 Snowplow Analytics Ltd. All rights reserved.
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

#import "Snowplow.h"
#import "SPSession.h"
#import "SPUtilities.h"
#import "SPWeakTimerTarget.h"
#import "SPTracker.h"

#import "SPBackground.h"
#import "SPForeground.h"

#if SNOWPLOW_TARGET_IOS
#import <UIKit/UIKit.h>
#endif

@interface SPSession ()

@property (atomic) NSNumber *accessedLast;
@property (weak) SPTracker *tracker;

@end

@implementation SPSession {
    NSInteger   _foregroundTimeout;
    NSInteger   _backgroundTimeout;
    NSInteger   _checkInterval;
    BOOL        _inBackground;
    NSString *  _userId;
    NSString *  _currentSessionId;
    NSString *  _previousSessionId;
    NSInteger   _sessionIndex;
    NSString *  _sessionStorage;
    NSString *  _firstEventId;
    NSTimer *   _sessionTimer;
    NSDictionary * _sessionDict;
    dispatch_queue_t _sessionQueue;
    NSInteger   _foregroundIndex;
    NSInteger   _backgroundIndex;
}

NSString * const kSessionSavePath = @"session.dict";

- (id) init {
    return [self initWithForegroundTimeout:600 andBackgroundTimeout:300 andCheckInterval:15 andTracker:nil];
}

- (id) initWithTracker:(SPTracker *)tracker {
    return [self initWithForegroundTimeout:600 andBackgroundTimeout:300 andCheckInterval:15 andTracker:tracker];
}

- (id) initWithForegroundTimeout:(NSInteger)foregroundTimeout andBackgroundTimeout:(NSInteger)backgroundTimeout andCheckInterval:(NSInteger)checkInterval {
    return [self initWithForegroundTimeout:600 andBackgroundTimeout:300 andCheckInterval:15 andTracker:nil];
}

- (id) initWithForegroundTimeout:(NSInteger)foregroundTimeout andBackgroundTimeout:(NSInteger)backgroundTimeout andCheckInterval:(NSInteger)checkInterval andTracker:(SPTracker *)tracker{
    self = [super init];
    if (self) {
        _sessionQueue = dispatch_queue_create("com.snowplow.sessionUpdates", DISPATCH_QUEUE_SERIAL);
        _foregroundTimeout = foregroundTimeout * 1000;
        _backgroundTimeout = backgroundTimeout * 1000;
        _checkInterval = checkInterval;
        _inBackground = NO;
        _sessionStorage = @"SQLITE";
        _tracker = tracker;

        NSDictionary * maybeSessionDict = [self getSessionFromFile];
        if (maybeSessionDict == nil) {
            _userId = [SPUtilities getUUIDString];
            _currentSessionId = nil;
        } else {
            _userId = [maybeSessionDict valueForKey:kSPSessionUserId];
            _currentSessionId = [maybeSessionDict valueForKey:kSPSessionId];
            _sessionIndex = [[maybeSessionDict valueForKey:kSPSessionIndex] intValue];
        }
        
        [self updateSession];
        [self updateAccessedLast];
        [self updateSessionDict];
        [self writeSessionToFile];
        [self startChecker];

        // Trigger notification for view changes
        #if SNOWPLOW_TARGET_IOS
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInBackground)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInForeground)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        #endif
    }
    return self;
}

// --- Public

- (void) startChecker {
    __weak __typeof__(self) weakSelf = self;

    if (_sessionTimer != nil) {
        [self stopChecker];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;

        strongSelf->_sessionTimer = [NSTimer scheduledTimerWithTimeInterval:strongSelf->_checkInterval
                                                         target:[[SPWeakTimerTarget alloc] initWithTarget:strongSelf andSelector:@selector(checkSession:)]
                                                       selector:@selector(timerFired:)
                                                       userInfo:nil
                                                        repeats:YES];
    });
}

- (void) stopChecker {
    [_sessionTimer invalidate];
    _sessionTimer = nil;
}

- (void) setForegroundTimeout:(NSInteger)foregroundTimeout {
    _foregroundTimeout = foregroundTimeout;
}

- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout {
    _backgroundTimeout = backgroundTimeout;
}

- (void) setCheckInterval:(NSInteger)checkInterval {
    _checkInterval = checkInterval;
    [self stopChecker];
    [self startChecker];
}

- (NSDictionary *) getSessionDictWithEventId:(NSString *)firstEventId {
    [self updateAccessedLast];
    if (_firstEventId == nil) {
        _firstEventId = firstEventId;
        [self addFirstEventIdToDict];
    }
    return [_sessionDict copy];
}

- (NSInteger) getForegroundTimeout {
    return _foregroundTimeout;
}

- (NSInteger) getBackgroundTimeout {
    return _backgroundTimeout;
}

- (NSInteger) getCheckInterval {
    return _checkInterval;
}

- (NSInteger) getSessionIndex {
    return _sessionIndex;
}

- (BOOL) getInBackground {
    return _inBackground;
}

- (NSString *)getUserId {
    return _userId;
}

- (NSString *)getSessionId {
    return _currentSessionId;
}

- (NSInteger) getBackgroundIndex {
    return _backgroundIndex;
}

- (NSInteger) getForegroundIndex {
    return _foregroundIndex;
}

- (SPTracker *) getTracker {
    return self.tracker;
}

// --- Private

- (BOOL) writeSessionToFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    BOOL result = NO;
    if ([paths count] > 0) {
        NSString *savePath = [[paths lastObject] stringByAppendingPathComponent:kSessionSavePath];
        NSMutableDictionary *sessionDict = [_sessionDict mutableCopy];
        [sessionDict removeObjectForKey:kSPSessionPreviousId];
        [sessionDict removeObjectForKey:kSPSessionStorage];
        result = [sessionDict writeToFile:savePath atomically:YES];
    }
    return result;
}

- (NSDictionary *) getSessionFromFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *sessionDict = nil;
    if ([paths count] > 0) {
        NSString * readPath = [[paths lastObject] stringByAppendingPathComponent:kSessionSavePath];
        sessionDict = [NSDictionary dictionaryWithContentsOfFile:readPath];
    }
    return sessionDict;
}

- (void) checkSession:(NSTimer *)timer {
    __weak __typeof__(self) weakSelf = self;
    
    dispatch_async(_sessionQueue, ^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        
        NSNumber *checkTime = [SPUtilities getTimestamp];
        NSInteger range = 0;
        
        if (strongSelf->_inBackground) {
            range = strongSelf->_backgroundTimeout;
        } else {
            range = strongSelf->_foregroundTimeout;
        }
        
        long long accessedLast = strongSelf.accessedLast.longLongValue;
        if ([strongSelf isTimeInRangeWithStartTime:accessedLast andCheckTime:checkTime.longLongValue andRange:range]) {
            // return because last access within the timeout
            return;
        }
        @synchronized (strongSelf) {
            if (accessedLast != strongSelf.accessedLast.longLongValue
                && [strongSelf isTimeInRangeWithStartTime:strongSelf.accessedLast.longLongValue andCheckTime:checkTime.longLongValue andRange:range])
            {
                // return because last access changed but within the timeout
                return;
            }
            [strongSelf updateSession];
            [strongSelf updateAccessedLast];
            [strongSelf updateSessionDict];
            [strongSelf writeSessionToFile];
        }
    });
}

- (void) updateSession {
    _previousSessionId = _currentSessionId;
    _currentSessionId = [SPUtilities getUUIDString];
    _sessionIndex++;
    _firstEventId = nil;
}

- (void) updateAccessedLast {
    self.accessedLast = [SPUtilities getTimestamp];
}

- (void) updateSessionDict {
    NSMutableDictionary * newSessionDict = [[NSMutableDictionary alloc] init];
    [newSessionDict setObject:_userId forKey:kSPSessionUserId];
    [newSessionDict setObject:_currentSessionId forKey:kSPSessionId];
    [newSessionDict setObject:(_previousSessionId != nil ? _previousSessionId : [NSNull null]) forKey:kSPSessionPreviousId];
    [newSessionDict setObject:[NSNumber numberWithInt:(int)_sessionIndex] forKey:kSPSessionIndex];
    [newSessionDict setObject:_sessionStorage forKey:kSPSessionStorage];
    _sessionDict = [newSessionDict copy];
}

- (void) addFirstEventIdToDict {
    NSMutableDictionary *dictionary = [_sessionDict mutableCopy];
    [dictionary setObject:_firstEventId forKey:kSPSessionFirstEventId];
    _sessionDict = dictionary;
}

- (BOOL) isTimeInRangeWithStartTime:(long long)startTime
                       andCheckTime:(long long)checkTime
                           andRange:(long long)range {
    return startTime > (checkTime - range);
}

- (void) updateInBackground {
    if (!_inBackground) {
        _backgroundIndex += 1;
        _inBackground = YES;
        if ([self.tracker getLifecycleEvents]) {
            [self sendBackgroundEvent];
        }
    }
}

- (void) updateInForeground {
    if (_inBackground) {
        _foregroundIndex += 1;
        _inBackground = NO;
        if ([self.tracker getLifecycleEvents]) {
            [self sendForegroundEvent];
        }
    }
}

- (void) sendBackgroundEvent {
    if (self.tracker) {
        __weak __typeof__(self) weakSelf = self;
        SPBackground * backgroundEvent = [SPBackground build:^(id<SPBackgroundBuilder> builder) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) return;
            [builder setIndex:[NSNumber numberWithInteger:strongSelf->_backgroundIndex]];
        }];
        [self.tracker track:backgroundEvent];
    }
}

- (void) sendForegroundEvent {
    if (self.tracker) {
        __weak __typeof__(self) weakSelf = self;
        SPForeground * foregroundEvent = [SPForeground build:^(id<SPForegroundBuilder> builder) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) return;
            [builder setIndex:[NSNumber numberWithInteger:strongSelf->_foregroundIndex]];
        }];
        [self.tracker track:foregroundEvent];
    }
}

- (void) dealloc {
    #if SNOWPLOW_TARGET_IOS
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    #endif
    [_sessionTimer invalidate];
    _sessionTimer = nil;
}

@end
