//
//  SPPlatformContext.h
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
//  Authors: Matus Tomlein
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SPPayload;

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
- (instancetype) initWithMobileDictUpdateFrequency:(NSTimeInterval)mobileDictUpdateFrequency networkDictUpdateFrequency:(NSTimeInterval)networkDictUpdateFrequency;

/**
 * Updates and returns payload dictionary with device context information.
 */
- (nonnull SPPayload *) fetchPlatformDict;

/*!
 @brief Returns a generated string unique to each device, used only for serving advertisements. This works only if you have the AdSupport library in your project and you enable the compiler flag <code>SNOWPLOW_IDFA_ENABLED</code> to your build settings.
 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (nullable NSString *) appleIdfa;

/*!
 @brief Returns the generated identifier for vendors. More info can be found in UIDevice's identifierForVendor documentation. If you do not want to use IDFV, add the comiler flag <code>SNOWPLOW_NO_IDFV</code> to your build settings.
 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (nullable NSString *) appleIdfv;

/*!
 @brief Returns the current device's vendor in the form of a string.
 @return A string with vendor, i.e. "Apple Inc."
 */
+ (nullable NSString *) deviceVendor;

/*!
 @brief Returns the current device's model in the form of a string.
 @return A string with device model.
 */
+ (nullable NSString *) deviceModel;

/*!
 @brief This is to detect what the version of mobile OS of the current device.
 @return The current device's OS version type as a string.
 */
+ (nullable NSString *) osVersion;

/*!
 @brief This is to detect what the type of mobile OS of the current device.
 @return The current device's OS type as a string.
 */
+ (nullable NSString *) osType;

/*!
 @brief Returns the carrier of the SIM inserted in the device.
 @return A string containing the carrier name of the service provider.
 */
+ (nullable NSString *) carrierName;

/*!
 @brief Returns the Network Type the device is connected to.
 @return A string containing the Network Type.
 */
+ (nullable NSString *) networkType;

/*!
 @brief Returns the Network Technology the device is using.
 @return A string containing the Network Technology.
 */
+ (nullable NSString *) networkTechnology;

/**
 * @property ephemeralMobileDictUpdatesCount
 * @brief Number of updates of mobile platform dictionary.
 */
@property (nonatomic, readonly) long ephemeralMobileDictUpdatesCount;

/**
 * @property ephemeralNetworkDictUpdatesCount
 * @brief Number of updates of network platform dictionary.
 */
@property (nonatomic, readonly) long ephemeralNetworkDictUpdatesCount;

@end

NS_ASSUME_NONNULL_END
