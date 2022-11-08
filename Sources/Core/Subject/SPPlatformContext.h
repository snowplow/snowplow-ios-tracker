//
//  SPPlatformContext.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Matus Tomlein
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SPPayload;
@class SPDeviceInfoMonitor;

/*!
 @class SPPlatformContext
 @brief Manages a dictionary (SPPayload) with platform context. Some properties for mobile platforms are updated on fetch in set intervals.
 */

@interface SPPlatformContext : NSObject

/**
 * Initializes a newly allocated PlatformContext object with default update frequency
 * @return a PlatformContext object
 */
- (instancetype) init;

/**
 * Initializes a newly allocated PlatformContext object with custom update frequency for mobile and network properties
 * @param mobileDictUpdateFrequency Minimal gap between subsequent updates of mobile platform information
 * @param networkDictUpdateFrequency Minimal gap between subsequent updates of network platform information
 * @return a PlatformContext object
 */
- (instancetype) initWithMobileDictUpdateFrequency:(NSTimeInterval)mobileDictUpdateFrequency
                        networkDictUpdateFrequency:(NSTimeInterval)networkDictUpdateFrequency;

/**
 * Initializes a newly allocated PlatformContext object with custom update frequency for mobile and network properties and a custom device info monitor
 * @param mobileDictUpdateFrequency Minimal gap between subsequent updates of mobile platform information
 * @param networkDictUpdateFrequency Minimal gap between subsequent updates of network platform information
 * @param deviceInfoMonitor Device monitor for fetching platform information
 * @return a PlatformContext object
 */
- (instancetype) initWithMobileDictUpdateFrequency:(NSTimeInterval)mobileDictUpdateFrequency
                        networkDictUpdateFrequency:(NSTimeInterval)networkDictUpdateFrequency
                                 deviceInfoMonitor:(SPDeviceInfoMonitor *)deviceInfoMonitor;

/**
 * Updates and returns payload dictionary with device context information.
 * @param userAnonymisation Whether to anonymise user identifiers (IDFA values)
 */
- (nonnull SPPayload *) fetchPlatformDictWithUserAnonymisation:(BOOL)userAnonymisation;

@end

NS_ASSUME_NONNULL_END
