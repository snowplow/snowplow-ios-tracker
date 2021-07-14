//
//  SPTrackerConfigurationUpdate.h
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
SP_DIRTYFLAG(trackerVersionSuffix)

@end

NS_ASSUME_NONNULL_END
