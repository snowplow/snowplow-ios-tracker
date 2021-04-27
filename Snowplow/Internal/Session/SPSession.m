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

#import "SPTrackerConstants.h"
#import "SPSession.h"
#import "SPUtilities.h"
#import "SPWeakTimerTarget.h"
#import "SPTracker.h"
#import "SPLogger.h"

#import "SPBackground.h"
#import "SPForeground.h"

#if SNOWPLOW_TARGET_IOS
#import <UIKit/UIKit.h>
#endif

@interface SPSession ()

@property (atomic) NSNumber *lastSessionCheck;
@property (weak) SPTracker *tracker;
@property (nonatomic) NSString *sessionFilename;
@property (nonatomic) NSURL *sessionFileUrl;

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

NSString * const kLegacyFilename = @"session.dict";
NSString * const kFilenamePrefix = @"session";
NSString * const kFilenameExt = @"dict";

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
        self.sessionFilename = kLegacyFilename;
        self.tracker = tracker;
        if (tracker.trackerNamespace) {
            NSString *namespace = tracker.trackerNamespace;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+" options:0 error:nil];
            NSString *suffix = [regex stringByReplacingMatchesInString:namespace options:0 range:NSMakeRange(0, namespace.length) withTemplate:@"-"];
            self.sessionFilename = [NSString stringWithFormat:@"%@_%@.%@", kFilenamePrefix, suffix, kFilenameExt];
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *url = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
        url = [url URLByAppendingPathComponent:@"snowplow"];
        NSError *error = nil;
        BOOL result = [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result) {
            SPLogError(@"Unable to create file for sessions: %@", error.localizedDescription);
            return nil;
        }
        url = [url URLByAppendingPathComponent:self.sessionFilename];
        self.sessionFileUrl = url;
        
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

- (NSString *)getPreviousSessionId {
    return _previousSessionId;
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

- (BOOL) writeSessionToFile {
    NSError *error = nil;
    NSMutableDictionary *sessionDict = [_sessionDict mutableCopy];
    [sessionDict removeObjectForKey:kSPSessionPreviousId];
    [sessionDict removeObjectForKey:kSPSessionStorage];
    
    BOOL result = NO;
    if (@available(iOS 11.0, macOS 10.13, watchOS 4.0, *)) {
        result = [sessionDict writeToURL:self.sessionFileUrl error:&error];
    } else {
        result = [sessionDict writeToURL:self.sessionFileUrl atomically:YES];
    }
    if (!result) {
        SPLogError(@"Unable to write file for sessions: %@", error.localizedDescription ?: @"-");
        return NO;
    }
    return YES;
}

- (NSDictionary *) getSessionFromFile {
    NSDictionary *sessionDict = nil;
    sessionDict = [NSDictionary dictionaryWithContentsOfURL:self.sessionFileUrl];
    if (sessionDict) {
        return sessionDict;
    }
    // Load legacy stored session (tracker v.1.x)
    @synchronized (SPSession.class) {
        sessionDict = [NSDictionary dictionaryWithContentsOfURL:self.sessionFileUrl];
        if (!sessionDict) {
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
            path = [path stringByAppendingPathComponent:kLegacyFilename];
            sessionDict = [NSDictionary dictionaryWithContentsOfFile:path];
        }
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
