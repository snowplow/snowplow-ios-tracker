//
//  SPTracker.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPUtilities.h"
#import "SPSession.h"
#import "SPScreenState.h"
#import "SPInstallTracker.h"
#import "SPGlobalContext.h"
#import "SPGdprContext.h"

#import "SNOWError.h"
#import "SPStructured.h"
#import "SPUnstructured.h"
#import "SPScreenView.h"
#import "SPPageView.h"
#import "SPTiming.h"
#import "SPEcommerce.h"
#import "SPEcommerceItem.h"
#import "SPConsentWithdrawn.h"
#import "SPConsentGranted.h"
#import "SPForeground.h"
#import "SPBackground.h"
#import "SPPushNotification.h"
#import "SPTrackerEvent.h"
#import "SPTrackerError.h"
#import "SPDiagnosticLogger.h"
#import "SPLogger.h"

/** A class extension that makes the screen view states mutable internally. */
@interface SPTracker () <SPDiagnosticLogger>

@property (readwrite, nonatomic, strong) SPScreenState * currentScreenState;
@property (readwrite, nonatomic, strong) SPScreenState * previousScreenState;

@property (nonatomic) NSMutableDictionary<NSString *, SPGlobalContext *> *globalContextGenerators;

@property (nonatomic) SPGdprContext *gdpr;

/*!
 @brief This method is called to send an auto-tracked screen view event.

 @param notification The notification raised by a UIViewController
 */
- (void) receiveScreenViewNotification:(NSNotification *)notification;

@end

void uncaughtExceptionHandler(NSException *exception) {
    NSArray* symbols = [exception callStackSymbols];
    NSString * stackTrace = [NSString stringWithFormat:@"Stacktrace:\n%@", symbols];
    NSString * message = [exception reason];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Load values
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * url = [userDefaults objectForKey:kSPErrorTrackerUrl];
        NSString * protocolString = [userDefaults objectForKey:kSPErrorTrackerProtocol];
        NSString * methodString = [userDefaults objectForKey:kSPErrorTrackerMethod];
        SPProtocol protocol = SPHttps;
        if (protocolString && [protocolString isEqual:@"http://"]) {
            protocol = SPHttp;
        }
        SPRequestOptions method = SPRequestPost;
        if (methodString && [methodString isEqual:@"/i"]) {
            method = SPRequestGet;
        }
        // Send notification to tracker
        SPEmitter * emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
            [builder setUrlEndpoint:url];
            [builder setProtocol:protocol];
            [builder setHttpMethod:method];
        }];
        SPTracker * tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
            [builder setEmitter:emitter];
        }];
        
        if (message == nil || [message length] == 0) {
            return;
        }
        SNOWError * error = [SNOWError build:^(id<SPErrorBuilder> builder) {
            [builder setMessage:message];
            if (stackTrace != nil && [stackTrace length] > 0) {
                [builder setStackTrace:stackTrace];
            }
        }];
        [tracker track:error];
        [NSThread sleepForTimeInterval:2.0f];
    });
}

#pragma mark - SPTracker implementation

@implementation SPTracker {
    NSMutableDictionary *  _trackerData;
    NSString *             _platformContextSchema;
    BOOL                   _dataCollection;
    SPSession *            _session;
    BOOL                   _sessionContext;
    BOOL                   _screenContext;
    BOOL                   _applicationContext;
    BOOL                   _autotrackScreenViews;
    BOOL                   _lifecycleEvents;
    NSInteger              _foregroundTimeout;
    NSInteger              _backgroundTimeout;
    NSInteger              _checkInterval;
    BOOL                   _builderFinished;
    BOOL                   _exceptionEvents;
    BOOL                   _installEvent;
}

+ (instancetype) build:(void(^)(id<SPTrackerBuilder>builder))buildBlock {
    SPTracker* tracker = [[SPTracker alloc] initWithDefaultValues];
    if (buildBlock) {
        buildBlock(tracker);
    }
    [tracker setup];
    [tracker checkInstall];
    return tracker;
}

