//
//  SPTrackerConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPTrackerConfiguration.h"

@implementation SPTrackerConfiguration

@synthesize namespace;
@synthesize appId;
@synthesize devicePlatform;
@synthesize base64Encoding;
@synthesize logLevel;
@synthesize loggerDelegate;
@synthesize applicationContext;
@synthesize platformContext;
@synthesize geoLocationContext;
@synthesize sessionContext;
@synthesize screenContext;
@synthesize screenViewAutotracking;
@synthesize lifecycleAutotracking;
@synthesize installAutotracking;
@synthesize exceptionAutotracking;
@synthesize diagnosticAutotracking;

- (instancetype)initWithNamespace:(NSString *)namespace appId:(NSString *)appId {
    if (self = [super init]) {
        self.namespace = namespace;
        self.appId = appId;

        self.devicePlatform = SPDevicePlatformMobile;
        self.base64Encoding = YES;
        
        self.logLevel = SPLogLevelOff;
        self.loggerDelegate = nil;

        self.sessionContext = YES;
        self.applicationContext = YES;
        self.platformContext = YES;
        self.geoLocationContext = NO;
        self.screenContext = YES;
        self.screenViewAutotracking = YES;
        self.lifecycleAutotracking = YES;
        self.installAutotracking = YES;
        self.exceptionAutotracking = YES;
        self.diagnosticAutotracking = NO;
    }
    return self;
}

// MARK: - Builder

SP_BUILDER_METHOD(SPDevicePlatform, devicePlatform)
SP_BUILDER_METHOD(BOOL, base64Encoding)
SP_BUILDER_METHOD(SPLogLevel, logLevel)
SP_BUILDER_METHOD(id<SPLoggerDelegate>, loggerDelegate)
SP_BUILDER_METHOD(BOOL, applicationContext)
SP_BUILDER_METHOD(BOOL, platformContext)
SP_BUILDER_METHOD(BOOL, geoLocationContext)
SP_BUILDER_METHOD(BOOL, sessionContext)
SP_BUILDER_METHOD(BOOL, screenContext)
SP_BUILDER_METHOD(BOOL, screenViewAutotracking)
SP_BUILDER_METHOD(BOOL, lifecycleAutotracking)
SP_BUILDER_METHOD(BOOL, installAutotracking)
SP_BUILDER_METHOD(BOOL, exceptionAutotracking)
SP_BUILDER_METHOD(BOOL, diagnosticAutotracking)

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPTrackerConfiguration *copy = [[SPTrackerConfiguration allocWithZone:zone] initWithNamespace:self.namespace appId:self.appId];
    copy.devicePlatform = self.devicePlatform;
    copy.base64Encoding = self.base64Encoding;
    copy.logLevel = self.logLevel;
    copy.loggerDelegate = self.loggerDelegate;
    copy.sessionContext = self.sessionContext;
    copy.applicationContext = self.applicationContext;
    copy.platformContext = self.platformContext;
    copy.geoLocationContext = self.geoLocationContext;
    copy.screenContext = self.screenContext;
    copy.screenViewAutotracking = self.screenViewAutotracking;
    copy.lifecycleAutotracking = self.lifecycleAutotracking;
    copy.installAutotracking = self.installAutotracking;
    copy.exceptionAutotracking = self.exceptionAutotracking;
    copy.diagnosticAutotracking = self.diagnosticAutotracking;
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.namespace forKey:SP_STR_PROP(namespace)];
    [coder encodeObject:self.appId forKey:SP_STR_PROP(appId)];
    [coder encodeInteger:self.logLevel forKey:SP_STR_PROP(logLevel)];
    [coder encodeObject:self.loggerDelegate forKey:SP_STR_PROP(loggerDelegate)];
    [coder encodeBool:self.sessionContext forKey:SP_STR_PROP(sessionContext)];
    [coder encodeBool:self.applicationContext forKey:SP_STR_PROP(applicationContext)];
    [coder encodeBool:self.platformContext forKey:SP_STR_PROP(platformContext)];
    [coder encodeBool:self.geoLocationContext forKey:SP_STR_PROP(geoLocationContext)];
    [coder encodeBool:self.screenContext forKey:SP_STR_PROP(screenContext)];
    [coder encodeBool:self.screenViewAutotracking forKey:SP_STR_PROP(screenViewAutotracking)];
    [coder encodeBool:self.lifecycleAutotracking forKey:SP_STR_PROP(lifecycleAutotracking)];
    [coder encodeBool:self.installAutotracking forKey:SP_STR_PROP(installAutotracking)];
    [coder encodeBool:self.exceptionAutotracking forKey:SP_STR_PROP(exceptionAutotracking)];
    [coder encodeBool:self.diagnosticAutotracking forKey:SP_STR_PROP(diagnosticAutotracking)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.namespace = [coder decodeObjectForKey:SP_STR_PROP(namespace)];
        self.appId = [coder decodeObjectForKey:SP_STR_PROP(appId)];
        self.logLevel = [coder decodeIntegerForKey:SP_STR_PROP(logLevel)];
        self.loggerDelegate = [coder decodeObjectForKey:SP_STR_PROP(loggerDelegate)];
        self.sessionContext = [coder decodeBoolForKey:SP_STR_PROP(sessionContext)];
        self.applicationContext = [coder decodeBoolForKey:SP_STR_PROP(applicationContext)];
        self.platformContext = [coder decodeBoolForKey:SP_STR_PROP(platformContext)];
        self.geoLocationContext = [coder decodeBoolForKey:SP_STR_PROP(geoLocationContext)];
        self.screenContext = [coder decodeBoolForKey:SP_STR_PROP(screenContext)];
        self.screenViewAutotracking = [coder decodeBoolForKey:SP_STR_PROP(screenViewAutotracking)];
        self.lifecycleAutotracking = [coder decodeBoolForKey:SP_STR_PROP(lifecycleAutotracking)];
        self.installAutotracking = [coder decodeBoolForKey:SP_STR_PROP(installAutotracking)];
        self.exceptionAutotracking = [coder decodeBoolForKey:SP_STR_PROP(exceptionAutotracking)];
        self.diagnosticAutotracking = [coder decodeBoolForKey:SP_STR_PROP(diagnosticAutotracking)];
    }
    return self;
}

@end
