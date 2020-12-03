//
//  SPTrackerController.m
//  Snowplow
//
//  Created by Alex Benini on 02/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPTrackerController.h"
#import "SPEmitterController.h"

#import "SPSubjectConfiguration.h"
#import "SPNetworkConfiguration.h"

#import "Snowplow.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPLogger.h"

@interface SPTrackerController ()

@property (readwrite, nonatomic, nullable) id<SPEmitterControlling> emitter;

@property (nonatomic) SPTracker *tracker;

@end


@implementation SPTrackerController

@synthesize platformContext;
@synthesize geoLocationContext;

- (instancetype)initWithTracker:(SPTracker *)tracker {
    if (self = [super init]) {
        self.tracker = tracker;
        self.emitter = [[SPEmitterController alloc] initWithEmitter:tracker.emitter];
    }
    return self;
}

+ (id<SPTrackerControlling>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration configurations:(NSArray<SPConfiguration *> *)configurations {
    SPSubjectConfiguration *subjectConfiguration = nil;
    SPSessionConfiguration *sessionConfiguration = nil;
    SPEmitterConfiguration *emitterConfiguration = nil;
    for (SPConfiguration *configuration in configurations) {
        if ([configuration isKindOfClass:SPSubjectConfiguration.class]) {
            subjectConfiguration = (SPSubjectConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPSessionConfiguration.class]) {
            sessionConfiguration = (SPSessionConfiguration *)configuration;
            continue;
        }
        if ([configuration isKindOfClass:SPEmitterConfiguration.class]) {
            emitterConfiguration = (SPEmitterConfiguration *)configuration;
            continue;
        }
    }
    SPEmitter *emitter = [SPEmitter build:^(id<SPEmitterBuilder> builder) {
        [builder setHttpMethod:networkConfiguration.method];
        [builder setProtocol:networkConfiguration.protocol];
        [builder setUrlEndpoint:networkConfiguration.endpoint];
        [builder setCustomPostPath:networkConfiguration.customPostPath];
        [builder setEmitRange:emitterConfiguration.emitRange];
        [builder setBufferOption:emitterConfiguration.bufferOption];
        [builder setEventStore:emitterConfiguration.eventStore];
        [builder setNetworkConnection:emitterConfiguration.networkConnection];
        [builder setByteLimitPost:emitterConfiguration.byteLimitPost];
        [builder setByteLimitGet:emitterConfiguration.byteLimitGet];
        [builder setEmitThreadPoolSize:emitterConfiguration.emitThreadPoolSize];
    }];
    SPSubject *subject = [[SPSubject alloc] initWithPlatformContext:trackerConfiguration.platformContext
                                                 geoLocationContext:trackerConfiguration.geoLocationContext
                                               subjectConfiguration:subjectConfiguration
                          ];
    SPTracker *tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
        [builder setEmitter:emitter];
        [builder setSubject:subject];
        [builder setAppId:trackerConfiguration.appId];
        [builder setTrackerNamespace:trackerConfiguration.namespace];
        [builder setBase64Encoded:trackerConfiguration.base64Encoding];
        [builder setLogLevel:trackerConfiguration.logLevel];
        [builder setLoggerDelegate:trackerConfiguration.loggerDelegate];
        [builder setDevicePlatform:trackerConfiguration.devicePlatform];
        [builder setSessionContext:trackerConfiguration.sessionContext];
        [builder setApplicationContext:trackerConfiguration.applicationContext];
        [builder setScreenContext:trackerConfiguration.screenContext];
        [builder setAutotrackScreenViews:trackerConfiguration.screenViewAutotracking];
        [builder setLifecycleEvents:trackerConfiguration.lifecycleAutotracking];
        [builder setInstallEvent:trackerConfiguration.installAutotracking];
        [builder setExceptionEvents:trackerConfiguration.exceptionAutotracking];
        [builder setTrackerDiagnostic:trackerConfiguration.diagnosticAutotracking];
        if (sessionConfiguration) {
            [builder setBackgroundTimeout:sessionConfiguration.backgroundTimeoutInSeconds];
            [builder setForegroundTimeout:sessionConfiguration.foregroundTimeoutInSeconds];
        }
    }];
    
    SPTrackerController *trackerController = [[SPTrackerController alloc] initWithTracker:tracker];
    return trackerController;
}

+ (id<SPTrackerControlling>)setupWithNetwork:(SPNetworkConfiguration *)networkConfiguration tracker:(SPTrackerConfiguration *)trackerConfiguration {
    return [SPTrackerController setupWithNetwork:networkConfiguration tracker:trackerConfiguration configurations:@[]];
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