- (instancetype) initWithDefaultValues {
    self = [super init];
    if (self) {
        _trackerNamespace = nil;
        _appId = nil;
        _devicePlatform = [SPUtilities getPlatform];
        _base64Encoded = YES;
        _dataCollection = YES;
        _sessionContext = NO;
        _applicationContext = NO;
        _screenContext = NO;
        _lifecycleEvents = NO;
        _autotrackScreenViews = NO;
        _foregroundTimeout = 600;
        _backgroundTimeout = 300;
        _checkInterval = 15;
        _builderFinished = NO;
        self.previousScreenState = nil;
        self.currentScreenState = nil;
        _exceptionEvents = NO;
        _installEvent = NO;
#if SNOWPLOW_TARGET_IOS
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
        _session = [[SPSession alloc] initWithForegroundTimeout:_foregroundTimeout
                                           andBackgroundTimeout:_backgroundTimeout
                                               andCheckInterval:_checkInterval
                                                     andTracker:self];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveScreenViewNotification:)
                                                 name:@"SPScreenViewDidAppear"
                                               object:nil];
    
    if (_exceptionEvents) {
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    }
    
    _builderFinished = YES;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // to ignore warnings for deprecated methods that we are forced to use until the next major version release

- (void) checkInstall {
    SPInstallTracker * installTracker = [[SPInstallTracker alloc] init];
    NSNumber * previousTimestamp = [installTracker getPreviousInstallTimestamp];
    if (_installEvent) {
        if (installTracker.isNewInstall) {
            SPSelfDescribingJson * installEvent = [[SPSelfDescribingJson alloc] initWithSchema:kSPApplicationInstallSchema andData:@{}];
            SPUnstructured * event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
                [builder setEventData:installEvent];
            }];
            [self track:event];
            if (previousTimestamp) {
                [installTracker clearPreviousInstallTimestamp];
            }
        } else if (previousTimestamp) {
            SPSelfDescribingJson * installEvent = [[SPSelfDescribingJson alloc] initWithSchema:kSPApplicationInstallSchema andData:@{}];
            SPUnstructured * event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
                [builder setEventData:installEvent];
                [builder setTimestamp:previousTimestamp];
            }];
            [self track:event];
            [installTracker clearPreviousInstallTimestamp];
        }
    }
}

#pragma GCC diagnostic pop

- (void) setTrackerData {
    _trackerData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    kSPVersion, kSPTrackerVersion,
                    _trackerNamespace != nil ? _trackerNamespace : [NSNull null], kSPNamespace,
                    _appId != nil ? _appId : [NSNull null], kSPAppId, nil];
}

#pragma mark - Setter

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

- (void) setDevicePlatform:(SPDevicePlatform)devicePlatform {
    _devicePlatform = devicePlatform;
}

- (void)setLogLevel:(SPLogLevel)logLevel {
    [SPLogger setLogLevel:logLevel];
}

- (void)setLoggerDelegate:(id<SPLoggerDelegate>)delegate {
    [SPLogger setLoggerDelegate:delegate];
}

- (void) setSessionContext:(BOOL)sessionContext {
    _sessionContext = sessionContext;
    if (_session != nil && !sessionContext) {
        [_session stopChecker];
        _session = nil;
    } else if (_builderFinished && _session == nil && sessionContext) {
        _session = [[SPSession alloc] initWithForegroundTimeout:_foregroundTimeout andBackgroundTimeout:_backgroundTimeout andCheckInterval:_checkInterval andTracker:self];
    }
}

- (void) setScreenContext:(BOOL)screenContext {
    _screenContext = screenContext;
}

- (void) setApplicationContext:(BOOL)applicationContext {
    _applicationContext = applicationContext;
}

