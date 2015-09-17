//
//  SPTracker.m
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPUtilities.h"
#import "SPSession.h"
#import "SPEvent.h"

@interface SPTracker ()

@property (nonatomic, retain) SPEmitter * emitter;
@property (nonatomic, retain) SPSubject * subject;
@property (nonatomic, retain) NSString *  appId;
@property (nonatomic, retain) NSString *  trackerNamespace;
@property (nonatomic)         BOOL        base64Encoded;

@end

@implementation SPTracker {
    NSMutableDictionary *  _trackerData;
    NSString *             _platformContextSchema;
    BOOL                   _dataCollection;
    SPSession *            _session;
    BOOL                   _sessionContext;
    NSInteger              _foregroundTimeout;
    NSInteger              _backgroundTimeout;
    NSInteger              _checkInterval;
    BOOL                   _builderFinished;
}

// SnowplowTracker Builder

+ (instancetype) build:(void(^)(id<SPTrackerBuilder>builder))buildBlock {
    SPTracker* tracker = [SPTracker new];
    if (buildBlock) {
        buildBlock(tracker);
    }
    [tracker setup];
    return tracker;
}

- (id) init {
    self = [super init];
    if (self) {
        _trackerNamespace = nil;
        _appId = nil;
        _base64Encoded = YES;
        _dataCollection = YES;
        _sessionContext = NO;
        _foregroundTimeout = 600000;
        _backgroundTimeout = 300000;
        _checkInterval = 15;
        _builderFinished = NO;
        
#if TARGET_OS_IPHONE
        _platformContextSchema = kSPMobileContextSchema;
#else
        _platformContextSchema = kSPDesktopContextSchema;
#endif
    }
    return self;
}

- (void) setup {
    [SPUtilities checkArgument:(_emitter != nil) withMessage:@"Emitter cannot be nil."];
    
    [self setTrackerData];
    if (_sessionContext) {
        _session = [[SPSession alloc] initWithForegroundTimeout:_foregroundTimeout andBackgroundTimeout:_backgroundTimeout andCheckInterval:_checkInterval];
    }
    _builderFinished = YES;
}

- (void) setTrackerData {
    _trackerData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    kSPVersion, kSPTrackerVersion,
                    _trackerNamespace != nil ? _trackerNamespace : [NSNull null], kSPNamespace,
                    _appId != nil ? _appId : [NSNull null], kSPAppId, nil];
}

// Required

- (void) setEmitter:(SPEmitter *)emitter {
    if (emitter != nil) {
        _emitter = emitter;
    }
}

- (void) setSubject:(SPSubject *)subject {
    _subject = subject;
}

- (void) setBase64Encoded:(BOOL)encoded {
    _base64Encoded = encoded;
}

- (void) setAppId:(NSString *)appId {
    _appId = appId;
    if (_builderFinished && _trackerData != nil) {
        [self setTrackerData];
    }
}

- (void) setTrackerNamespace:(NSString *)trackerNamespace {
    _trackerNamespace = trackerNamespace;
    if (_builderFinished && _trackerData != nil) {
        [self setTrackerData];
    }
}

- (void) setSessionContext:(BOOL)sessionContext {
    _sessionContext = sessionContext;
    if (_session != nil && !sessionContext) {
        [_session stopChecker];
        _session = nil;
    } else if (_builderFinished && _session == nil && sessionContext) {
        _session = [[SPSession alloc] initWithForegroundTimeout:_foregroundTimeout andBackgroundTimeout:_backgroundTimeout andCheckInterval:_checkInterval];
    }
}

- (void) setForegroundTimeout:(NSInteger)foregroundTimeout {
    _foregroundTimeout = foregroundTimeout;
    if (_builderFinished && _session != nil) {
        [_session setForegroundTimeout:foregroundTimeout];
    }
}

- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout {
    _backgroundTimeout = backgroundTimeout;
    if (_builderFinished && _session != nil) {
        [_session setBackgroundTimeout:backgroundTimeout];
    }
}

- (void) setCheckInterval:(NSInteger)checkInterval {
    _checkInterval = checkInterval;
    if (_builderFinished && _session != nil) {
        [_session setCheckInterval:checkInterval];
    }
}

// Extra Functions

