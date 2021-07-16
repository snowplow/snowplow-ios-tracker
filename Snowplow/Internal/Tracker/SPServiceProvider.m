//
//  SPServiceProvider.m
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPServiceProvider.h"
#import "SPDefaultNetworkConnection.h"
#import "SPGdprContext.h"

#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPTracker.h"
#import "SPSession.h"

#import "SPTrackerControllerImpl.h"
#import "SPEmitterControllerImpl.h"
#import "SPNetworkControllerImpl.h"
#import "SPSubjectControllerImpl.h"
#import "SPSessionControllerImpl.h"
#import "SPGlobalContextsControllerImpl.h"
#import "SPGDPRControllerImpl.h"

#import "SPNetworkConfigurationUpdate.h"
#import "SPTrackerConfigurationUpdate.h"
#import "SPEmitterConfigurationUpdate.h"
#import "SPSubjectConfigurationUpdate.h"
#import "SPSessionConfigurationUpdate.h"
#import "SPGDPRConfigurationUpdate.h"

@interface SPServiceProvider ()

@property (nonatomic, nonnull, readwrite) NSString *namespace;

// Internal services
@property (nonatomic, nullable) SPTracker *tracker;
@property (nonatomic, nullable) SPEmitter *emitter;
@property (nonatomic, nullable) SPSubject *subject;

// Controllers
@property (nonatomic, nullable) SPTrackerControllerImpl *trackerController;
@property (nonatomic, nullable) SPEmitterControllerImpl *emitterController;
@property (nonatomic, nullable) SPNetworkControllerImpl *networkController;
@property (nonatomic, nullable) SPGDPRControllerImpl *gdprController;
@property (nonatomic, nullable) SPGlobalContextsControllerImpl *globalContextsController;
@property (nonatomic, nullable) SPSubjectControllerImpl *subjectController;
@property (nonatomic, nullable) SPSessionControllerImpl *sessionController;

// Original configurations
@property (nonatomic) SPGlobalContextsConfiguration *globalContextConfiguration;

// Configuration updates
@property (nonatomic) SPNetworkConfigurationUpdate *networkConfigurationUpdate;
@property (nonatomic) SPTrackerConfigurationUpdate *trackerConfigurationUpdate;
@property (nonatomic) SPEmitterConfigurationUpdate *emitterConfigurationUpdate;
@property (nonatomic) SPSubjectConfigurationUpdate *subjectConfigurationUpdate;
@property (nonatomic) SPSessionConfigurationUpdate *sessionConfigurationUpdate;
@property (nonatomic) SPGDPRConfigurationUpdate *gdprConfigurationUpdate;

@end

@implementation SPServiceProvider
@synthesize emitter = _emitter;
@synthesize subject = _subject;
@synthesize tracker = _tracker;
@synthesize trackerController = _trackerController;
@synthesize emitterController = _emitterController;
@synthesize networkController = _networkController;
@synthesize sessionController = _sessionController;
@synthesize subjectController = _subjectController;
@synthesize gdprController = _gdprController;
@synthesize globalContextsController = _globalContextsController;

// MARK: - Init

- (instancetype)initWithNamespace:(NSString *)namespace network:(SPNetworkConfiguration *)networkConfiguration configurations:(NSArray<SPConfiguration *> *)configurations {
    if (self = [super init]) {
        [self initializeConfigurationUpdates];
        self.namespace = namespace;
        self.networkConfigurationUpdate.sourceConfig = networkConfiguration;
        [self processConfigurations:configurations];
        if (!self.trackerConfigurationUpdate.sourceConfig) {
            self.trackerConfigurationUpdate.sourceConfig = [SPTrackerConfiguration new];
        }
        [self tracker]; // Build tracker to initialize NotificationCenter receivers
    }
    return self;
}

- (void)resetWithConfigurations:(NSArray<SPConfiguration *> *)configurations {
    [self stopServices];
    [self resetConfigurationUpdates];
    [self processConfigurations:configurations];
    [self resetServices];
    [self tracker];
}

- (void)shutdown {
    [_tracker pauseEventTracking];
    [self stopServices];
    [self resetServices];
    [self resetControllers];
    [self initializeConfigurationUpdates];
}

// MARK: - Private methods