- (void) setAutotrackScreenViews:(BOOL)autotrackScreenViews {
    _autotrackScreenViews = autotrackScreenViews;
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

- (void) setLifecycleEvents:(BOOL)lifecycleEvents {
    _lifecycleEvents = lifecycleEvents;
}

- (void) setExceptionEvents:(BOOL)exceptionEvents {
    _exceptionEvents = exceptionEvents;
}

- (void) setInstallEvent:(BOOL)installEvent {
    _installEvent = installEvent;
}

- (void)setTrackerDiagnostic:(BOOL)trackerDiagnostic {
    if (_builderFinished) {
        id<SPDiagnosticLogger> diagnosticLogger = trackerDiagnostic ? self : nil;
        [SPLogger setDiagnosticLogger:diagnosticLogger];
    }
}

#pragma mark - Diagnostic

- (void)logWithTag:(NSString *)tag message:(NSString *)message error:(NSError *)error exception:(NSException *)exception {
    SPTrackerError *event = [[SPTrackerError alloc] initWithSource:tag message:message error:error exception:exception];
    [self track:event];
}

#pragma mark - Global Contexts methods

- (void)setGlobalContextGenerators:(NSDictionary<NSString *, SPGlobalContext *> *)globalContexts {
    _globalContextGenerators = globalContexts.mutableCopy ?: [NSMutableDictionary dictionary];
}

- (BOOL)addGlobalContext:(SPGlobalContext *)generator tag:(NSString *)tag {
    if ([self.globalContextGenerators objectForKey:tag]) {
        return NO;
    }
    [self.globalContextGenerators setObject:generator forKey:tag];
    return YES;
}

- (SPGlobalContext *)removeGlobalContext:(NSString *)tag {
    SPGlobalContext *toDelete = [self.globalContextGenerators objectForKey:tag];
    if (toDelete) {
        [self.globalContextGenerators removeObjectForKey:tag];
    }
    return toDelete;
}

#pragma mark - GDPR methods

- (void)setGdprContextWithBasis:(SPGdprProcessingBasis)basisForProcessing
                     documentId:(NSString *)documentId
                documentVersion:(NSString *)documentVersion
            documentDescription:(NSString *)documentDescription
{
    self.gdpr = [[SPGdprContext alloc] initWithBasis:basisForProcessing
                                          documentId:documentId
                                     documentVersion:documentVersion
                                 documentDescription:documentDescription];
}

- (void)enableGdprContextWithBasis:(SPGdprProcessingBasis)basisForProcessing
                        documentId:(NSString *)documentId
                   documentVersion:(NSString *)documentVersion
               documentDescription:(NSString *)documentDescription
{
    self.gdpr = [[SPGdprContext alloc] initWithBasis:basisForProcessing
                                          documentId:documentId
                                     documentVersion:documentVersion
                                 documentDescription:documentDescription];
}

- (void)disableGdprContext {
    self.gdpr = nil;
}

#pragma mark - Extra Functions

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

#pragma mark - Getters

- (NSInteger) getSessionIndex {
    return [_session getSessionIndex];
}

- (BOOL) getInBackground {
    return [_session getInBackground];
}

- (BOOL) getIsTracking {
    return _dataCollection;
}

- (NSString*) getSessionUserId {
    return [_session getUserId];
}

- (NSString*) getSessionId {
    return [_session getSessionId];
}

- (BOOL) getLifecycleEvents {
    return _lifecycleEvents;
}

- (NSArray<NSString *> *)globalContextTags {
    return self.globalContextGenerators.allKeys;
}

#pragma mark - Notifications management

- (void) receiveScreenViewNotification:(NSNotification *)notification {
    NSString * name = [[notification userInfo] objectForKey:@"name"];
    NSString * type = stringWithSPScreenType([[[notification userInfo] objectForKey:@"type"] integerValue]);
    NSString * topViewControllerClassName = [[notification userInfo] objectForKey:@"topViewControllerClassName"];
    NSString * viewControllerClassName = [[notification userInfo] objectForKey:@"viewControllerClassName"];

    if (_autotrackScreenViews) {
        SPScreenView *event = [SPScreenView build:^(id<SPScreenViewBuilder> builder) {
            [builder setName:name];
            [builder setType:type];
            [builder setViewControllerClassName:viewControllerClassName];
            [builder setTopViewControllerClassName:topViewControllerClassName];
        }];
        [self track:event];
    }
}

#pragma mark - Event Tracking Functions

- (void) trackPageViewEvent:(SPPageView *)event {
    [self track:event];
}

- (void) trackStructuredEvent:(SPStructured *)event {
    [self track:event];
}

- (void) trackUnstructuredEvent:(SPUnstructured *)event {
    [self track:event];
}

- (void) trackSelfDescribingEvent:(SPSelfDescribingJson *)event {
    if (!event || !_dataCollection) return;
    SPUnstructured * unstruct = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
        [builder setEventData: event];
    }];
    [self track:unstruct];
}

