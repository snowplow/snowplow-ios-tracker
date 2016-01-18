//
//  IGLUSchema.h
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

@interface IGLUSchema : NSObject

/**
 * Creates a new IGLUSchema which contains a lookup key and the
 * downloaded schema file.
 *
 * @param key The SchemaKey
 * @param schema The NSDictionary containing the JSONSchema file
 * @param regex A precompiled regular expression for determining valid schema keys
 */
- (id)initWithKey:(NSString *)key andSchema:(NSDictionary *)schema andRegex:(NSRegularExpression *)regex;

/**
 * Sets a new Schema dictionary
 *
 * @param schema The JsonSchema as an NSDictionary
 */
- (void)setSchema:(NSDictionary *)schema;

/**
 * Whether the Key could be correctly divided into sections passed on our regex.
 *
 * @return whether the Schema Key was valid or not
 */
- (BOOL)getValid;

/**
 * Returns the Vendor.
 *
 * @return the schema vendor as an NSString
 */
- (NSString *)getVendor;

/**
 * Returns the Schema Name.
 *
 * @return the schema name as an NSString
 */
- (NSString *)getName;

/**
 * Returns the Schema Format.
 *
 * @return the schema format as an NSString
 */
- (NSString *)getFormat;

/**
 * Returns the Schema Version.
 *
 * @return the schema version as an NSString
 */
- (NSString *)getVersion;

/**
 * Returns the Schema Dictionary.
 *
 * @return the schema dictionary as an NSDictionary
 */
- (NSDictionary *)getSchema;


/**
 * Returns the SchemaKey; either the parts put back together or an invalid key that was stored.
 *
 * @return the key
 */
- (NSString *)getKey;

@end
