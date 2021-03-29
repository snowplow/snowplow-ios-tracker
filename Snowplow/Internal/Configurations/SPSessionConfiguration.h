//
//  SPSessionConfiguration.h
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

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SessionConfigurationProtocol)
@protocol SPSessionConfigurationProtocol

/**
 * The amount of time that can elapse before the
 * session id is updated while the app is in the
 * foreground.
 */
@property NSInteger foregroundTimeoutInSeconds;
/**
 * The amount of time that can elapse before the
 * session id is updated while the app is in the
 * background.
 */
@property NSInteger backgroundTimeoutInSeconds;

/**
 * The amount of time that can elapse before the
 * session id is updated while the app is in the
 * foreground.
 */
@property NSMeasurement<NSUnitDuration *> *foregroundTimeout API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0));
/**
 * The amount of time that can elapse before the
 * session id is updated while the app is in the
 * background.
 */
@property NSMeasurement<NSUnitDuration *> *backgroundTimeout API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0));

@end

/**
 * This class represents the configuration from of the applications session.
 * The SessionConfiguration can be used to setup the behaviour of sessions.
 *
 * A session is a context which is appended to each event sent.
 * The values it brings can change based on:
 * - the timeout set for the inactivity of app when in foreground;
 * - the timeout set for the inactivity of app when in background.
 *
 * Session data is maintained for the life of the application being installed on a device.
 * A new session will be created if the session information is not accessed within a configurable timeout.
 */
NS_SWIFT_NAME(SessionConfiguration)
@interface SPSessionConfiguration : SPConfiguration <SPSessionConfigurationProtocol>

/**
 * This will setup the session behaviour of the tracker.
 * @param foregroundTimeout The timeout set for the inactivity of app when in foreground.
 * @param backgroundTimeout The timeout set for the inactivity of app when in background.
 */
- (instancetype)initWithForegroundTimeoutInSeconds:(NSInteger)foregroundTimeout backgroundTimeoutInSeconds:(NSInteger)backgroundTimeout;

/**
 * This will setup the session behaviour of the tracker.
 * @param foregroundTimeout The timeout set for the inactivity of app when in foreground.
 * @param backgroundTimeout The timeout set for the inactivity of app when in background.
 */
- (instancetype)initWithForegroundTimeout:(NSMeasurement<NSUnitDuration *> *)foregroundTimeout
                        backgroundTimeout:(NSMeasurement<NSUnitDuration *> *)backgroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0));

@end

NS_ASSUME_NONNULL_END
