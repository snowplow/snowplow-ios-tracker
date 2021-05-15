//
//  SPTrackerConfigurationUpdate.h
//  Snowplow
//
//  Created by Alex Benini on 14/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPTrackerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPTrackerConfigurationUpdate : SPTrackerConfiguration

@property (nonatomic, nullable) SPTrackerConfiguration *sourceConfig;

@property (nonatomic) BOOL isPaused;

SP_DIRTYFLAG(appId)
SP_DIRTYFLAG(devicePlatform)
SP_DIRTYFLAG(base64Encoding)
SP_DIRTYFLAG(logLevel)
SP_DIRTYFLAG(loggerDelegate)
SP_DIRTYFLAG(applicationContext)
SP_DIRTYFLAG(platformContext)
SP_DIRTYFLAG(geoLocationContext)
SP_DIRTYFLAG(sessionContext)
SP_DIRTYFLAG(screenContext)
SP_DIRTYFLAG(screenViewAutotracking)
SP_DIRTYFLAG(lifecycleAutotracking)
SP_DIRTYFLAG(installAutotracking)
SP_DIRTYFLAG(exceptionAutotracking)
SP_DIRTYFLAG(diagnosticAutotracking)

@end

NS_ASSUME_NONNULL_END
