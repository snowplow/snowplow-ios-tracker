//
//  SPTrackerController.m
//  Snowplow
//
//  Created by Alex Benini on 02/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPTrackerController.h"
#import "SPEmitterController.h"
#import "SPGDPRController.h"
#import "SPGlobalContextsController.h"

#import "SPSubjectConfiguration.h"
#import "SPNetworkConfiguration.h"

#import "Snowplow.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPLogger.h"

@interface SPTrackerController ()

@property (readwrite, nonatomic) id<SPEmitterControlling> emitter;
@property (readwrite, nonatomic) id<SPGDPRControlling> gdpr;
@property (readwrite, nonatomic) id<SPGlobalContextsControlling> globalContexts;

@property (nonatomic) SPTracker *tracker;

@end


@implementation SPTrackerController

// TODO: Check these two contexts can be edited at runtime. Legacy wants not editable (I guess)
@synthesize platformContext;
@synthesize geoLocationContext;

- (instancetype)initWithTracker:(SPTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
        self.emitter = [[SPEmitterController alloc] initWithEmitter:tracker.emitter];
        self.gdpr = [[SPGDPRController alloc] initWithTracker:tracker];
        self.globalContexts = [[SPGlobalContextsController alloc] initWithTracker:tracker];
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
    return self.tracker.session;
}

- (BOOL)isTracking {
    return [self.tracker getIsTracking];
}

- (NSString *)version {
    return kSPVersion;
}

@end
