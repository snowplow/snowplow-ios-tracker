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

@property (atomic) NSNumber *lastSessionCheck;
@property (weak) SPTracker *tracker;

@end

@implementation SPSession {
    NSInteger   _foregroundTimeout;
    NSInteger   _backgroundTimeout;
    BOOL        _inBackground;
    BOOL        _isNewSession;
    BOOL        _isSessionCheckerEnabled;
    NSString *  _userId;
    NSString *  _currentSessionId;
    NSString *  _previousSessionId;
    NSInteger   _sessionIndex;
    NSString *  _sessionStorage;
    NSString *  _firstEventId;
    NSDictionary * _sessionDict;
    NSInteger   _foregroundIndex;
    NSInteger   _backgroundIndex;
}

NSString * const kSessionSavePath = @"session.dict";

- (id) init {
    return [self initWithForegroundTimeout:600 andBackgroundTimeout:300 andTracker:nil];
}

- (id) initWithTracker:(SPTracker *)tracker {
    return [self initWithForegroundTimeout:600 andBackgroundTimeout:300 andTracker:tracker];
}

- (instancetype)initWithForegroundTimeout:(NSInteger)foregroundTimeout andBackgroundTimeout:(NSInteger)backgroundTimeout {
    return [self initWithForegroundTimeout:foregroundTimeout andBackgroundTimeout:backgroundTimeout];
}

- (instancetype)initWithForegroundTimeout:(NSInteger)foregroundTimeout andBackgroundTimeout:(NSInteger)backgroundTimeout andTracker:(SPTracker *)tracker {
    if (self = [super init]) {
        _foregroundTimeout = foregroundTimeout * 1000;
        _backgroundTimeout = backgroundTimeout * 1000;
        _inBackground = NO;
        _isNewSession = YES;
        _sessionStorage = @"LOCAL_STORAGE";
        _tracker = tracker;

        NSDictionary * storedSessionDict = [self getSessionFromFile];
        if (storedSessionDict) {
            _userId = [storedSessionDict valueForKey:kSPSessionUserId];
            _currentSessionId = [storedSessionDict valueForKey:kSPSessionId];
            _sessionIndex = [[storedSessionDict valueForKey:kSPSessionIndex] intValue];
        } else {
            _userId = [SPUtilities getUUIDString];
            _currentSessionId = nil;
            _sessionIndex = -1;
        }
        
        self.lastSessionCheck = [SPUtilities getTimestamp];
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
    _isSessionCheckerEnabled = YES;
}

- (void) stopChecker {
    _isSessionCheckerEnabled = NO;
}

- (void) setForegroundTimeout:(NSInteger)foregroundTimeout {
    _foregroundTimeout = foregroundTimeout;
}

- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout {
    _backgroundTimeout = backgroundTimeout;
}

- (NSDictionary *) getSessionDictWithEventId:(NSString *)eventId {
    if (!_isSessionCheckerEnabled) {
        return [_sessionDict copy];
    }
    @synchronized (self) {
        if ([self shouldUpdateSession]) {
            [self updateSessionWithEventId:eventId];
        }
        self.lastSessionCheck = [SPUtilities getTimestamp];
        return [_sessionDict copy];
    }
}

- (NSInteger) getForegroundTimeout {
    return _foregroundTimeout;
}

- (NSInteger) getBackgroundTimeout {
    return _backgroundTimeout;
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

- (BOOL)shouldUpdateSession {
    if (_isNewSession) {
        return YES;
    }
    long long lastAccess = self.lastSessionCheck.longLongValue;
    long long now = [SPUtilities getTimestamp].longLongValue;
    NSInteger timeout = _inBackground ? _backgroundTimeout : _foregroundTimeout;
    return now < lastAccess || now - lastAccess > timeout;
}

- (void)updateSessionWithEventId:(NSString *)eventId {
    _isNewSession = NO;
    _firstEventId = eventId;
    _previousSessionId = _currentSessionId;
    _currentSessionId = [SPUtilities getUUIDString];
    _sessionIndex++;
    
    // Update session dictionary used as context for events
    NSMutableDictionary *newSessionDict = [NSMutableDictionary new];
    if (_firstEventId) {
        [newSessionDict setObject:_firstEventId forKey:kSPSessionFirstEventId];
    }
    [newSessionDict setObject:_userId forKey:kSPSessionUserId];
    [newSessionDict setObject:_currentSessionId forKey:kSPSessionId];
    [newSessionDict setObject:(_previousSessionId != nil ? _previousSessionId : [NSNull null]) forKey:kSPSessionPreviousId];
    [newSessionDict setObject:[NSNumber numberWithInt:(int)_sessionIndex] forKey:kSPSessionIndex];
    [newSessionDict setObject:_sessionStorage forKey:kSPSessionStorage];
    _sessionDict = [newSessionDict copy];

    [self writeSessionToFile];
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
}

@end