- (void) trackScreenViewEvent:(SPScreenView *)event {
    [self track:event];
}

- (void) trackTimingEvent:(SPTiming *)event {
    [self track:event];
}

- (void) trackEcommerceEvent:(SPEcommerce *)event {
    [self track:event];
}

- (void) trackEcommerceItemEvent:(SPEcommerceItem *)event {
    [self track:event];
}

- (void) trackConsentWithdrawnEvent:(SPConsentWithdrawn *)event {
    [self track:event];
}

- (void) trackConsentGrantedEvent:(SPConsentGranted *)event {
    [self track:event];
}

- (void) trackPushNotificationEvent:(SPPushNotification *)event {
    [self track:event];
}

- (void) trackForegroundEvent:(SPForeground *)event {
    [self track:event];
}

- (void) trackBackgroundEvent:(SPBackground *)event {
    [self track:event];
}

- (void) trackErrorEvent:(SNOWError *)event {
    [self track:event];
}

- (void)track:(SPEvent *)event {
    if (!event || !_dataCollection) return;
    
    if ([event isKindOfClass:SPScreenView.class]) {
        @synchronized (_currentScreenState) {
            SPScreenView *screenView = (SPScreenView *)event;
            _previousScreenState = _currentScreenState;
            _currentScreenState = [screenView getScreenState];
            [screenView updateWithPreviousState: _previousScreenState];
        }
    }

    [event beginProcessingWithTracker:self];
    [self processEvent:event];
    [event endProcessingWithTracker:self];
}

#pragma mark - Event Decoration

- (void)processEvent:(SPEvent *)event {
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    SPPayload *payload = [self payloadWithEvent:trackerEvent];
    [_emitter addPayloadToBuffer:payload];
}

- (SPPayload *)getFinalPayloadWithPayload:(SPPayload *)pb andContext:(NSMutableArray *)contextArray andEventId:(NSString *)eventId {
    [pb addDictionaryToPayload:_trackerData];

    // Add Subject information
    if (_subject != nil) {
        [pb addDictionaryToPayload:[[_subject getStandardDict] getAsDictionary]];
    }
    [pb addValueToPayload:SPDevicePlatformToString(_devicePlatform) forKey:kSPPlatform];

    // Add the contexts
    NSMutableArray<SPSelfDescribingJson *> *contexts = contextArray;
    [self addBasicContextsToContexts:contexts eventId:eventId isService:NO]; // isService = NO is just the default - this method will be removed in the version 2.0

    [self wrapContexts:contexts toPayload:pb];
    return pb;
}

- (SPPayload *)payloadWithEvent:(SPTrackerEvent *)event {
    SPPayload *payload = [SPPayload new];
    payload.allowDiagnostic = !event.isService;

    [self addBasicPropertiesToPayload:payload event:event];
    if (event.isPrimitive) {
        [self addPrimitivePropertiesToPayload:payload event:event];
    } else {
        [self addSelfDescribingPropertiesToPayload:payload event:event];
    }
    NSMutableArray<SPSelfDescribingJson *> *contexts = event.contexts;
    [self addBasicContextsToContexts:contexts event:event];
    [self addGlobalContextsToContexts:contexts event:event];
    [self wrapContexts:contexts toPayload:payload];

    return payload;
}

- (void)addBasicPropertiesToPayload:(SPPayload *)payload event:(SPTrackerEvent *)event {
    [payload addValueToPayload:event.eventId.UUIDString forKey:kSPEid];
    [payload addValueToPayload:[NSString stringWithFormat:@"%lld", event.timestamp] forKey:kSPTimestamp];
    if (event.trueTimestamp) {
        [payload addValueToPayload:[NSString stringWithFormat:@"%lld", event.trueTimestamp.longLongValue] forKey:kSPTrueTimestamp];
    }
    [payload addDictionaryToPayload:_trackerData];
    if (_subject != nil) {
        [payload addDictionaryToPayload:[[_subject getStandardDict] getAsDictionary]];
    }
    [payload addValueToPayload:SPDevicePlatformToString(_devicePlatform) forKey:kSPPlatform];
}

