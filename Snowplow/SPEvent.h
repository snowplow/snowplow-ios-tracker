//
//  SPEvent.h
//  Snowplow
//
//  Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
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
@class SPSelfDescribingJson;

// Builder Protocols : Defines all setter functions

@protocol SPEventBuilder <NSObject>
- (void) setTimestamp:(NSInteger)timestamp;
- (void) setContexts:(NSMutableArray *)contexts;
- (void) setEventId:(NSString *)eventId;
@end

@protocol SPPageViewBuilder <SPEventBuilder>
- (void) setPageUrl:(NSString *)pageUrl;
- (void) setPageTitle:(NSString *)pageTitle;
- (void) setReferrer:(NSString *)referrer;
@end

@protocol SPStructuredBuilder <SPEventBuilder>
- (void) setCategory:(NSString *)category;
- (void) setAction:(NSString *)action;
- (void) setLabel:(NSString *)label;
- (void) setProperty:(NSString *)property;
- (void) setValue:(double)value;
@end

@protocol SPUnstructuredBuilder <SPEventBuilder>
- (void) setEventData:(SPSelfDescribingJson *)eventData;
@end

@protocol SPScreenViewBuilder <SPEventBuilder>
- (void) setName:(NSString *)name;
- (void) setId:(NSString *)sId;
@end

@protocol SPTimingBuilder <SPEventBuilder>
- (void) setCategory:(NSString *)category;
- (void) setVariable:(NSString *)variable;
- (void) setTiming:(NSInteger)timing;
- (void) setLabel:(NSString *)label;
@end

@protocol SPEcommTransactionBuilder <SPEventBuilder>
- (void) setOrderId:(NSString *)orderId;
- (void) setTotalValue:(double)totalValue;
- (void) setAffiliation:(NSString *)affiliation;
- (void) setTaxValue:(double)taxValue;
- (void) setShipping:(double)shipping;
- (void) setCity:(NSString *)city;
- (void) setState:(NSString *)state;
- (void) setCountry:(NSString *)country;
- (void) setCurrency:(NSString *)currency;
- (void) setItems:(NSArray *)items;
@end

@protocol SPEcommTransactionItemBuilder <SPEventBuilder>
- (void) setItemId:(NSString *)itemId;
- (void) setSku:(NSString *)sku;
- (void) setPrice:(double)price;
- (void) setQuantity:(NSInteger)quantity;
- (void) setName:(NSString *)name;
- (void) setCategory:(NSString *)category;
- (void) setCurrency:(NSString *)currency;
@end

// Base Event

@interface SPEvent : NSObject <SPEventBuilder>

@property (nonatomic, readwrite) NSInteger timestamp;
@property (nonatomic, readwrite, retain) NSMutableArray* contexts;
@property (nonatomic, readwrite, retain) NSString * eventId;

- (NSMutableArray *) getContexts;
- (NSInteger) getTimestamp;
- (NSString *) getEventId;
- (SPPayload *) addDefaultParamsToPayload:(SPPayload *)pb;
@end

// PageView Event

@interface SPPageView : SPEvent <SPPageViewBuilder>
+ (instancetype) build:(void(^)(id<SPPageViewBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
@end

// Structured Event

@interface SPStructured : SPEvent <SPStructuredBuilder>
+ (instancetype) build:(void(^)(id<SPStructuredBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
@end

// Unstructured Event

@interface SPUnstructured : SPEvent <SPUnstructuredBuilder>
+ (instancetype) build:(void(^)(id<SPUnstructuredBuilder>builder))buildBlock;
- (SPPayload *) getPayloadWithEncoding:(BOOL)encoding;
@end

// ScreenView Event

@interface SPScreenView : SPEvent <SPScreenViewBuilder>
+ (instancetype) build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

// Timing Event

@interface SPTiming : SPEvent <SPTimingBuilder>
+ (instancetype) build:(void(^)(id<SPTimingBuilder>builder))buildBlock;
- (SPSelfDescribingJson *) getPayload;
@end

// Ecommerce Event

@interface SPEcommerce : SPEvent <SPEcommTransactionBuilder>
+ (instancetype) build:(void(^)(id<SPEcommTransactionBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
- (NSArray *) getItems;
@end


// Ecommerce Item Event

@interface SPEcommerceItem : SPEvent <SPEcommTransactionItemBuilder>
+ (instancetype) build:(void(^)(id<SPEcommTransactionItemBuilder>builder))buildBlock;
- (SPPayload *) getPayload;
@end
