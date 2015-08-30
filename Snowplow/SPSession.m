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
#import "SPUtils.h"
#import "SPPayload.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@implementation SPSession {
    NSInteger         _foregroundTimeout;
    NSInteger         _backgroundTimeout;
    NSInteger         _checkInterval;
    NSInteger         _accessedLast;
    BOOL              _inBackground;
    NSString *        _userId;
    NSString *        _currentSessionId;
    NSString *        _previousSessionId;
    NSInteger         _sessionIndex;
    NSString *        _sessionStorage;
    SPPayload *       _sessionDict;
    NSTimer *         _sessionTimer;
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
            _userId = [SPUtils getEventId];
            _currentSessionId = @"";
        } else {
            _userId = [maybeSessionDict valueForKey:kSessionUserId];
            _currentSessionId = [maybeSessionDict valueForKey:kSessionId];
            _previousSessionId = [maybeSessionDict valueForKey:kSessionPreviousId];
            _sessionIndex = [[maybeSessionDict valueForKey:kSessionIndex] intValue];
        }
        
        [self updateSession];
        [self updateAccessedLast];
        [self updateSessionDict];
        [self writeSessionToFile];
        [self startChecker];
        
        // Trigger notification for view changes
        #if TARGET_OS_IPHONE
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
    dispatch_async(dispatch_get_main_queue(), ^{
        _sessionTimer = [NSTimer scheduledTimerWithTimeInterval:_checkInterval
                                                         target:self
                                                       selector:@selector(checkSession:)
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

- (SPPayload *) getSessionDict {
    [self updateAccessedLast];
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
        NSDictionary * sessionDict = [[self getSessionDict] getPayloadAsDictionary];
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
        NSInteger checkTime = [SPUtils getTimestamp];
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
    _currentSessionId = [SPUtils getEventId];
    _sessionIndex++;
}

- (void) updateAccessedLast {
    _accessedLast = [SPUtils getTimestamp];
}

- (void) updateSessionDict {
    _sessionDict = [[SPPayload alloc] init];
    [_sessionDict addValueToPayload:_userId forKey:kSessionUserId];
    [_sessionDict addValueToPayload:_currentSessionId forKey:kSessionId];
    [_sessionDict addValueToPayload:_previousSessionId forKey:kSessionPreviousId];
    [_sessionDict addValueToPayload:[NSString stringWithFormat:@"%ld", (long)_sessionIndex] forKey:kSessionIndex];
    [_sessionDict addValueToPayload:_sessionStorage forKey:kSessionStorage];
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

@end
