//
//  IGLUResolver.h
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

@class IGLUSchema;

@interface IGLUResolver : NSObject

/**
 * Creates a new Resolver with a JSON String.
 *
 * @param json The resolver JSON used for setup
 */
- (id) initWithDictionary:(NSDictionary *)json;

/**
 * Returns an NSDictionary containing a Schema that was just looked up.
 * 
 * @param key The SchemaKey to try and get a JsonSchema for
 * @param bundles The bundle objects to search for embedded files
 * @return the NSDictionary containing the Schema or Nil
 */
- (NSDictionary *)getSchemaForKey:(NSString *)key withBundles:(NSMutableArray *)bundles;

/**
 * Returns the name.
 *
 * @return the name value as an NSString
 */
- (NSString *)getName;

/**
 * Returns the type.
 *
 * @return the type value as an NSString
 */
- (NSString *)getType;

/**
 * Returns the uri.
 *
 * @return the uri value as an NSString
 */
- (NSString *)getUri;

/**
 * Returns the path.
 *
 * @return the path value as an NSString
 */
- (NSString *)getPath;


/**
 * Returns the priority.
 *
 * @return the priority value as an NSNumber
 */
- (NSNumber *)getPriority;

/**
 * Returns the vendor prefixes.
 *
 * @return the vendor prefixes as an NSArray
 */
- (NSArray *)getVendorPrefixes;

@end
