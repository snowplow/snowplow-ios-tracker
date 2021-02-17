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

#import "SPTrackerController.h"
#import "SPEmitterController.h"
#import "SPNetworkController.h"
#import "SPGDPRController.h"
#import "SPGlobalContextsController.h"
#import "SPSessionController.h"

#import "SPSubjectConfiguration.h"
#import "SPNetworkConfiguration.h"

#import "TrackerConstants.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPDefaultNetworkConnection.h"
#import "SPSubject.h"
#import "SPLogger.h"

@interface SPTrackerController ()

@property (readwrite, nonatomic) id<SPNetworkControlling> network;
@property (readwrite, nonatomic) id<SPEmitterControlling> emitter;
@property (readwrite, nonatomic) id<SPGDPRControlling> gdpr;
@property (readwrite, nonatomic) id<SPGlobalContextsControlling> globalContexts;

@property (nonatomic) SPSessionController *sessionController;

@property (nonatomic) SPTracker *tracker;

@end


@implementation SPTrackerController

// TODO: Check these two contexts can be edited at runtime. Legacy wants not editable (I guess)
@synthesize platformContext;
@synthesize geoLocationContext;

- (instancetype)initWithTracker:(SPTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
        self.sessionController = [[SPSessionController alloc] initWithTracker:tracker];
        self.emitter = [[SPEmitterController alloc] initWithEmitter:tracker.emitter];
        self.gdpr = [[SPGDPRController alloc] initWithTracker:tracker];
        self.globalContexts = [[SPGlobalContextsController alloc] initWithTracker:tracker];
        if (!tracker.emitter.networkConnection || [tracker.emitter.networkConnection isKindOfClass:SPDefaultNetworkConnection.class]) {
            self.network = [[SPNetworkController alloc] initWithEmitter:tracker.emitter];
        }
    }
    return self;
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

- (void)trackSelfDescribingEvent:(nonnull SPSelfDescribingJson *)event {
    [self.tracker trackSelfDescribingEvent:event];
}

// MARK: - Properties' setters and getters

- (void)setAppId:(NSString *)appId {
    [self.tracker setAppId:appId];
}

- (NSString *)appId {
    return [self.tracker appId];
}

- (void)setNamespace:(NSString *)namespace {
    [self.tracker setTrackerNamespace:namespace];
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

- (void)setDiagnosticAutotracking:(BOOL)diagnosticAutotracking {
    [self.tracker setTrackerDiagnostic:diagnosticAutotracking];
}

- (BOOL)diagnosticAutotracking {
    return [SPLogger diagnosticLogger] != nil;
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

- (nullable id<SPSessionControlling>)session {
    return self.sessionController.isEnabled ? self.sessionController : nil;
}

- (BOOL)isTracking {
    return [self.tracker getIsTracking];
}

- (NSString *)version {
    return kSPVersion;
}

@end
