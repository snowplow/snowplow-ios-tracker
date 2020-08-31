//
//  SPUtils.h
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#include "SPDevicePlatform.h"

@class SPPayload;
@class SPSelfDescribingJson;
@class SPScreenState;

#if SNOWPLOW_TARGET_IOS
#import <UserNotifications/UserNotifications.h>
#endif

/*!
 @class SPUtilities
 @brief A class of utility functions.

 This is a class that contains utility functions used throughout the tracker.
 */
@interface SPUtilities : NSObject

/*!
 @brief Returns the system timezone region.

 @return A string of the timezone region (e.g. 'Toronto/Canada').
 */
+ (NSString *) getTimezone;

/*!
 @brief Returns the system language currently used on the device.

 @return A string of the current language.
 */
+ (NSString *) getLanguage;

/*!
 @brief Returns the platform type of the device..

 @return A string of the platform type.
 */
+ (SPDevicePlatform) getPlatform;

/*!
 @brief Returns a randomly generated UUID (type 4).
 
 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 @deprecated Use `getUUIDString` instead`.
 */
+ (NSString *) getEventId __deprecated_msg("Use `getUUIDString` instead.");

/*!
 @brief Returns a randomly generated UUID (type 4).

 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (NSString *) getUUIDString;

/*!
 @brief Check if the value is a valid UUID (type 4).
 @param uuidString UUID string to validate.
 @return Weither is a valid UUID string.
 */
+ (bool ) isUUIDString:(NSString *)uuidString;

/*!
 @brief Returns a generated string unique to each device, used only for serving advertisements. This is similar to the native advertisingIdentifier supplied by Apple. If you do not want to use OpenIDFA, add the compiler flag <code>SNOWPLOW_NO_OPENIDFA</code> to your build settings.

 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (NSString *) getOpenIdfa;

/*!
 @brief Returns a generated string unique to each device, used only for serving advertisements. This works only if you have the AdSupport library in your project. If you have it, but do not want to use IDFA, add the compiler flag <code>SNOWPLOW_NO_IFA</code> to your build settings.

 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (NSString *) getAppleIdfa;

/*!
 @brief Returns the generated identifier for vendors. More info can be found in UIDevice's identifierForVendor documentation. If you do not want to use IDFV, add the comiler flag <code>SNOWPLOW_NO_IDFV</code> to your build settings.

 @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (NSString *) getAppleIdfv;

/*!
 @brief Returns the carrier of the SIM inserted in the device.

 @return A string containing the carrier name of the service provider.
 */
+ (NSString *) getCarrierName;

/*!
 @brief Returns the Network Type the device is connected to.

 @return A string containing the Network Type.
 */
+ (NSString *) getNetworkType;

/*!
 @brief Returns the Network Technology the device is using.

 @return A string containing the Network Technology.
 */
+ (NSString *) getNetworkTechnology;

/*!
 @brief Generates a randomly generated 6-digit integer.

 @return A random 6-digit int.
 */
+ (int) getTransactionId __deprecated;

/*!
 @brief Returns the timestamp generated at the point it was called.

 @return A double of the timestamp from when the method was called.
 */
+ (NSNumber *) getTimestamp;

/*!
 @brief Calculates the resolution of the screen in-terms of actual pixels of the device. This doesn't count Retine-pixels which are technically subpixels.

 @return A formatted string with resolution 'width' and 'height'.
 */
+ (NSString *) getResolution;

/*!
 @brief Calculates the viewport of the app as it is on the screen. Currently, returns the same value as getResolution.

 @return A formatted string with viewport width and height.
 */
+ (NSString *) getViewPort;

/*!
 @brief Returns the current device's vendor in the form of a string.

 @return A string with vendor, i.e. "Apple Inc."
 */
+ (NSString *) getDeviceVendor;

/*!
 @brief Returns the current device's model in the form of a string.

 @return A string with device model.
 */
+ (NSString *) getDeviceModel;

/*!
 @brief This is to detect what the version of mobile OS of the current device.

 @return The current device's OS version type as a string.
 */
