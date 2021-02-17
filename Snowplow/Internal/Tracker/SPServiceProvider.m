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
#import "SPTrackerController.h"
#import "SPDefaultNetworkConnection.h"

@interface SPServiceProvider ()

@property (nonatomic) SPNetworkConfiguration *networkConfiguration;
@property (nonatomic) SPEmitterConfiguration *emitterConfiguration;
@property (nonatomic) SPTrackerConfiguration *trackerConfiguration;
@property (nonatomic) SPSubjectConfiguration *subjectConfiguration;
@property (nonatomic) SPSessionConfiguration *sessionConfiguration;
@property (nonatomic) SPGDPRConfiguration *gdprConfiguration;
@property (nonatomic) SPGlobalContextsConfiguration *globalContextConfiguration;

@end

@implementation SPServiceProvider

// MARK: - Init

- (instancetype)initWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration configurations:(NSArray<SPConfiguration *> *)configurations {
    if (self = [super init]) {
        self.networkConfiguration = networkConfiguration;
        self.trackerConfiguration = trackerConfiguration;
        for (SPConfiguration *configuration in configurations) {
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
    return self;
}

// MARK: - Setup

+ (id<SPTrackerControlling>)setupWithEndpoint:(NSString *)endpoint protocol:(SPProtocol)protocol method:(SPRequestOptions)method namespace:(NSString *)namespace appId:(NSString *)appId {
    SPNetworkConfiguration *network = [[SPNetworkConfiguration alloc] initWithEndpoint:endpoint protocol:protocol method:method];
    SPTrackerConfiguration *tracker = [[SPTrackerConfiguration alloc] initWithNamespace:namespace appId:appId];
    return [SPServiceProvider setupWithNetwork:network tracker:tracker];
}

+ (id<SPTrackerControlling>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration configurations:(NSArray<SPConfiguration *> *)configurations {
    SPServiceProvider *serviceProvider = [[SPServiceProvider alloc] initWithNetwork:networkConfiguration tracker:trackerConfiguration configurations:configurations];
    return serviceProvider.trackerController;
}

+ (id<SPTrackerControlling>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration {
    return [SPServiceProvider setupWithNetwork:networkConfiguration tracker:trackerConfiguration configurations:@[]];
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

- (id<SPTrackerControlling>)trackerController {
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
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:trackerConfig.appId];
        [builder setTrackerNamespace:trackerConfig.namespace];
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

- (SPTrackerController *)makeTrackerController {
    return [[SPTrackerController alloc] initWithTracker:self.tracker];
}

#pragma clang diagnostic pop

@end
