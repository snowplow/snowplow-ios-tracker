//
//  SPTrackerConfigurationUpdate.m
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPTrackerConfigurationUpdate.h"

@implementation SPTrackerConfigurationUpdate

SP_DIRTY_GETTER(NSString *, appId)
SP_DIRTY_GETTER(SPDevicePlatform, devicePlatform)
SP_DIRTY_GETTER(BOOL, base64Encoding)
SP_DIRTY_GETTER(SPLogLevel, logLevel)
SP_DIRTY_GETTER(id<SPLoggerDelegate>, loggerDelegate)
SP_DIRTY_GETTER(BOOL, applicationContext)
SP_DIRTY_GETTER(BOOL, platformContext)
SP_DIRTY_GETTER(BOOL, geoLocationContext)
SP_DIRTY_GETTER(BOOL, sessionContext)
SP_DIRTY_GETTER(BOOL, screenContext)
SP_DIRTY_GETTER(BOOL, screenViewAutotracking)
SP_DIRTY_GETTER(BOOL, lifecycleAutotracking)
SP_DIRTY_GETTER(BOOL, installAutotracking)
SP_DIRTY_GETTER(BOOL, exceptionAutotracking)
SP_DIRTY_GETTER(BOOL, diagnosticAutotracking)

@end