- (void)processConfigurations:(NSArray<SPConfiguration *> *)configurations {
    for (SPConfiguration *configuration in configurations) {
        if ([configuration isKindOfClass:SPNetworkConfiguration.class]) {
            self.networkConfigurationUpdate.sourceConfig = (SPNetworkConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPTrackerConfiguration.class]) {
            self.trackerConfigurationUpdate.sourceConfig = (SPTrackerConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPSubjectConfiguration.class]) {
            self.subjectConfigurationUpdate.sourceConfig = (SPSubjectConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPSessionConfiguration.class]) {
            self.sessionConfigurationUpdate.sourceConfig = (SPSessionConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPEmitterConfiguration.class]) {
            self.emitterConfigurationUpdate.sourceConfig = (SPEmitterConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPGDPRConfiguration.class]) {
            self.gdprConfigurationUpdate.sourceConfig = (SPGDPRConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPGlobalContextsConfiguration.class]) {
            self.globalContextConfiguration = (SPGlobalContextsConfiguration *)configuration;
            continue;
        }
    }
}

- (void)stopServices {
    [_emitter pause];
}

- (void)resetServices {
    _emitter = nil;
    _subject = nil;
    _tracker = nil;
}

- (void)resetControllers {
    _trackerController = nil;
    _sessionController = nil;
    _emitterController = nil;
    _gdprController = nil;
    _globalContextsController = nil;
    _subjectController = nil;
    _networkController = nil;
}

- (void)resetConfigurationUpdates {
    // Don't reset networkConfiguration as it's needed in case it's not passed in the new configurations.
    // Set a default trackerConfiguration to reset to default if not passed.
    self.trackerConfigurationUpdate.sourceConfig = [SPTrackerConfiguration new];
    self.emitterConfigurationUpdate.sourceConfig = nil;
    self.subjectConfigurationUpdate.sourceConfig = nil;
    self.sessionConfigurationUpdate.sourceConfig = nil;
    self.gdprConfigurationUpdate.sourceConfig = nil;
}

- (void)initializeConfigurationUpdates {
    self.networkConfigurationUpdate = [SPNetworkConfigurationUpdate new];
    self.trackerConfigurationUpdate = [SPTrackerConfigurationUpdate new];
    self.emitterConfigurationUpdate = [SPEmitterConfigurationUpdate new];
    self.subjectConfigurationUpdate = [SPSubjectConfigurationUpdate new];
    self.sessionConfigurationUpdate = [SPSessionConfigurationUpdate new];
    self.gdprConfigurationUpdate = [SPGDPRConfigurationUpdate new];
}

// MARK: - Getters

- (SPSubject *)subject {
    if (_subject) return _subject;
    _subject = [self makeSubject];
    return _subject;
}

- (SPEmitter *)emitter {
    if (_emitter) return _emitter;
    _emitter = [self makeEmitter];
    return _emitter;
}

- (SPTracker *)tracker {
    if (_tracker) return _tracker;
    _tracker = [self makeTracker];
    return _tracker;
}

- (SPTrackerControllerImpl *)trackerController {
    if (_trackerController) return _trackerController;
    _trackerController = [self makeTrackerController];
    return _trackerController;
}

- (SPSessionControllerImpl *)sessionController {
    if (_sessionController) return _sessionController;
    _sessionController = [self makeSessionController];
    return _sessionController;
}

- (SPEmitterControllerImpl *)emitterController {
    if (_emitterController) return _emitterController;
    _emitterController = [self makeEmitterController];
    return _emitterController;
}

- (SPGDPRControllerImpl *)gdprController {
    if (_gdprController) return _gdprController;
    _gdprController = [self makeGDPRController];
    return _gdprController;
}

- (SPGlobalContextsControllerImpl *)globalContextsController {
    if (_globalContextsController) return _globalContextsController;
    _globalContextsController = [self makeGlobalContextsController];
    return _globalContextsController;
}

- (SPSubjectControllerImpl *)subjectController {
    if (_subjectController) return _subjectController;
    _subjectController = [self makeSubjectController];
    return _subjectController;
}

- (SPNetworkControllerImpl *)networkController {
    if (_networkController) return _networkController;
    _networkController = [self makeNetworkController];
    return _networkController;
}

// MARK: - Factories

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (SPSubject *)makeSubject {
    return [[SPSubject alloc] initWithPlatformContext:self.trackerConfigurationUpdate.platformContext
                                   geoLocationContext:self.trackerConfigurationUpdate.geoLocationContext
                                 subjectConfiguration:self.subjectConfigurationUpdate];
}

- (SPEmitter *)makeEmitter {
    SPNetworkConfigurationUpdate *networkConfig = self.networkConfigurationUpdate;
    SPEmitterConfigurationUpdate *emitterConfig = self.emitterConfigurationUpdate;
    return [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        if (networkConfig.networkConnection) {
            [builder setNetworkConnection:networkConfig.networkConnection];
        } else {
            [builder setHttpMethod:networkConfig.method];
            [builder setProtocol:networkConfig.protocol];
            [builder setUrlEndpoint:networkConfig.endpoint];
        }
        [builder setCustomPostPath:networkConfig.customPostPath];
        [builder setRequestHeaders:networkConfig.requestHeaders];
        if (emitterConfig) {
            [builder setEmitRange:emitterConfig.emitRange];
            [builder setBufferOption:emitterConfig.bufferOption];
            [builder setEventStore:emitterConfig.eventStore];
            [builder setByteLimitPost:emitterConfig.byteLimitPost];
            [builder setByteLimitGet:emitterConfig.byteLimitGet];
            [builder setEmitThreadPoolSize:emitterConfig.threadPoolSize];
            [builder setCallback:emitterConfig.requestCallback];
        }
    }];
}

