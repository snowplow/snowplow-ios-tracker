//
//  SPUtils.h
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#include "SPDevicePlatform.h"
#import "SPTrackerConstants.h"

@class SPPayload;
@class SPSelfDescribingJson;
@class SPScreenState;

/*!
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
 */
+ (NSString *) getUUIDString;

/*!
 @brief Check if the value is a valid UUID (type 4).
 @param uuidString UUID string to validate.
 @return Weither is a valid UUID string.
 */
+ (bool ) isUUIDString:(NSString *)uuidString;

/*!
 @brief Returns the timestamp (in milliseconds) generated at the point it was called.
 @return A double of the timestamp from when the method was called.
 */
+ (NSNumber *) getTimestamp;

/*!
 @brief Converts a timestamp (in milliseconds) to ISO8601 formatted string
 @return ISO8601 formatted string
 */
+ (NSString *) timestampToISOString:(long long)timestamp;

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