- (void) pauseEventTracking {
    _dataCollection = NO;
    [_emitter stopTimerFlush];
    [_session stopChecker];
}

- (void) resumeEventTracking {
    _dataCollection = YES;
    [_emitter startTimerFlush];
    [_session startChecker];
}

// Getters

- (NSInteger) getSessionIndex {
    return [_session getSessionIndex];
}

- (BOOL) getInBackground {
    return [_session getInBackground];
}

- (BOOL) getIsTracking {
    return _dataCollection;
}

// Event Tracking Functions

- (void) trackPageViewEvent:(SPPageView *)event {
    if (!_dataCollection) {
        return;
    }
    [self addTrackerPayload:[event getPayload] context:[event getContexts]];
}

- (void) trackStructuredEvent:(SPStructured *)event {
    if (!_dataCollection) {
        return;
    }
    [self addTrackerPayload:[event getPayload] context:[event getContexts]];
}

- (void) trackUnstructuredEvent:(SPUnstructured *)event {
    if (!_dataCollection) {
        return;
    }
    [self addTrackerPayload:[event getPayloadWithEncoding:_base64Encoded] context:[event getContexts]];
}

- (void) trackScreenViewEvent:(SPScreenView *)event {
    SPUnstructured * unstruct = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:[event getPayload]];
        [builder setTimestamp:[event getTimestamp]];
        [builder setContexts:[event getContexts]];
        [builder setEventId:[event getEventId]];
    }];
    [self trackUnstructuredEvent:unstruct];
}

- (void) trackTimingEvent:(SPTiming *)event {
    SPUnstructured * unstruct = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData:[event getPayload]];
        [builder setTimestamp:[event getTimestamp]];
        [builder setContexts:[event getContexts]];
        [builder setEventId:[event getEventId]];
    }];
    [self trackUnstructuredEvent:unstruct];
}

- (void) trackEcommerceEvent:(SPEcommerce *)event {
    if (!_dataCollection) {
        return;
    }
    [self addTrackerPayload:[event getPayload] context:[event getContexts]];
    
    NSInteger tstamp = [event getTimestamp];
    for (SPEcommerceItem * item in [event getItems]) {
        [item setTimestamp:tstamp];
        [self trackEcommerceItemEvent:item];
    }
}

- (void) trackEcommerceItemEvent:(SPEcommerceItem *)event {
    [self addTrackerPayload:[event getPayload] context:[event getContexts]];
}

// Event Decoration

- (void) addTrackerPayload:(SPPayload *)pb context:(NSMutableArray *)contextArray {
    [pb addDictionaryToPayload:_trackerData];
    
    // Add Subject information
    if (_subject != nil) {
        [pb addDictionaryToPayload:[[_subject getStandardDict] getPayloadAsDictionary]];
    } else {
        [pb addValueToPayload:[SPUtilities getPlatform] forKey:kSPPlatform];
    }
    
    // Add the Contexts together
    if (_subject != nil) {
        NSDictionary * platformDict = [[_subject getPlatformDict] getPayloadAsDictionary];
        if (platformDict != nil) {
            [contextArray addObject:[self getContextEnvelopeWithSchema:_platformContextSchema
                                                               andData:platformDict]];
        }
    }
    
    if (_session != nil) {
        NSDictionary * sessionDict = [[_session getSessionDict] getPayloadAsDictionary];
        if (sessionDict != nil) {
            [contextArray addObject:[self getContextEnvelopeWithSchema:kSPSessionContextSchema
                                                               andData:sessionDict]];
        }
    }
    
    if (contextArray.count > 0) {
        NSDictionary * contextEnvelope = [self getContextEnvelopeWithSchema:kSPContextSchema
                                                                    andData:contextArray];
        [pb addDictionaryToPayload:contextEnvelope
                     base64Encoded:_base64Encoded
                   typeWhenEncoded:kSPContextEncoded
                typeWhenNotEncoded:kSPContext];
    }
    
    // Add the event!
    [_emitter addPayloadToBuffer:pb];
}

- (NSDictionary *) getContextEnvelopeWithSchema:(NSString *)schema andData:(NSObject *)data {
    return [NSDictionary dictionaryWithObjectsAndKeys:schema, kSPSchema, data, kSPData, nil];
}

@end