+ (NSString *) getOSVersion;

/*!
 @brief This is to detect what the type of mobile OS of the current device.

 @return The current device's OS type as a string.
 */
+ (NSString *) getOSType;

/*!
 @brief Returns the Application ID

 @return The device bundle application id
 */
+ (NSString *) getAppId;

/*!
 @brief URL encodes a string so that it is suitable to use in a query-string. A nil s returns @"".

 @return The url encoded string
 */
+ (NSString *)urlEncodeString:(NSString *)s;

/*!
 @brief URL encodes a dictionary as key=value pairs separated by &, so that it can be used in a query-string.

 This method can encode string, numbers, and bool values, and not embedded arrays or dictionaries.
 It encodes bool as 1 and 0.

 @return The url encoded string of the dictionary.
 */
+ (NSString *)urlEncodeDictionary:(NSDictionary *)d;

/*!
 @brief Returns the byte size of a string.

 @param str A string.
 @return The byte size of the string.
 */
+ (NSInteger) getByteSizeWithString:(NSString *)str __deprecated_msg("getByteSizeWithString is deprecated. Use NSString method instead.");

/*!
 @brief Checks an expression and will log if it is false.

 This allows for rudimentary Preconditions for object setup.

 @param argument The argument to check.
 @param message The message to log.
 */
+ (void) checkArgument:(BOOL)argument withMessage:(NSString *)message;

/*!
 @brief Removes all entries which have a value of NSNull from the dictionary.

 @param dict An NSDictionary to be cleaned.
 @return The same NSDictionary without any Null values.
 */
+ (NSDictionary *) removeNullValuesFromDictWithDict:(NSDictionary *)dict;

/*!
 @brief Maps a trigger object to the corresponding simplified string.
 @param trigger A UNNotificationTrigger object.

 @return A string describing the type of trigger.
 */
#if SNOWPLOW_TARGET_IOS
+ (NSString *) getTriggerType:(UNNotificationTrigger *)trigger NS_AVAILABLE_IOS(10.0);
#endif

/*!
 @brief Converts a UNNotificationAttachment array into an array of string dictionaries.
 @param attachments An array of UNNotificationAttachment.
 @return An array of string dictionaries.
 */

#if SNOWPLOW_TARGET_IOS
+ (NSArray<NSDictionary *> *) convertAttachments:(NSArray<UNNotificationAttachment *> *)attachments NS_AVAILABLE_IOS(10.0);
#endif

/*!
 @brief Converts a kebab-case string keys into a camel-case string keys.
 @param dict The dictionary to convert.
 @return A dictionary.
 */
+ (NSDictionary *) replaceHyphenatedKeysWithCamelcase:(NSDictionary *)dict;

/*!
 Converts a kebab-case string into a camel-case string.
 @param key A kebab-case key.
 @return A camel-case string.
 */
+ (NSString *) camelcaseParsedKey:(NSString *)key;

/*!
 Return nil if value is nil or empty string, otherwise return string.
 @param aString Some string
 @return A string or nil
 */
+ (NSString *) validateString:(NSString *)aString;

/*!
 Returns a screen context SDJ given a screen state object.
 @param screenState Some screen state
 @return A context SDJ.
 */
+ (SPSelfDescribingJson *) getScreenContextWithScreenState:(SPScreenState *)screenState;

/*!
 Returns the app version.
 @return App version string.
 */
+ (NSString *) getAppVersion;
 
 /*!
 Returns the app build.
 @return App build string.
 */
+ (NSString *) getAppBuild;

/*!
 Returns the application build and version as a payload to be used in the application context.
 @return A context SDJ.
 */
+ (SPSelfDescribingJson *) getApplicationContext;

/*!
 Returns the application build and version as a payload to be used in the application context.
 @param version The application version
 @param build The application build
 @return A context SDJ.
 */
+ (SPSelfDescribingJson *) getApplicationContextWithVersion:(NSString *)version andBuild:(NSString *)build;

@end
