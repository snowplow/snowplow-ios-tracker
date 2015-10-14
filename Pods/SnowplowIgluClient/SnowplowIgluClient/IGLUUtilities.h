//
//  IGLUUtilities.h
//  SnowplowIgluClient
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@interface IGLUUtilities : NSObject

/**
 * Parses an NSString to an NSDictionary JSON representation
 *
 * @param json The JSON String to parse
 * @return the NSDictionary JSON or Nil
 */
+ (NSDictionary *)parseToJsonWithString:(NSString *)json;

/**
 * Downloads a file from the Net and returns it as an NSString
 *
 * @param urlPath The Path to the online asset
 * @return the NSString version of the file
 */
+ (NSString *)getStringWithUrlPath:(NSString *)urlPath;

/**
 * Gets a String from a local file, parses it to an NSString and returns.
 *
 * @param filePath The file path to check for the JSON file
 * @param directory The directory the file should be in
 * @param mainBundle The bundle to do the resource lookup within
 * @return the JSON as an NSString or Nil
 */
+ (NSString *)getStringWithFilePath:(NSString *)filePath andDirectory:(NSString *)directory andBundle:(NSBundle *)mainBundle;

/**
 * Gets a JSON from a local file, parses it to an NSDictionary and returns.
 *
 * @param filePath The file path to check for the JSON file
 * @param directory The directory the file should be in
 * @param mainBundle The bundle to do the resource lookup within
 * @return the JSON as an NSDictionary or Nil
 */
+ (NSDictionary *)getJsonAsDictionaryWithFilePath:(NSString *)filePath andDirectory:(NSString *)directory andBundle:(NSBundle *)mainBundle;

/**
 * Checks whether the argument is valid and will throw an exception if it is not.
 *
 * @param argument The argument to validate
 * @param message The message to print out with the exception
 */
+ (void)checkArgument:(BOOL)argument withMessage:(NSString *)message;

@end
