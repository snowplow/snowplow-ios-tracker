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

@interface SPServiceProvider ()

@property (nonatomic, nonnull, readwrite) NSString *namespace;
@property (nonatomic, nonnull) SPNetworkConfiguration *networkConfiguration;
@property (nonatomic, nonnull) SPTrackerConfiguration *trackerConfiguration;
@property (nonatomic) SPEmitterConfiguration *emitterConfiguration;
@property (nonatomic) SPSubjectConfiguration *subjectConfiguration;
@property (nonatomic) SPSessionConfiguration *sessionConfiguration;
@property (nonatomic) SPGDPRConfiguration *gdprConfiguration;
@property (nonatomic) SPGlobalContextsConfiguration *globalContextConfiguration;

@end

@implementation SPServiceProvider

// MARK: - Init

- (instancetype)initWithNamespace:(NSString *)namespace network:(SPNetworkConfiguration *)networkConfiguration configurations:(NSArray<SPConfiguration *> *)configurations {
    if (self = [super init]) {
        self.namespace = namespace;
        self.networkConfiguration = networkConfiguration;
        [self processConfigurations:configurations];
        if (!self.trackerConfiguration) {
            self.trackerConfiguration = [SPTrackerConfiguration new];
        }
    }
    return self;
}

- (void)resetWithConfigurations:(NSArray<SPConfiguration *> *)configurations {
    [self stopServices];
    [self processConfigurations:configurations];
    [self resetServices];
    [_trackerController resetWithTracker:self.tracker];
}

- (void)shutdown {
    [_tracker pauseEventTracking];
    [self stopServices];
    [self resetServices];
    _trackerController = nil;
}

// MARK: - Private methods

- (void)processConfigurations:(NSArray<SPConfiguration *> *)configurations {
    for (SPConfiguration *configuration in configurations) {
        if ([configuration isKindOfClass:SPNetworkConfiguration.class]) {
            self.networkConfiguration = (SPNetworkConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPTrackerConfiguration.class]) {
            self.trackerConfiguration = (SPTrackerConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPSubjectConfiguration.class]) {
            self.subjectConfiguration = (SPSubjectConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPSessionConfiguration.class]) {
            self.sessionConfiguration = (SPSessionConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPEmitterConfiguration.class]) {
            self.emitterConfiguration = (SPEmitterConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPGDPRConfiguration.class]) {
            self.gdprConfiguration = (SPGDPRConfiguration *)configuration;
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

// MARK: - Factories

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (SPSubject *)makeSubject {
    return [[SPSubject alloc] initWithPlatformContext:self.trackerConfiguration.platformContext
                                   geoLocationContext:self.trackerConfiguration.geoLocationContext
                                 subjectConfiguration:self.subjectConfiguration];
}

- (SPEmitter *)makeEmitter {
    SPNetworkConfiguration *networkConfig = self.networkConfiguration;
    SPEmitterConfiguration *emitterConfig = self.emitterConfiguration;
    return [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        if (networkConfig.networkConnection) {
            [builder setNetworkConnection:networkConfig.networkConnection];
        } else {
            [builder setHttpMethod:networkConfig.method];
            [builder setProtocol:networkConfig.protocol];
            [builder setUrlEndpoint:networkConfig.endpoint];
        }
        [builder setCustomPostPath:networkConfig.customPostPath];
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
    SPTrackerConfiguration *trackerConfig = self.trackerConfiguration;
    SPSessionConfiguration *sessionConfig = self.sessionConfiguration;
    SPGlobalContextsConfiguration *gcConfig = self.globalContextConfiguration;
    SPGDPRConfiguration *gdprConfig = self.gdprConfiguration;
    return [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setTrackerNamespace:self.namespace];
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:trackerConfig.appId];
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
        if (gdprConfig) {
            [builder setGdprContextWithBasis:gdprConfig.basisForProcessing documentId:gdprConfig.documentId documentVersion:gdprConfig.documentVersion documentDescription:gdprConfig.documentDescription];
        }
    }];
}

- (SPTrackerControllerImpl *)makeTrackerController {
    SPTrackerControllerImpl *trackerController = [SPTrackerControllerImpl new];
    [trackerController resetWithTracker:self.tracker];
    return trackerController;
}

#pragma clang diagnostic pop

@end
