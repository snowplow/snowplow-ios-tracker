//
//  SnowplowTracker.h
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SnowplowRequest.h"

@interface SnowplowTracker : NSObject

extern NSString * const kSnowplowVendor;
extern Boolean const kDefaultEncodeBase64;
extern NSString * const kVersion;

@property (nonatomic) Boolean base64Encoded;
@property (nonatomic) NSString *trackerNamespace;
@property (nonatomic) SnowplowRequest *collector;
@property (nonatomic) NSMutableDictionary *standardData;
@property (nonatomic) NSString *schemaTag;
@property (nonatomic) NSString *contextSchema;
@property (nonatomic) NSString *unstructedEventSchema;

/**
 *  Initializes a newly allocated SnowplowTracker. All class properties default to nil, and require you to use setCollector, setNamespace, setAppId, setUserId. Using initUsingCollector:appId:base64Encoded:namespace is recommended.
 *  @return A SnowplowTracker instance.
 */
- (id) init;

/**
 *  Initializes a newly allocated SnowplowTracker with all the required properties to send events to it.
 *  @param collector A SnowplowRequest object that is initialized to send the events created by the SnowplowTracker.
 *  @param appId Your app ID
 *  @param base64encoded If true, all context data will be Base64 encoded before being added to the event.
 *  @param namespace Identifier for the tracker instance.
 *  @return A SnowplowTracker instance.
 */
- (id) initUsingCollector:(SnowplowRequest *)collector
                    appId:(NSString *)appId
            base64Encoded:(Boolean)encoded
                namespace:(NSString *)namespace_;

/**
 *  Sets the collector to the new SnowplowRequest passed to it.
 *  @param A correctly defined SnowplowRequest instance. Overrides original if set.
 */
- (void) setCollector:(SnowplowRequest *)collector;

/**
 *  Sets the namespace to the new string passed to it.
 *  @param A string of the new namespace to use. Overrides original if set.
 */
- (void) setNamespace:(NSString *)trackerNamespace;

/**
 *  Sets the app ID to the new string passed to it.
 *  @param A string of the new app ID to use. Overrides original if set.
 */
- (void) setAppId:(NSString *)appId;

/**
 *  Sets the user ID to the new string passed to it.
 *  @param A string of the new user ID to use. Overrides original if set.
 */
- (void) setUserId:(NSString *)userId;

/**
 *  Sets the schema tag to the new string passed to it. This is used to set the context schema in the event for self describing JSON.
 *  @param A string of the new namespace to be use.
 */
- (void) setSchemaTag:(NSString *)schema;

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
               context:(NSDictionary *)context
             timestamp:(double)timestamp;

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                      context:(NSDictionary *)context
                    timestamp:(double)timestamp;

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSDictionary *)context
                      timestamp:(double)timestamp;

- (void) trackEcommerceTransactionItem:(NSString *)orderId
                                   sku:(NSString *)sku
                                  name:(NSString *)name
                              category:(NSString *)category
                                 price:(float)price
                              quantity:(int)quantity
                              currency:(NSString *)currency
                               context:(NSDictionary *)context
                             timestamp:(double)timestamp;

- (void) trackEcommerceTransaction:(NSString *)orderId
                        totalValue:(float)totalValue
                       affiliation:(NSString *)affiliation
                          taxValue:(float)taxValue
                          shipping:(float)shipping
                              city:(NSString *)city
                             state:(NSString *)state
                           country:(NSString *)country
                          currency:(NSString *)currency
                             items:(NSDictionary *)items
                           context:(NSDictionary *)context
                         timestamp:(double)timestamp;

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSDictionary *)context
               timestamp:(double)timestamp;

@end
