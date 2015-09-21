//
//  SPSelfDescribingJson.h
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SPPayload;

@interface SPSelfDescribingJson : NSObject

/**
 *  Initializes a newly allocated SPSelfDescribingJson
 *  @param schema a valid schema string
 *  @param data data to be embedded into the SelfDescribingJson
 *  @return An SPSelfDescribingJson.
 */
- (id) initWithSchema:(NSString *)schema andData:(NSObject *)data;

/**
 *  Initializes a newly allocated SPSelfDescribingJson
 *  @param schema a valid schema string
 *  @param data payload to be embedded into the SelfDescribingJson
 *  @return An SPSelfDescribingJson.
 */
- (id) initWithSchema:(NSString *)schema andPayload:(SPPayload *)data;

/**
 *  Initializes a newly allocated SPSelfDescribingJson
 *  @param schema a valid schema string
 *  @param data payload to be embedded into the SelfDescribingJson
 *  @return An SPSelfDescribingJson.
 */
- (id) initWithSchema:(NSString *)schema andSelfDescribingJson:(SPSelfDescribingJson *)data;

/**
 * Sets the Schema String to be used for this SelfDescribingJson
 * @param schema The Schema String
 */
- (void) setSchema:(NSString *)schema;

/**
 * Sets the Data of the SelfDescribingJson
 * @param data an NSObject to be nested into the data
 */
- (void) setDataWithObject:(NSObject *)data;

/**
 * Sets the Data of the SelfDescribingJson
 * @param data an SPPayload to be nested into the data
 */
- (void) setDataWithPayload:(SPPayload *)data;

/**
 * Sets the Data of the SelfDescribingJson
 * @param data an SelfDescribingJson to be nested into the data
 */
- (void) setDataWithSelfDescribingJson:(SPSelfDescribingJson *)data;

/**
 * Returns the internal NSDictionary of the SelfDescribingJson
 * @return the payload
 */
- (NSDictionary *) getAsDictionary;

/**
 * Returns a String description of the internal dictionary
 * @return the dictionary description
 */
- (NSString *) description;

@end