- (SPTracker *)makeTracker {
    SPEmitter *emitter = self.emitter;
    SPSubject *subject = self.subject;
    SPTrackerConfiguration *trackerConfig = self.trackerConfigurationUpdate;
    SPSessionConfiguration *sessionConfig = self.sessionConfigurationUpdate;
    SPGlobalContextsConfiguration *gcConfig = self.globalContextConfiguration;
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setTrackerNamespace:self.namespace];
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:trackerConfig.appId];
        [builder setTrackerVersionSuffix:trackerConfig.trackerVersionSuffix];
        [builder setBase64Encoded:trackerConfig.base64Encoding];
        [builder setLogLevel:trackerConfig.logLevel];
        [builder setLoggerDelegate:trackerConfig.loggerDelegate];
        [builder setDevicePlatform:trackerConfig.devicePlatform];
        [builder setSessionContext:trackerConfig.sessionContext];
        [builder setApplicationContext:trackerConfig.applicationContext];
        [builder setScreenContext:trackerConfig.screenContext];
        [builder setAutotrackScreenViews:trackerConfig.screenViewAutotracking];
        [builder setLifecycleEvents:trackerConfig.lifecycleAutotracking];
        [builder setInstallEvent:trackerConfig.installAutotracking];
        [builder setExceptionEvents:trackerConfig.exceptionAutotracking];
        [builder setTrackerDiagnostic:trackerConfig.diagnosticAutotracking];
        if (sessionConfig) {
            [builder setBackgroundTimeout:sessionConfig.backgroundTimeoutInSeconds];
            [builder setForegroundTimeout:sessionConfig.foregroundTimeoutInSeconds];
        }
        if (gcConfig) {
            [builder setGlobalContextGenerators:gcConfig.contextGenerators];
        }
        SPGDPRConfigurationUpdate *gdprConfig = self.gdprConfigurationUpdate;
        if (gdprConfig.sourceConfig) {
            [builder setGdprContextWithBasis:gdprConfig.basisForProcessing documentId:gdprConfig.documentId documentVersion:gdprConfig.documentVersion documentDescription:gdprConfig.documentDescription];
        }
    }];
    if (self.trackerConfigurationUpdate.isPaused) {
        [tracker pauseEventTracking];
    }
    if (self.sessionConfigurationUpdate.isPaused) {
        [tracker.session stopChecker];
    }
    return tracker;
}

- (SPTrackerControllerImpl *)makeTrackerController {
    SPTrackerControllerImpl *controller = [[SPTrackerControllerImpl alloc] initWithServiceProvider:self];
    return controller;
}

- (SPSessionControllerImpl *)makeSessionController {
    SPSessionControllerImpl *controller = [[SPSessionControllerImpl alloc] initWithServiceProvider:self];
    return controller;
}

- (SPEmitterControllerImpl *)makeEmitterController {
    SPEmitterControllerImpl *controller = [[SPEmitterControllerImpl alloc] initWithServiceProvider:self];
    return controller;
}

- (SPGDPRControllerImpl *)makeGDPRController {
    SPGDPRControllerImpl *controller = [[SPGDPRControllerImpl alloc] initWithServiceProvider:self];
    SPGdprContext *gdpr = self.tracker.gdprContext;
    if (gdpr) {
        [controller resetWithBasis:gdpr.basis documentId:gdpr.documentId documentVersion:gdpr.documentVersion documentDescription:gdpr.documentDescription];
    }
    return controller;
}

- (SPGlobalContextsControllerImpl *)makeGlobalContextsController {
    SPGlobalContextsControllerImpl *controller = [[SPGlobalContextsControllerImpl alloc] initWithServiceProvider:self];
    return controller;
}

- (SPSubjectControllerImpl *)makeSubjectController {
    SPSubjectControllerImpl *controller = [[SPSubjectControllerImpl alloc] initWithServiceProvider:self];
    return controller;
}

- (SPNetworkControllerImpl *)makeNetworkController {
    SPNetworkControllerImpl *controller = [[SPNetworkControllerImpl alloc] initWithServiceProvider:self];
    return controller;
}

#pragma clang diagnostic pop

@end
