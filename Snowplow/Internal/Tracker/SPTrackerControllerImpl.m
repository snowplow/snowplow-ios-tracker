//
//  SPTrackerController.m
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

#import "SPServiceProviderProtocol.h"
#import "SPTrackerControllerImpl.h"
#import "SPEmitterControllerImpl.h"
#import "SPNetworkControllerImpl.h"
#import "SPGDPRControllerImpl.h"
#import "SPGlobalContextsControllerImpl.h"
#import "SPSubjectControllerImpl.h"
#import "SPSessionControllerImpl.h"

#import "SPSubjectConfiguration.h"
#import "SPNetworkConfiguration.h"

#import "SPTrackerConstants.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPDefaultNetworkConnection.h"
#import "SPSubject.h"
#import "SPLogger.h"


@interface SPTrackerControllerImpl ()

@property (nonatomic, weak) SPTracker *tracker;

@end

@implementation SPTrackerControllerImpl

- (SPTracker *)tracker {
    return self.serviceProvider.tracker;
}

// MARK: - Controllers

- (id<SPNetworkController>)network {
    return self.serviceProvider.networkController;
}

- (id<SPEmitterController>)emitter {
    return self.serviceProvider.emitterController;
}

- (id<SPGDPRController>)gdpr {
    return self.serviceProvider.gdprController;
}

- (id<SPGlobalContextsController>)globalContexts {
    return self.serviceProvider.globalContextsController;
}

- (id<SPSubjectController>)subject {
    return self.serviceProvider.subjectController;
}

- (SPSessionControllerImpl *)sessionController {
    return self.serviceProvider.sessionController;
}

- (nullable id<SPSessionController>)session {
    SPSessionControllerImpl *sessionController = self.serviceProvider.sessionController;
    return sessionController.isEnabled ? sessionController : nil;
}

// MARK: - Control methods

- (void)pause {
    [self.tracker pauseEventTracking];
}

- (void)resume {
    [self.tracker resumeEventTracking];
}

- (void)track:(nonnull SPEvent *)event {
    [self.tracker track:event];
}

// MARK: - Properties' setters and getters

- (void)setAppId:(NSString *)appId {
    [self.tracker setAppId:appId];
}

- (NSString *)appId {
    return [self.tracker appId];
}

- (NSString *)namespace {
    return [self.tracker trackerNamespace];
}

- (void)setDevicePlatform:(SPDevicePlatform)devicePlatform {
    [self.tracker setDevicePlatform:devicePlatform];
}

- (SPDevicePlatform)devicePlatform {
    return [self.tracker devicePlatform];
}

- (void)setBase64Encoding:(BOOL)base64Encoding {
    [self.tracker setBase64Encoded:base64Encoding];
}

- (BOOL)base64Encoding {
    return [self.tracker base64Encoded];
}

- (void)setLogLevel:(SPLogLevel)logLevel {
    [SPLogger setLogLevel:logLevel];
}

- (SPLogLevel)logLevel {
    return [SPLogger logLevel];
}

- (void)setLoggerDelegate:(id<SPLoggerDelegate>)loggerDelegate {
    [SPLogger setDelegate:loggerDelegate];
}

- (id<SPLoggerDelegate>)loggerDelegate {
    return [SPLogger delegate];
}

- (void)setApplicationContext:(BOOL)applicationContext {
    [self.tracker setApplicationContext:applicationContext];
}

- (BOOL)applicationContext {
    return [self.tracker applicationContext];
}

- (void)setPlatformContext:(BOOL)platformContext {
    if (self.tracker.subject) {
        self.tracker.subject.platformContext = platformContext;
    }
}

- (BOOL)platformContext {
    return self.tracker.subject.platformContext;
}

- (void)setGeoLocationContext:(BOOL)geoLocationContext {
    if (self.tracker.subject) {
        self.tracker.subject.geoLocationContext = geoLocationContext;
    }
}

- (BOOL)geoLocationContext {
    return self.tracker.subject.geoLocationContext;
}

- (void)setDiagnosticAutotracking:(BOOL)diagnosticAutotracking {
    [self.tracker setTrackerDiagnostic:diagnosticAutotracking];
}

- (BOOL)diagnosticAutotracking {
    return self.tracker.trackerDiagnostic;
}

- (void)setExceptionAutotracking:(BOOL)exceptionAutotracking {
    [self.tracker setExceptionEvents:exceptionAutotracking];
}

- (BOOL)exceptionAutotracking {
    return [self.tracker exceptionEvents];
}

- (void)setInstallAutotracking:(BOOL)installAutotracking {
    [self.tracker setInstallEvent:installAutotracking];
}

- (BOOL)installAutotracking {
    return [self.tracker installEvent];
}

- (void)setLifecycleAutotracking:(BOOL)lifecycleAutotracking {
    [self.tracker setLifecycleEvents:lifecycleAutotracking];
}

- (BOOL)lifecycleAutotracking {
    return [self.tracker getLifecycleEvents];
}

- (void)setScreenContext:(BOOL)screenContext {
    [self.tracker setScreenContext:screenContext];
}

- (BOOL)screenContext {
    return [self.tracker screenContext];
}

- (void)setScreenViewAutotracking:(BOOL)screenViewAutotracking {
    [self.tracker setAutotrackScreenViews:screenViewAutotracking];
}

- (BOOL)screenViewAutotracking {
    return [self.tracker autoTrackScreenView];
}

- (void)setSessionContext:(BOOL)sessionContext {
    [self.tracker setSessionContext:sessionContext];
}

- (BOOL)sessionContext {
    return [self.tracker sessionContext];
}

- (BOOL)isTracking {
    return [self.tracker getIsTracking];
}

- (NSString *)version {
    return kSPVersion;
}

@end
