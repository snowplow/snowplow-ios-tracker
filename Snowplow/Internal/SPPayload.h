//
//  SPPayload.h
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

@interface SPPayload : NSObject

@property (nonatomic) BOOL allowDiagnostic;

/**
 *  Initializes a newly allocated SPPayload
 *  @return A SnowplowPayload.
 */
- (id) init;

/**
 *  Initializes a newly allocated SPPayload with an existing object of type NSDictionary.
 *  @param dict An object of NSDictionary.
 *  @return A SnowplowPayload.
 */
- (id)initWithNSDictionary:(NSDictionary<NSString *, NSObject *> *)dict;

/**
 *  Adds a simple name-value pair into the SPPayload intance.
 *  @param value A NSString value
 *  @param key A key of type NSString
 */
- (void) addValueToPayload:(NSString *)value forKey:(NSString *)key;

/**
 *  Adds a dictionary of attributes to be appended into the SPPayload instance. It does NOT overwrite the existing data in the object.
 *  All attribute values must be NSString types to be added; all others are discarded.
 *  @param dict An object of NSDictionary.
 */
- (void)addDictionaryToPayload:(NSDictionary<NSString *, NSObject *> *)dict;

/**
 *  Adds a dictionary of attributes to be appended into the SPPayload instance. Gives you the option to Base64 encode the data before adding it into the object.
 *  @param json NSData of JSON-compatible data to be added.
 *  @param encode Boolean option to choose whether the JSON data should be encoded.
 *  @param typeEncoded If the data is to be encoded, the result will be a value of the key in typeEncoded.
 *  @param typeNotEncoded If the data is NOT going to be encoded, the result will be a value of the key in typeWhenNotEncoded.
 */
- (void) addJsonToPayload:(NSData *)json
            base64Encoded:(Boolean)encode
          typeWhenEncoded:(NSString *)typeEncoded
       typeWhenNotEncoded:(NSString *)typeNotEncoded;

/**
 *  Adds a JSON string of attributes to be appended into the SPPayload instance. Gives you the option to Base64 encode the data before adding it into the object. This method converts the string to NSData and uses the data with addJsonStringToPayload:base64Encoded:typeWhenEncoded:typeWhenNotEncoded:
 *  @param json NSData of JSON-compatible data to be added.
 *  @param encode Boolean option to choose whether the JSON data should be encoded.
 *  @param typeEncoded If the data is to be encoded, the result will be a value of the key in typeEncoded.
 *  @param typeNotEncoded If the data is NOT going to be encoded, the result will be a value of the key in typeWhenNotEncoded.
 */
- (void) addJsonStringToPayload:(NSString *)json
                  base64Encoded:(Boolean)encode
                typeWhenEncoded:(NSString *)typeEncoded
             typeWhenNotEncoded:(NSString *)typeNotEncoded;

/**
 *  Adds a dictionary of attributes to be appended into the SPPayload instance. Gives you the option to Base64 encode the data before adding it into the object. This method converts the dictionary to NSData and uses the data with addJsonStringToPayload:base64Encoded:typeWhenEncoded:typeWhenNotEncoded:
 *  @param json NSDictionary of JSON-compatible data to be added.
 *  @param encode Boolean option to choose whether the JSON data should be encoded.
 *  @param typeEncoded If the data is to be encoded, the result will be a value of the key in typeEncoded.
 *  @param typeNotEncoded If the data is NOT going to be encoded, the result will be a value of the key in typeWhenNotEncoded.
 */
- (void) addDictionaryToPayload:(NSDictionary<NSString *, NSObject *> *)json
                  base64Encoded:(Boolean)encode
                typeWhenEncoded:(NSString *)typeEncoded
             typeWhenNotEncoded:(NSString *)typeNotEncoded;

/**
 * Returns the payload of that particular SPPayload object.
 * @return NSDictionary of data in the object.
 */
- (NSDictionary<NSString *, NSObject *> *) getAsDictionary;

/**
 * Returns the byte size of a payload.
 * @return A long representing the byte size of the payload.
 */
- (NSUInteger)byteSize;

@end

