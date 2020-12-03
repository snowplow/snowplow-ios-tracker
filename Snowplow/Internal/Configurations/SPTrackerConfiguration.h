//
//  SPTrackerConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 26/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPDevicePlatform.h"
#import "SPLoggerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerConfigurationProtocol)
@protocol SPTrackerConfigurationProtocol

@property () NSString *namespace;
@property () NSString *appId;

@property () SPDevicePlatform devicePlatform;
@property () BOOL base64Encoding;

@property () SPLogLevel logLevel;
@property (nullable) id<SPLoggerDelegate> loggerDelegate;

@property () BOOL applicationContext;
@property () BOOL platformContext;
@property () BOOL geoLocationContext;
@property () BOOL sessionContext;
@property () BOOL screenContext;
@property () BOOL screenViewAutotracking;
@property () BOOL lifecycleAutotracking;
@property () BOOL installAutotracking;
@property () BOOL exceptionAutotracking;
@property () BOOL diagnosticAutotracking;

@end

NS_SWIFT_NAME(TrackerConfiguration)
@interface SPTrackerConfiguration : SPConfiguration <SPTrackerConfigurationProtocol>

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;

- (instancetype)initWithNamespace:(NSString *)namespace appId:(NSString *)appId;

SP_BUILDER_DECLARE(SPDevicePlatform, devicePlatform)
SP_BUILDER_DECLARE(BOOL, base64Encoding)
SP_BUILDER_DECLARE(SPLogLevel, logLevel)
SP_BUILDER_DECLARE_NULLABLE(id<SPLoggerDelegate>, loggerDelegate)
SP_BUILDER_DECLARE(BOOL, applicationContext)
SP_BUILDER_DECLARE(BOOL, platformContext)
SP_BUILDER_DECLARE(BOOL, geoLocationContext)
SP_BUILDER_DECLARE(BOOL, sessionContext)
SP_BUILDER_DECLARE(BOOL, screenContext)
SP_BUILDER_DECLARE(BOOL, screenViewAutotracking)
SP_BUILDER_DECLARE(BOOL, lifecycleAutotracking)
SP_BUILDER_DECLARE(BOOL, installAutotracking)
SP_BUILDER_DECLARE(BOOL, exceptionAutotracking)
SP_BUILDER_DECLARE(BOOL, diagnosticAutotracking)

@end

NS_ASSUME_NONNULL_END