- (void)addPrimitivePropertiesToPayload:(SPPayload *)payload event:(SPTrackerEvent *)event {
    [payload addValueToPayload:event.eventName forKey:kSPEvent];
    [payload addDictionaryToPayload:event.payload];
}

- (void)addSelfDescribingPropertiesToPayload:(SPPayload *)payload event:(SPTrackerEvent *)event {
    [payload addValueToPayload:kSPEventUnstructured forKey:kSPEvent];
    SPSelfDescribingJson *data = [[SPSelfDescribingJson alloc] initWithSchema:event.schema andData:event.payload];
    NSDictionary *unstructuredEventPayload = @{
        kSPSchema: kSPUnstructSchema,
        kSPData: [data getAsDictionary],
    };
    [payload addDictionaryToPayload:unstructuredEventPayload
                      base64Encoded:_base64Encoded
                    typeWhenEncoded:kSPUnstructuredEncoded
                 typeWhenNotEncoded:kSPUnstructured];
}

- (void)addBasicContextsToContexts:(NSMutableArray<SPSelfDescribingJson *> *)contexts event:(SPTrackerEvent *)event {
    [self addBasicContextsToContexts:contexts eventId:event.eventId.UUIDString isService:event.isService];
}

- (void)addBasicContextsToContexts:(NSMutableArray<SPSelfDescribingJson *> *)contexts eventId:(NSString *)eventId isService:(BOOL)isService {
    if (_subject) {
        NSDictionary * platformDict = [[_subject getPlatformDict] getAsDictionary];
        if (platformDict != nil) {
            [contexts addObject:[[SPSelfDescribingJson alloc] initWithSchema:_platformContextSchema andData:platformDict]];
        }
        NSDictionary * geoLocationDict = [_subject getGeoLocationDict];
        if (geoLocationDict != nil) {
            [contexts addObject:[[SPSelfDescribingJson alloc] initWithSchema:kSPGeoContextSchema andData:geoLocationDict]];
        }
    }

    if (_applicationContext) {
        SPSelfDescribingJson * contextJson = [SPUtilities getApplicationContext];
        if (contextJson != nil) {
            [contexts addObject:contextJson];
        }
    }
    
    if (isService) {
        return;
    }

    // Add session
    if (_session) {
        NSDictionary *sessionDict = [_session getSessionDictWithEventId:eventId];
        if (sessionDict) {
            [contexts addObject:[[SPSelfDescribingJson alloc] initWithSchema:kSPSessionContextSchema andData:sessionDict]];
        } else {
            SPLogTrack(nil, @"Unable to get session context for eventId: %@", eventId);
        }
    }
    
    // Add screen context
    if (_screenContext && _currentScreenState) {
        SPSelfDescribingJson * contextJson = [SPUtilities getScreenContextWithScreenState:_currentScreenState];
        if (contextJson != nil) {
            [contexts addObject:contextJson];
        }
    }
    
    // Add GDPR context
    if (self.gdpr) {
        SPSelfDescribingJson *gdprContext = self.gdpr.context;
        if (gdprContext) {
            [contexts addObject:gdprContext];
        }
    }
}

- (void)addGlobalContextsToContexts:(NSMutableArray<SPSelfDescribingJson *> *)contexts event:(id<SPInspectableEvent>)event {
    [self.globalContextGenerators enumerateKeysAndObjectsUsingBlock:^(NSString *key, SPGlobalContext *generator, BOOL *stop) {
        [contexts addObjectsFromArray:[generator contextsFromEvent:event]];
    }];
}

- (void)wrapContexts:(NSArray<SPSelfDescribingJson *> *)contexts toPayload:(SPPayload *)payload {
    if (contexts.count == 0) {
        return;
    }
    NSMutableArray<NSDictionary *> *data = [NSMutableArray new];
    for (SPSelfDescribingJson *context in contexts) {
        [data addObject:[context getAsDictionary]];
    }

    SPSelfDescribingJson *finalContext = [[SPSelfDescribingJson alloc] initWithSchema:kSPContextSchema andData:data];
    if (finalContext == nil) {
        return;
    }
    [payload addDictionaryToPayload:[finalContext getAsDictionary]
                      base64Encoded:_base64Encoded
                    typeWhenEncoded:kSPContextEncoded
                 typeWhenNotEncoded:kSPContext];
}

@end
