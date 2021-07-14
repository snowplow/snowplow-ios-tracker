//
//  SPTrackerConfigurationUpdate.m
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
SP_DIRTY_GETTER(NSString *, trackerVersionSuffix)

@end
