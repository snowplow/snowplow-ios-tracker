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
#import "SnowplowEmitter.h"
#import "SnowplowPayload.h"

@interface SnowplowTracker : NSObject

@property (retain)              SnowplowEmitter *   collector;
@property (retain)              NSString *          appId;
@property (retain)              NSString *          trackerNamespace;
@property (nonatomic, retain)   NSString *          userId;

extern NSString * const kSnowplowVendor;
extern NSString * const kIglu;
extern Boolean    const kDefaultEncodeBase64;
extern NSString * const kVersion;

/**
 *  Initializes a newly allocated SnowplowTracker. All class properties default to nil, and require you to use setCollector, setNamespace, setAppId, setUserId. Using initUsingCollector:appId:base64Encoded:namespace is recommended.
 *  @return A SnowplowTracker instance.
 */
- (id) init;

/**
 *  Initializes a newly allocated SnowplowTracker with all the required properties to send events to it.
 *  @param collector_ A SnowplowEmitter object that is initialized to send the events created by the SnowplowTracker.
 *  @param appId_ Your app ID
 *  @param base64encoded If true, all context data will be Base64 encoded before being added to the event.
 *  @param namespace_ Identifier for the tracker instance.
 *  @return A SnowplowTracker instance.
 */
- (id) initWithCollector:(SnowplowEmitter *)collector_
                   appId:(NSString *)appId_
           base64Encoded:(Boolean)encoded
               namespace:(NSString *)namespace_;

/**
 *  Sets the schema tag to the new string passed to it. This is used to set the context schema in the event for self describing JSON.
 *  @param A string of the new namespace to be use.
 */
- (void) setSchemaTag:(NSString *)schema;

/**
 *  Lets you track a page view using all the variables entered here.
 *  @param pageUrl The URL of the page
 *  @param pageTitle The title of page we're tracking
 *  @param referrer Referrerr of the page
 */
- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer;

/**
 *  Lets you track a page view using all the variables entered here.
 *  @param pageUrl The URL of the page
 *  @param pageTitle The title of page we're tracking
 *  @param referrer Referrerr of the page
 *  @param context An array of custom context for the event
 */
- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
               context:(NSMutableArray *)context;

/**
 *  Lets you track a page view using all the variables entered here.
 *  @param pageUrl The URL of the page
 *  @param pageTitle The title of page we're tracking
 *  @param referrer Referrerr of the page
 *  @param timestamp Optional user-provided timestamp.
 */
- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
             timestamp:(double)timestamp;

/**
 *  Lets you track a page view using all the variables entered here.
 *  @param pageUrl The URL of the page
 *  @param pageTitle The title of page we're tracking
 *  @param referrer Referrerr of the page
 *  @param context An array of custom context for the event
 *  @param timestamp Optional user-provided timestamp.
 */
- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
               context:(NSMutableArray *)context
             timestamp:(double)timestamp;

/**
 *  A structured event is a basic event using the paramaters passed to it.
 *  @param category Category of the event
 *  @param action The event itself
 *  @param label Refer to the object the action is performed on
 *  @param property Property associated with either the action or the object
 *  @param value A value associated with the user action
 */
- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value;

/**
 *  A structured event is a basic event using the paramaters passed to it.
 *  @param category Category of the event
 *  @param action The event itself
 *  @param label Refer to the object the action is performed on
 *  @param property Property associated with either the action or the object
 *  @param value A value associated with the user action
 *  @param context An array of custom context for the event
 */
- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                      context:(NSMutableArray *)context;

/**
 *  A structured event is a basic event using the paramaters passed to it.
 *  @param category Category of the event
 *  @param action The event itself
 *  @param label Refer to the object the action is performed on
 *  @param property Property associated with either the action or the object
 *  @param value A value associated with the user action
 *  @param timestamp Optional user-provided timestamp.
 */
- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                    timestamp:(double)timestamp;

/**
 *  A structured event is a basic event using the paramaters passed to it.
 *  @param category Category of the event
 *  @param action The event itself
 *  @param label Refer to the object the action is performed on
 *  @param property Property associated with either the action or the object
 *  @param value A value associated with the user action
 *  @param context An array of custom context for the event
 *  @param timestamp Optional user-provided timestamp.
 */
- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                      context:(NSMutableArray *)context
                    timestamp:(double)timestamp;

/**
 *  An unstructured event allows you to create an event custom structured to your requirements
 *  @param eventJson A dictionary of event data.
 */
- (void) trackUnstructuredEvent:(NSDictionary *)eventJson;

/**
 *  An unstructured event allows you to create an event custom structured to your requirements
 *  @param eventJson A dictionary of event data.
 *  @param timestamp Optional user provided timestamp.
 */
- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                      timestamp:(double)timestamp;

/**
 *  An unstructured event allows you to create an event custom structured to your requirements
 *  @param eventJson A dictionary of event data.
 *  @param context An array of custom context for the event
 */
- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSMutableArray *)context;

/**
 *  An unstructured event allows you to create an event custom structured to your requirements
 *  @param eventJson A dictionary of event data.
 *  @param context An array of custom context for the event
 *  @param timestamp Optional user provided timestamp.
 */
- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSMutableArray *)context
                      timestamp:(double)timestamp;

/**
 *  An internal method to be called by trackEcommerceTransaction.
 *  @param orderId Order ID
 *  @param sku Item SKU
 *  @param name Item name
 *  @param category Item category
 *  @param price Item price
 *  @param quantity Item quantity
 *  @param currency The currency the price is expressed in
 */
- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                                sku:(NSString *)sku
                                               name:(NSString *)name
                                           category:(NSString *)category
                                              price:(float)price
                                           quantity:(int)quantity
                                           currency:(NSString *)currency;

/**
 *  An internal method to be called by trackEcommerceTransaction.
 *  @param orderId Order ID
 *  @param sku Item SKU
 *  @param name Item name
 *  @param category Item category
 *  @param price Item price
 *  @param quantity Item quantity
 *  @param currency The currency the price is expressed in
 *  @param context An array of custom context for the event
 */
- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                                sku:(NSString *)sku
                                               name:(NSString *)name
                                           category:(NSString *)category
                                              price:(float)price
                                           quantity:(int)quantity
                                           currency:(NSString *)currency
                                            context:(NSMutableArray *)context;

/**
 *  An internal method to be called by trackEcommerceTransaction.
 *  @param orderId Order ID
 *  @param sku Item SKU
 *  @param name Item name
 *  @param category Item category
 *  @param price Item price
 *  @param quantity Item quantity
 *  @param currency The currency the price is expressed in
 *  @param timestamp Optional user provided timestamp.
 */
- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                                sku:(NSString *)sku
                                               name:(NSString *)name
                                           category:(NSString *)category
                                              price:(float)price
                                           quantity:(int)quantity
                                           currency:(NSString *)currency
                                          timestamp:(double)timestamp;

/**
 *  An internal method to be called by trackEcommerceTransaction.
 *  @param orderId Order ID
 *  @param sku Item SKU
 *  @param name Item name
 *  @param category Item category
 *  @param price Item price
 *  @param quantity Item quantity
 *  @param currency The currency the price is expressed in
 *  @param context An array of custom context for the event
 *  @param timestamp Optional user provided timestamp.
 */
