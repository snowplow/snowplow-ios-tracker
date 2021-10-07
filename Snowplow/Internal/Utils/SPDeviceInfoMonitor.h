//
//  SPDeviceInfoMonitor.h
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

@interface SPDeviceInfoMonitor : NSObject

/*!
 @brief Returns a generated string unique to each device, used only for serving advertisements. This works only if you have the AdSupport library in your project and you enable the compiler flag <code>SNOWPLOW_IDFA_ENABLED</code> to your build settings.
 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
- (nullable NSString *) appleIdfa;

/*!
 @brief Returns the generated identifier for vendors. More info can be found in UIDevice's identifierForVendor documentation. If you do not want to use IDFV, add the comiler flag <code>SNOWPLOW_NO_IDFV</code> to your build settings.
 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
- (nullable NSString *) appleIdfv;

/*!
 @brief Returns the current device's vendor in the form of a string.
 @return A string with vendor, i.e. "Apple Inc."
 */
- (nullable NSString *) deviceVendor;

/*!
 @brief Returns the current device's model in the form of a string.
 @return A string with device model.
 */
- (nullable NSString *) deviceModel;

/*!
 @brief This is to detect what the version of mobile OS of the current device.
 @return The current device's OS version type as a string.
 */
- (nullable NSString *) osVersion;

/*!
 @brief This is to detect what the type of mobile OS of the current device.
 @return The current device's OS type as a string.
 */
- (nullable NSString *) osType;

/*!
 @brief Returns the carrier of the SIM inserted in the device.
 @return A string containing the carrier name of the service provider.
 */
- (nullable NSString *) carrierName;

/*!
 @brief Returns the Network Type the device is connected to.
 @return A string containing the Network Type.
 */
- (nullable NSString *) networkType;

/*!
 @brief Returns the Network Technology the device is using.
 @return A string containing the Network Technology.
 */
- (nullable NSString *) networkTechnology;

/*!
 @brief Returns remaining battery level as an integer percentage of total battery capacity.
 @return Battery level.
 */
- (NSNumber *) batteryLevel;

/*!
 @brief Returns battery state for the device.
 @return One of "charging", "full", "unplugged" or NULL
 */
- (NSString *) batteryState;

/*!
 @brief Returns whether low power mode is activated.
 @return Boolean indicating the state of low power mode.
 */
- (NSNumber *) isLowPowerModeEnabled;

/*!
 @brief Returns total physical system memory in bytes.
 @return Total physical system memory in bytes.
 */
- (NSNumber *) physicalMemory;

/*!
 @brief Returns the amount of memory in bytes available to the current app (iOS 13+).
 @return Amount of memory in bytes available to the current app (or 0 if not supported).
 */
- (NSNumber *) appAvailableMemory;

/*!
 @brief Returns number of bytes of storage remaining. The information is requested from the home directory.
 @return Bytes of storage remaining.
 */
- (NSNumber *) availableStorage;

/*!
 @brief Returns the total number of bytes of storage. The information is requested from the home directory.
 @return Total size of storage in bytes.
 */
- (NSNumber *) totalStorage;

@end

NS_ASSUME_NONNULL_END
