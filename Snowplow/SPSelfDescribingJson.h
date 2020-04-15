//
//  SPSelfDescribingJson.h
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SPPayload;

/*!
 @class SPSelfDescribingJson
 @brief The class that represents self-describing JSONs.

 This class holds the information of a self-describing JSON.

 @see SPPayload
 */
@interface SPSelfDescribingJson : NSObject

/// the schema URI for this self-describing JSON.
@property (nonatomic) NSString *schema;
/// Data of the self-describing JSON.
@property (nonatomic, readonly) NSObject *data;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 @brief Initializes a newly allocated SPSelfDescribingJson.

 @param schema A valid schema string.
 @param data Data to set for data field of the self-describing JSON, should be an NSDictionary.
 @return An SPSelfDescribingJson.
 */
- (instancetype)initWithSchema:(NSString *)schema andData:(NSObject *)data NS_DESIGNATED_INITIALIZER;

/*!
 @brief Initializes a newly allocated SPSelfDescribingJson.

 @param schema A valid schema string.
 @param data Payload to set for data field of the self-describing JSON.
 @return An SPSelfDescribingJson.
 */
- (instancetype)initWithSchema:(NSString *)schema andPayload:(SPPayload *)data;

/*!
 @brief Initializes a newly allocated SPSelfDescribingJson.

 @param schema A valid schema URI.
 @param data Self-describing JSON to set for data field of the self-describing JSON.
 @return An SPSelfDescribingJson.
 */
- (instancetype)initWithSchema:(NSString *)schema andSelfDescribingJson:(SPSelfDescribingJson *)data;

/*!
 @brief Sets the data field of the self-describing JSON.

 @param data An NSObject to be nested into the data.
 */
- (void) setDataWithObject:(NSObject *)data;

/*!
 @brief Sets the data field of the self-describing JSON.

 @param data An SPPayload to be nested into the data.
 */
- (void) setDataWithPayload:(SPPayload *)data;

/*!
 @brief Sets the data field of the self-describing JSON.

 @param data A self-describing JSON to be nested into the data.
 */
- (void) setDataWithSelfDescribingJson:(SPSelfDescribingJson *)data;

/*!
 @brief Returns the internal NSDictionary of the self-describing JSON.

 @return The self-describing JSON as an NSDictionary.
 */
- (NSDictionary<NSString *, NSObject *> *) getAsDictionary;

/*!
 @brief Returns a string description of the internal dictionary.

 @return The description of the dictionary.
 */
- (NSString *) description;

@end
