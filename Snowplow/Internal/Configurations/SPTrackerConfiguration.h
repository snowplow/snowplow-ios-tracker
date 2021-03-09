//
//  SPTrackerConfiguration.h
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

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"
#import "SPDevicePlatform.h"
#import "SPLoggerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TrackerConfigurationProtocol)
@protocol SPTrackerConfigurationProtocol

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

SP_BUILDER_DECLARE(NSString *, appId)
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
