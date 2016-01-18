//
//  SPSession.m
//  Snowplow
//
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPSession.h"
#import "SPUtilities.h"
#import "SPWeakTimerTarget.h"

#if SNOWPLOW_TARGET_IOS
#import <UIKit/UIKit.h>
#endif

@implementation SPSession {
    NSInteger   _foregroundTimeout;
    NSInteger   _backgroundTimeout;
    NSInteger   _checkInterval;
    NSInteger   _accessedLast;
    BOOL        _inBackground;
    NSString *  _userId;
    NSString *  _currentSessionId;
    NSString *  _previousSessionId;
    NSInteger   _sessionIndex;
    NSString *  _sessionStorage;
    NSString *  _firstEventId;
    NSTimer *   _sessionTimer;
    NSMutableDictionary * _sessionDict;
}

NSString * const kSessionSavePath = @"session.dict";

- (id) init {
    return [self initWithForegroundTimeout:600 andBackgroundTimeout:300 andCheckInterval:15];
}

- (id) initWithForegroundTimeout:(NSInteger)foregroundTimeout andBackgroundTimeout:(NSInteger)backgroundTimeout andCheckInterval:(NSInteger)checkInterval {
    self = [super init];
    if (self) {
        _foregroundTimeout = foregroundTimeout * 1000;
        _backgroundTimeout = backgroundTimeout * 1000;
        _checkInterval = checkInterval;
        _inBackground = NO;
        _sessionStorage = @"SQLITE";
        
        NSDictionary * maybeSessionDict = [self getSessionFromFile];
        if (maybeSessionDict == nil) {
            _userId = [SPUtilities getEventId];
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
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        #endif
    }
    return self;
}

// --- Public

- (void) startChecker {
    if (_sessionTimer != nil) {
        [self stopChecker];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _sessionTimer = [NSTimer scheduledTimerWithTimeInterval:_checkInterval
                                                         target:[[SPWeakTimerTarget alloc] initWithTarget:self andSelector:@selector(checkSession:)]
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

- (NSMutableDictionary *) getSessionDictWithEventId:(NSString *)firstEventId {
    [self updateAccessedLast];
    if (_firstEventId == nil) {
        _firstEventId = firstEventId;
        [self addFirstEventIdToDict];
    }
    return _sessionDict;
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

// --- Private

- (BOOL) writeSessionToFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    BOOL result = NO;
    if ([paths count] > 0) {
        NSString * savePath = [[paths lastObject] stringByAppendingPathComponent:kSessionSavePath];
        NSMutableDictionary * sessionDict = [NSMutableDictionary dictionaryWithDictionary:_sessionDict];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger checkTime = [SPUtilities getTimestamp];
        NSInteger range = 0;
        
        if (_inBackground) {
            range = _backgroundTimeout;
        } else {
            range = _foregroundTimeout;
        }
        
        if (![self isTimeInRangeWithStartTime:_accessedLast andCheckTime:checkTime andRange:range]) {
            [self updateSession];
            [self updateAccessedLast];
            [self updateSessionDict];
            [self writeSessionToFile];
        }
    });
}

- (void) updateSession {
    _previousSessionId = _currentSessionId;
    _currentSessionId = [SPUtilities getEventId];
    _sessionIndex++;
    _firstEventId = nil;
}

- (void) updateAccessedLast {
    _accessedLast = [SPUtilities getTimestamp];
}

- (void) updateSessionDict {
    NSMutableDictionary * newSessionDict = [[NSMutableDictionary alloc] init];
    [newSessionDict setObject:_userId forKey:kSPSessionUserId];
    [newSessionDict setObject:_currentSessionId forKey:kSPSessionId];
    [newSessionDict setObject:(_previousSessionId != nil ? _previousSessionId : [NSNull null]) forKey:kSPSessionPreviousId];
    [newSessionDict setObject:[NSNumber numberWithInt:(int)_sessionIndex] forKey:kSPSessionIndex];
    [newSessionDict setObject:_sessionStorage forKey:kSPSessionStorage];
    _sessionDict = newSessionDict;
}

- (void) addFirstEventIdToDict {
    [_sessionDict setObject:_firstEventId forKey:kSPSessionFirstEventId];
}

- (BOOL) isTimeInRangeWithStartTime:(NSInteger)startTime
                       andCheckTime:(NSInteger)checkTime
                           andRange:(NSInteger)range {
    return startTime > (checkTime - range);
}

- (void) updateInBackground {
    _inBackground = YES;
}

- (void) updateInForeground {
    _inBackground = NO;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_sessionTimer invalidate];
    _sessionTimer = nil;
}

@end
