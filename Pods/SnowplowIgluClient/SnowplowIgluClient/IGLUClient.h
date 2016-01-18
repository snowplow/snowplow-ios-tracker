//
//  IGLUClient.h
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

@interface IGLUClient : NSObject

/**
 * Creates a new Iglu Client with a JSON String.
 *
 * @param json A JSON String containing a resolver-config
 * @param bundles an array of bundles that we can search in
 */
- (id)initWithJsonString:(NSString *)json andBundles:(NSMutableArray *)bundles;

/**
 * Creates a new Iglu Client with a url path leading to a JSON String.
 *
 * @param urlPath A String containing a URL of a resolver-config
 * @param bundles an array of bundles that we can search in
 */
- (id)initWithUrlPath:(NSString *)urlPath andBundles:(NSMutableArray *)bundles;

/**
 * Validates a JSON against the Iglu Client and all of its resolvers.
 * - Checks the cache first for any matches
 * - Checks each resolver in order of priority
 * - Validates whether the JSON validates
 *
 * @param newJson The JSON to test and validate
 * @return whether the JSON is valid or not
 */
- (BOOL)validateJson:(NSDictionary *)newJson;

/**
 * Adds a bundle object to the searchable bundles array.
 *
 * @param bundle The bundle object to add.
 */
- (void)addToBundles:(NSBundle *)bundle;

/**
 * Returns the array of bundles the client currently has.
 *
 * @return the mutable array of bundles.
 */
- (NSMutableArray *)getBundles;

/**
 * Returns the array of resolvers that have been configured from the resolver config
 *
 * @return the resolver array
 */
- (NSMutableArray *)getResolvers;

/**
 * Returns the cache size set from the resolver config
 *
 * @return the cache size as an NSInteger
 */
- (NSInteger)getCacheSize;

/**
 * Returns the current count of cached JSON Schemas
 *
 * @return the count as an NSInteger
 */
- (NSInteger)getSuccessSize;

/**
 * Returns the current count of failed JSON Schemas
 *
 * @return the count as an NSInteger
 */
- (NSInteger)getFailedSize;

/**
 * Will empty the cache of all IGLUSchema's.
 * This includes both good and bad caches
 */
- (void)clearCaches;

@end
