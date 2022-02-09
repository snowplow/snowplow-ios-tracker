//
//  SPSession.m
//  Snowplow
//
//  Copyright (c) 2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPDataPersistence.h"
#import "SPTrackerConstants.h"
#import "SPSession.h"
#import "SPUtilities.h"
#import "SPWeakTimerTarget.h"
#import "SPTracker.h"
#import "SPLogger.h"

#import "SPBackground.h"
#import "SPForeground.h"

#if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
#import <UIKit/UIKit.h>
#endif

@interface SPSession ()

@property (atomic) NSNumber *lastSessionCheck;
@property (weak) SPTracker *tracker;
@property (nonatomic) SPDataPersistence *dataPersistence;
@property (nonatomic, readwrite) SPSessionState *state;

@end

@implementation SPSession {
    NSInteger   _foregroundTimeout;
    NSInteger   _backgroundTimeout;
    BOOL        _inBackground;
    BOOL        _isNewSession;
    BOOL        _isSessionCheckerEnabled;
    NSString *  _userId;
    NSInteger   _foregroundIndex;
    NSInteger   _backgroundIndex;
}

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
        self.tracker = tracker;
        self.dataPersistence = [SPDataPersistence dataPersistenceForNamespace:tracker.trackerNamespace];
        NSDictionary *storedSessionDict = self.dataPersistence.session;
        
        if (storedSessionDict) {
            _state = [[SPSessionState alloc] initWithStoredState:storedSessionDict];
        }
        if (!_state) {
            SPLogTrack(nil, @"No previous session info available");
        }
        _userId = [self retrieveUserIdWithState:_state];
        
        // Start session check
        self.lastSessionCheck = [SPUtilities getTimestamp];
        [self startChecker];

        // Trigger notification for view changes
        #if SNOWPLOW_TARGET_IOS || SNOWPLOW_TARGET_TV
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

// MARK: - Public

- (void) startChecker {
    _isSessionCheckerEnabled = YES;
}

- (void) stopChecker {
    _isSessionCheckerEnabled = NO;
}

- (void)startNewSession {
    // TODO: when the sesssion has been renewed programmatically, it has to be reported in the session context to the collector.
    _isNewSession = YES;
}

- (void) setForegroundTimeout:(NSInteger)foregroundTimeout {
    _foregroundTimeout = foregroundTimeout;
}

- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout {
    _backgroundTimeout = backgroundTimeout;
}

- (NSDictionary *) getSessionDictWithEventId:(NSString *)eventId {
    @synchronized (self) {
        if (_isSessionCheckerEnabled) {
            if ([self shouldUpdateSession]) {
                [self updateSessionWithEventId:eventId];
                if (self.onSessionStateUpdate) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        self.onSessionStateUpdate(self.state);
                    });
                }
            }
            self.lastSessionCheck = [SPUtilities getTimestamp];
        }
        return _state.sessionContext;
    }
}

- (NSInteger) getForegroundTimeout {
    return _foregroundTimeout;
}

- (NSInteger) getBackgroundTimeout {
    return _backgroundTimeout;
}

- (BOOL) getInBackground {
    return _inBackground;
}

- (NSString *)getUserId {
    return _userId;
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

// MARK: - Private

- (NSString *)retrieveUserIdWithState:(SPSessionState *)state {
    NSString *userId = state.userId ?: [SPUtilities getUUIDString];
    // Session_UserID is available only if the session context is enabled.
    // In a future version we would like to make it available even if the session context is disabled.
    // For this reason, we store the Session_UserID in a separate storage (decoupled by session values)
    // calling it Installation_UserID in order to remark that it isn't related to the session context.
    // Although, for legacy, we need to copy its value in the Session_UserID of the session context
    // as the session context schema (and related data modelling) requires it.
    // For further details: https://discourse.snowplowanalytics.com/t/rfc-mobile-trackers-v2-0
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *storedUserId = [userDefaults stringForKey:kSPInstallationUserId];
    if (storedUserId) {
        userId = storedUserId;
    } else if (_userId) {
        [userDefaults setObject:userId forKey:kSPInstallationUserId];
    }
    return userId;
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
    NSInteger sessionIndex = (_state.sessionIndex ?: 0) + 1;
    _state = [[SPSessionState alloc] initWithFirstEventId:eventId currentSessionId:[SPUtilities getUUIDString] previousSessionId:_state.sessionId sessionIndex:sessionIndex userId:_userId storage:@"LOCAL_STORAGE"];
    NSDictionary<NSString *,NSObject *> *sessionToPersist = _state.sessionContext;
    // Remove previousSessionId if nil because dictionaries with nil values aren't plist serializable
    // and can't be stored with SPDataPersistence.
    if (!_state.previousSessionId) {
        NSMutableDictionary<NSString *,NSObject *> *sessionCopy = [sessionToPersist mutableCopy];
        [sessionCopy removeObjectForKey:kSPSessionPreviousId];
        sessionToPersist = sessionCopy;
    }
    self.dataPersistence.session = sessionToPersist;
}

- (void) updateInBackground {
    if (!_inBackground && [self.tracker getLifecycleEvents]) {
        _backgroundIndex += 1;
        _inBackground = YES;
        [self sendBackgroundEvent];
    }
}

- (void) updateInForeground {
    if (_inBackground && [self.tracker getLifecycleEvents]) {
        _foregroundIndex += 1;
        _inBackground = NO;
        [self sendForegroundEvent];
    }
}

- (void) sendBackgroundEvent {
    if (self.tracker) {
        SPBackground *backgroundEvent = [[SPBackground alloc] initWithIndex:@(_backgroundIndex)];
        [self.tracker track:backgroundEvent];
    }
}

- (void) sendForegroundEvent {
    if (self.tracker) {
        SPForeground *foregroundEvent = [[SPForeground alloc] initWithIndex:@(_foregroundIndex)];
        [self.tracker track:foregroundEvent];
    }
}

- (void) dealloc {
    #if SNOWPLOW_TARGET_IOS
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    #endif
}

@end
