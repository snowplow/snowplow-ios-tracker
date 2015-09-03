//
//  SPTracker.h
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

@class SPEmitter;
@class SPPayload;
@class SPSubject;
@class SPSession;

@protocol SPTrackerBuilder <NSObject>

- (void) setEmitter:(SPEmitter *)emitter;
- (void) setSubject:(SPSubject *)subject;
- (void) setAppId:(NSString *)appId;
- (void) setBase64Encoded:(BOOL)base64Encoded;
- (void) setTrackerNamespace:(NSString *)trackerNamespace;
- (void) setSessionContext:(BOOL)sessionContext;
- (void) setForegroundTimeout:(NSInteger)foregroundTimeout;
- (void) setBackgroundTimeout:(NSInteger)backgroundTimeout;
- (void) setCheckInterval:(NSInteger)checkInterval;

@end

@interface SPTracker : NSObject <SPTrackerBuilder>

@property (readonly, nonatomic, retain) SPEmitter * emitter;
@property (readonly, nonatomic, retain) SPSubject * subject;
@property (readonly, nonatomic, retain) NSString *  appId;
@property (readonly, nonatomic, retain) NSString *  trackerNamespace;
@property (readonly, nonatomic)         BOOL        base64Encoded;

/**
 * Builds the Tracker using a build block of functions.
 */
+ (instancetype) build:(void(^)(id<SPTrackerBuilder>builder))buildBlock;

/**
 *  Initializes a newly allocated SnowplowTracker.
 *  @return A SnowplowTracker instance.
 */
- (id) init;

/**
 * Pauses all event tracking, storage and session checking.
 */
- (void) pauseEventTracking;

/**
 * Resumes all event tracking and restarts the session checking.
 */
- (void) resumeEventTracking;

/**
 * Returns the current session index count
 * @return a count of sessions
 */
- (NSInteger) getSessionIndex;

/**
 * Returns whether the application is in the background or foreground
 * @return boolean truth of application location
 */
- (BOOL) getInBackground;

/**
 * Returns whether the Tracker is currently collecting data.
 * @return the boolean state of the tracker (on/off)
 */
- (BOOL) getIsTracking;

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
- (SPPayload *) trackEcommerceTransactionItem:(NSString *)orderId
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
- (SPPayload *) trackEcommerceTransactionItem:(NSString *)orderId
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
- (SPPayload *) trackEcommerceTransactionItem:(NSString *)orderId
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
- (SPPayload *) trackEcommerceTransactionItem:(NSString *)orderId
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

/**
 *  A tracker for User Timings.
 *  @param category Categorizing timing variables into logical groups (e.g API calls, asset loading)
 *  @param variable Identify the timing being recorded
 *  @param time The number of milliseconds in elapsed time to report
 *  @param label Optional description of this timing
 */
- (void) trackTimingWithCategory:(NSString *)category
                        variable:(NSString *)variable
                          timing:(NSUInteger)timing
                           label:(NSString *)label;

/**
 *  A tracker for User Timings.
 *  @param category Categorizing timing variables into logical groups (e.g API calls, asset loading)
 *  @param variable Identify the timing being recorded
 *  @param time The number of milliseconds in elapsed time to report
 *  @param label Optional description of this timing
 *  @param context An array of custom context for the event
 */
- (void) trackTimingWithCategory:(NSString *)category
                        variable:(NSString *)variable
                          timing:(NSUInteger)timing
                           label:(NSString *)label
                         context:(NSMutableArray *)context;

/**
 *  A tracker for User Timings.
 *  @param category Categorizing timing variables into logical groups (e.g API calls, asset loading)
 *  @param variable Identify the timing being recorded
 *  @param time The number of milliseconds in elapsed time to report
 *  @param label Optional description of this timing
 *  @param timestamp Optional user provided timestamp
 */
- (void) trackTimingWithCategory:(NSString *)category
                        variable:(NSString *)variable
                          timing:(NSUInteger)timing
                           label:(NSString *)label
                       timestamp:(double)timestamp;

/**
 *  A tracker for User Timings.
 *  @param category Categorizing timing variables into logical groups (e.g API calls, asset loading)
 *  @param variable Identify the timing being recorded
 *  @param time The number of milliseconds in elapsed time to report
 *  @param label Optional description of this timing
 *  @param context An array of custom context for the event
 *  @param timestamp Optional user provided timestamp
 */
- (void) trackTimingWithCategory:(NSString *)category
                        variable:(NSString *)variable
                          timing:(NSUInteger)timing
                           label:(NSString *)label
                         context:(NSMutableArray *)context
                       timestamp:(double)timestamp;

@end
