//
//  SPUtils.h
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@interface SPUtilities : NSObject

/**
 *  Returns the system timezone region.
 *  @return A string of the timezone region (e.g. 'Toronto/Canada')
 */
+ (NSString *) getTimezone;

/**
 *  Returns the system language currently used on the device.
 *  @return A string of the current language.
 */
+ (NSString *) getLanguage;

/**
 *  Returns the platform type of the device. This is always going to be "mob".
 *  @return A string of the platform type.
 */
+ (NSString *) getPlatform;

/**
 *  Returns a randomly generated UUID (type 4).
 *  @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (NSString *) getEventId;

/**
 *  Returns a generated string unique to each device, used only for serving advertisements. This is similar to the native advertisingIdentifier supplied by Apple.
 *  @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (NSString *) getOpenIdfa;

/**
 *  Returns a generated string unique to each device, used only for serving advertisements. This works only if you have the AdSupport library in your project. If you have it, but do not want to use IDFA, add the complier flag <code>SNOWPLOW_NO_IFA</code> to your build settings.
 *  @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (NSString *) getAppleIdfa;

/**
 * Returns the generated identifier for vendors. More info can be found in UIDevice's identifierForVendor documentation.
 *  @return A string containing a formatted UUID for example E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 */
+ (NSString *) getAppleIdfv;

/**
 *  Returns the carrier of the SIM inserted in the device.
 *  @return A string containing the carrier name of the service provider.
 */
+ (NSString *) getCarrierName;

/**
 * Returns the Network Type the device is connected to
 * @return A string containing the Network Type
 */
+ (NSString *) getNetworkType;

/**
 * Returns the Network Technology the device is using
 * @return A string containing the Network Technology
 */
+ (NSString *) getNetworkTechnology;

/**
 *  Generates a randomly generated 6-digit integer.
 *  @return A random 6-digit int.
 */
+ (int) getTransactionId __deprecated;

/**
 *  Returns the timestamp generated at the point it was called.
 *  @return A double of the timestamp from when the method was called.
 */
+ (NSInteger) getTimestamp;

/**
 *  Calculates the resolution of the screen in-terms of actual pixels of the device. This doesn't count Retine-pixels which are technically subpixels.
 *  @return An NSDictionary with 'width' and 'height'.
 */
+ (NSString *) getResolution;

/**
 *  Calculates the viewport of the app as it is on the screen. Currently, returns the same value as getResolution.
 *  Returns an NSDictionary with 'width' and 'height'.
 */
+ (NSString *) getViewPort;

/**
 *  Returns the current device's vendor in the form of a string.
 *  @return A string with vendor, i.e. "Apple Inc."
 */
+ (NSString *) getDeviceVendor;

/**
 *  Returns the current device's model in the form of a string.
 *  @return A string with device model.
 */
+ (NSString *) getDeviceModel;

/**
 *  This is to detect what the version of mobile OS of the current device.
 *  @return The current device's OS version type as a string.
 */
+ (NSString *) getOSVersion;

/**
 *  This is to detect what the type of mobile OS of the current device.
 *  @return The current device's OS type as a string.
 */
+ (NSString *) getOSType;

/**
 *  Returns the Application ID
 *  @return The device bundle application id
 */
+ (NSString *) getAppId;

/**
 *  URL encodes a string so that it is suitable to use in a query-string. A nil s returns @"".
 *  @return The url encoded string
 */
+ (NSString *)urlEncodeString:(NSString *)s;

/**
 *  URL encodes a dictionary as key=value pairs separated by &, so that it can be used in a query-string.
 *  This method can encode string, numbers, and bool values, and not embedded arrays or dictionaries. It
 *  encodes bool as 1 and 0.
 *  @return The url encoded string of the dictionary
 */
+ (NSString *)urlEncodeDictionary:(NSDictionary *)d;

/**
 * Returns the byte size of the string
 * @param str The string to get the byte-size of
 * @return the byte size of the String
 */
+ (NSInteger) getByteSizeWithString:(NSString *)str;

/**
 * Returns whether or not the device is currently online.
 * @return the network status of the device
 */
+ (BOOL) isOnline;

/**
 * Checks an expression and will throw an exception if it is false.
 * This allows for rudimentary Preconditions for object setup.
 * @param argument The argument to check
 * @param message The message to append to the exception
 */
+ (void) checkArgument:(BOOL)argument withMessage:(NSString *)message;

/**
 *  Removes all entries which have a value of NSNull from the dictionary.
 *  @param dict An NSDictionary to be cleaned
 *  @return the same NSDictionary without any Null values
 */
+ (NSDictionary *) removeNullValuesFromDictWithDict:(NSDictionary *)dict;

@end