- (SnowplowPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                                sku:(NSString *)sku
                                               name:(NSString *)name
                                           category:(NSString *)category
                                              price:(float)price
                                           quantity:(int)quantity
                                           currency:(NSString *)currency
                                            context:(NSMutableArray *)context
                                          timestamp:(double)timestamp;

/**
 *  A tracker for e-commerce transactions
 *  @param orderId ID of the e-commerce transaction
 *  @param totalValue Total transaction value
 *  @param affiliation Transaction affiliation
 *  @param taxValue Transaction tax value
 *  @param shipping Delivery cost charged
 *  @param city Delivery address city
 *  @param state Delivery address state
 *  @param country Delivery address country
 *  @param currency The currency the price is expressed in
 *  @param items The items in the transaction. The structure is up to you.
 */
- (void) trackEcommerceTransaction:(NSString *)orderId
                        totalValue:(float)totalValue
                       affiliation:(NSString *)affiliation
                          taxValue:(float)taxValue
                          shipping:(float)shipping
                              city:(NSString *)city
                             state:(NSString *)state
                           country:(NSString *)country
                          currency:(NSString *)currency
                             items:(NSArray *)items;

/**
 *  A tracker for e-commerce transactions
 *  @param orderId ID of the e-commerce transaction
 *  @param totalValue Total transaction value
 *  @param affiliation Transaction affiliation
 *  @param taxValue Transaction tax value
 *  @param shipping Delivery cost charged
 *  @param city Delivery address city
 *  @param state Delivery address state
 *  @param country Delivery address country
 *  @param currency The currency the price is expressed in
 *  @param items The items in the transaction. The structure is up to you.
 *  @param context An array of custom context for the event
 */
- (void) trackEcommerceTransaction:(NSString *)orderId
                        totalValue:(float)totalValue
                       affiliation:(NSString *)affiliation
                          taxValue:(float)taxValue
                          shipping:(float)shipping
                              city:(NSString *)city
                             state:(NSString *)state
                           country:(NSString *)country
                          currency:(NSString *)currency
                             items:(NSArray *)items
                           context:(NSMutableArray *)context;

/**
 *  A tracker for e-commerce transactions
 *  @param orderId ID of the e-commerce transaction
 *  @param totalValue Total transaction value
 *  @param affiliation Transaction affiliation
 *  @param taxValue Transaction tax value
 *  @param shipping Delivery cost charged
 *  @param city Delivery address city
 *  @param state Delivery address state
 *  @param country Delivery address country
 *  @param currency The currency the price is expressed in
 *  @param items The items in the transaction. The structure is up to you.
 *  @param timestamp Optional user provided timestamp.
 */
- (void) trackEcommerceTransaction:(NSString *)orderId
                        totalValue:(float)totalValue
                       affiliation:(NSString *)affiliation
                          taxValue:(float)taxValue
                          shipping:(float)shipping
                              city:(NSString *)city
                             state:(NSString *)state
                           country:(NSString *)country
                          currency:(NSString *)currency
                             items:(NSArray *)items
                         timestamp:(double)timestamp;

/**
 *  A tracker for e-commerce transactions
 *  @param orderId ID of the e-commerce transaction
 *  @param totalValue Total transaction value
 *  @param affiliation Transaction affiliation
 *  @param taxValue Transaction tax value
 *  @param shipping Delivery cost charged
 *  @param city Delivery address city
 *  @param state Delivery address state
 *  @param country Delivery address country
 *  @param currency The currency the price is expressed in
 *  @param items The items in the transaction. The structure is up to you.
 *  @param context An array of custom context for the event
 *  @param timestamp Optional user provided timestamp.
 */
- (void) trackEcommerceTransaction:(NSString *)orderId
                        totalValue:(float)totalValue
                       affiliation:(NSString *)affiliation
                          taxValue:(float)taxValue
                          shipping:(float)shipping
                              city:(NSString *)city
                             state:(NSString *)state
                           country:(NSString *)country
                          currency:(NSString *)currency
                             items:(NSArray *)items
                           context:(NSMutableArray *)context
                         timestamp:(double)timestamp;

/**
 *  A tracker for Storyboards, Views, and Windows.
 *  @param name The name of the screen view event
 *  @param id_ Screen view ID
 */
- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_;

/**
 *  A tracker for Storyboards, Views, and Windows.
 *  @param name The name of the screen view event
 *  @param id_ Screen view ID
 *  @param context An array of custom context for the event
 */
- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSMutableArray *)context;

/**
 *  A tracker for Storyboards, Views, and Windows.
 *  @param name The name of the screen view event
 *  @param id_ Screen view ID
 *  @param timestamp Optional user provided timestamp.
 */
- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
               timestamp:(double)timestamp;

/**
 *  A tracker for Storyboards, Views, and Windows.
 *  @param name The name of the screen view event
 *  @param id_ Screen view ID
 *  @param context An array of custom context for the event
 *  @param timestamp Optional user provided timestamp.
 */
- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSMutableArray *)context
               timestamp:(double)timestamp;

@end
