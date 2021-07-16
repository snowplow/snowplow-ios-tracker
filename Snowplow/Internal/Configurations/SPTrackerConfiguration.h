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

/**
 * Identifer of the app.
 */
@property () NSString *appId;

/**
 * It sets the device platform the tracker is running on.
 */
@property () SPDevicePlatform devicePlatform;
/**
 * It indicates whether the JSON data in the payload should be base64 encoded.
 */
@property () BOOL base64Encoding;

/**
 * It sets the log level of tracker logs.
 */
@property () SPLogLevel logLevel;
/**
 * It sets the logger delegate that receive logs from the tracker.
 */
@property (nullable) id<SPLoggerDelegate> loggerDelegate;

/**
 * Whether application context is sent with all the tracked events.
 */
@property () BOOL applicationContext;
/**
 * Whether mobile/platform context is sent with all the tracked events.
 */
@property () BOOL platformContext;
/**
 * Whether geo-location context is sent with all the tracked events.
 */
@property () BOOL geoLocationContext;
/**
 * Whether session context is sent with all the tracked events.
 */
@property () BOOL sessionContext;
/**
 * Whether screen context is sent with all the tracked events.
 */
@property () BOOL screenContext;
/**
 * Whether enable automatic tracking of ScreenView events.
 */
@property () BOOL screenViewAutotracking;
/**
 * Whether enable automatic tracking of background and foreground transitions.
 */
@property () BOOL lifecycleAutotracking;
/**
 * Whether enable automatic tracking of install event.
 */
@property () BOOL installAutotracking;
/**
 * Whether enable crash reporting.
 */
@property () BOOL exceptionAutotracking;
/**
 * Whether enable diagnostic reporting.
 */
@property () BOOL diagnosticAutotracking;
/**
 * Decorate the v_tracker field in the tracker protocol.
 * @note Do not use. Internal use only.
 */
@property (nonatomic, nullable) NSString *trackerVersionSuffix;

@end

/**
 * This class represents the configuration of the tracker and the core tracker properties.
 * The TrackerConfiguration can be used to setup the tracker behaviour indicating what should be
 * tracked in term of automatic tracking and contexts/entities to track with the events.
 */
NS_SWIFT_NAME(TrackerConfiguration)
@interface SPTrackerConfiguration : SPConfiguration <SPTrackerConfigurationProtocol>

/**
 * It sets a default TrackerConfiguration.
 * Default values:
 *         devicePlatform = DevicePlatform.Mobile;
 *         base64encoding = true;
 *         logLevel = LogLevel.OFF;
 *         loggerDelegate = null;
 *         sessionContext = true;
 *         applicationContext = true;
 *         platformContext = true;
 *         geoLocationContext = false;
 *         screenContext = true;
 *         screenViewAutotracking = true;
 *         lifecycleAutotracking = true;
 *         installAutotracking = true;
 *         exceptionAutotracking = true;
 *         diagnosticAutotracking = false;
 */
- (instancetype)init;

/**
 * Identifer of the app.
 */
SP_BUILDER_DECLARE(NSString *, appId)
/**
 * It sets the device platform the tracker is running on.
 */
SP_BUILDER_DECLARE(SPDevicePlatform, devicePlatform)
/**
 * It indicates whether the JSON data in the payload should be base64 encoded.
 */
SP_BUILDER_DECLARE(BOOL, base64Encoding)
/**
 * It sets the log level of tracker logs.
 */
SP_BUILDER_DECLARE(SPLogLevel, logLevel)
/**
 * It sets the logger delegate that receive logs from the tracker.
 */
SP_BUILDER_DECLARE_NULLABLE(id<SPLoggerDelegate>, loggerDelegate)
/**
 * Whether application context is sent with all the tracked events.
 */
SP_BUILDER_DECLARE(BOOL, applicationContext)
/**
 * Whether mobile/platform context is sent with all the tracked events.
 */
SP_BUILDER_DECLARE(BOOL, platformContext)
/**
 * Whether geo-location context is sent with all the tracked events.
 */
SP_BUILDER_DECLARE(BOOL, geoLocationContext)
/**
 * Whether session context is sent with all the tracked events.
 */
SP_BUILDER_DECLARE(BOOL, sessionContext)
/**
 * Whether screen context is sent with all the tracked events.
 */
SP_BUILDER_DECLARE(BOOL, screenContext)
/**
 * Whether enable automatic tracking of ScreenView events.
 */
SP_BUILDER_DECLARE(BOOL, screenViewAutotracking)
/**
 * Whether enable automatic tracking of background and foreground transitions.
 */
SP_BUILDER_DECLARE(BOOL, lifecycleAutotracking)
/**
 * Whether enable automatic tracking of install event.
 */
SP_BUILDER_DECLARE(BOOL, installAutotracking)
/**
 * Whether enable crash reporting.
 */
SP_BUILDER_DECLARE(BOOL, exceptionAutotracking)
/**
 * Whether enable diagnostic reporting.
 */
SP_BUILDER_DECLARE(BOOL, diagnosticAutotracking)
/**
 * Internal use only.
 */
SP_BUILDER_DECLARE(NSString *, trackerVersionSuffix)

@end

NS_ASSUME_NONNULL_END
