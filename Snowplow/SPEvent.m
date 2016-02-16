//
//  SPEvent.m
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

#import "Snowplow.h"
#import "SPEvent.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

// Base Event

@implementation SPEvent

- (id) init {
    self = [super init];
    if (self) {
        _timestamp = [SPUtilities getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
        _eventId = [SPUtilities getEventId];
    }
    return self;
}

// --- Builder Methods

- (void) setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
}

- (void) setContexts:(NSMutableArray *)contexts {
    for (NSObject * sdj in contexts) {
        [SPUtilities checkArgument:([sdj isKindOfClass:[SPSelfDescribingJson class]])
                       withMessage:@"All contexts must be SelfDescribingJson objects."];
    }
    _contexts = contexts;
}

- (void) setEventId:(NSString *)eventId {
    _eventId = eventId;
}

// --- Public Methods

- (NSMutableArray *) getContexts {
    return [NSMutableArray arrayWithArray:_contexts];
}

- (NSInteger) getTimestamp {
    return _timestamp;
}

- (NSString *) getEventId {
    return _eventId;
}

- (SPPayload *) addDefaultParamsToPayload:(SPPayload *)pb {
    [pb addValueToPayload:[NSString stringWithFormat:@"%@", [@(_timestamp) stringValue]] forKey:kSPTimestamp];
    [pb addValueToPayload:_eventId forKey:kSPEid];
    return pb;
}

- (void) basePreconditions {
    [SPUtilities checkArgument:(_contexts != nil) withMessage:@"Contexts cannot be nil."];
    [SPUtilities checkArgument:([_eventId length] != 0) withMessage:@"EventID cannot be nil or empty."];
}

@end

// PageView Event

@implementation SPPageView {
    NSString * _pageUrl;
    NSString * _pageTitle;
    NSString * _referrer;
}

+ (instancetype) build:(void(^)(id<SPPageViewBuilder>builder))buildBlock {
    SPPageView* event = [SPPageView new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_pageUrl length] != 0) withMessage:@"PageURL cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setPageUrl:(NSString *)pageUrl {
    _pageUrl = pageUrl;
}

- (void) setPageTitle:(NSString *)pageTitle {
    _pageTitle = pageTitle;
}

- (void) setReferrer:(NSString *)referrer {
    _referrer = referrer;
}

// --- Public Methods

- (SPPayload *) getPayload {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventPageView forKey:kSPEvent];
    [pb addValueToPayload:_pageUrl forKey:kSPPageUrl];
    [pb addValueToPayload:_pageTitle forKey:kSPPageTitle];
    [pb addValueToPayload:_referrer forKey:kSPPageRefr];
    return [self addDefaultParamsToPayload:pb];
}

@end

// Structured Event

@implementation SPStructured {
    NSString * _category;
    NSString * _action;
    NSString * _label;
    NSString * _property;
    NSNumber * _value;
}

+ (instancetype) build:(void(^)(id<SPStructuredBuilder>builder))buildBlock {
    SPStructured* event = [SPStructured new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category cannot be nil or empty."];
    [SPUtilities checkArgument:([_action length] != 0) withMessage:@"Action cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setCategory:(NSString *)category {
    _category = category;
}

- (void) setAction:(NSString *)action {
    _action = action;
}

- (void) setLabel:(NSString *)label {
    _label = label;
}

- (void) setProperty:(NSString *)property {
    _property = property;
}

- (void) setValue:(double)value {
    _value = [NSNumber numberWithDouble:value];
}

// --- Public Methods

- (SPPayload *) getPayload {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventStructured forKey:kSPEvent];
    [pb addValueToPayload:_category forKey:kSPStuctCategory];
    [pb addValueToPayload:_action forKey:kSPStuctAction];
    [pb addValueToPayload:_label forKey:kSPStuctLabel];
    [pb addValueToPayload:_property forKey:kSPStuctProperty];
    [pb addValueToPayload:[NSString stringWithFormat:@"%g", [_value doubleValue]] forKey:kSPStuctValue];
    return [self addDefaultParamsToPayload:pb];
}

@end

// Unstructured Event

@implementation SPUnstructured {
    SPSelfDescribingJson * _eventData;
}

+ (instancetype) build:(void(^)(id<SPUnstructuredBuilder>builder))buildBlock {
    SPUnstructured* event = [SPUnstructured new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_eventData != nil) withMessage:@"EventData cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setEventData:(SPSelfDescribingJson *)eventData {
    _eventData = eventData;
}

// --- Public Methods

- (SPPayload *) getPayloadWithEncoding:(BOOL)encoding {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventUnstructured forKey:kSPEvent];
    
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:kSPUnstructSchema
                                                        andSelfDescribingJson:_eventData];
    
    [pb addDictionaryToPayload:[sdj getAsDictionary]
                 base64Encoded:encoding
               typeWhenEncoded:kSPUnstructuredEncoded
            typeWhenNotEncoded:kSPUnstructured];
    return [self addDefaultParamsToPayload:pb];
}

@end

// ScreenView Event

@implementation SPScreenView {
    NSString * _name;
    NSString * _id;
}

+ (instancetype) build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock {
    SPScreenView* event = [SPScreenView new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_name length] != 0 || [_id length] != 0) withMessage:@"Name and ID cannot both be nil and empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setId:(NSString *)sId {
    _id = sId;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    if (_id != nil) {
        [event setObject:_id forKey:kSPSvId];
    }
    if (_name != nil) {
        [event setObject:_name forKey:kSPSvName];
    }
    
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPScreenViewSchema
                                                andData:event];
}

@end

// Timing Event

@implementation SPTiming {
    NSString * _category;
    NSString * _variable;
    NSNumber * _timing;
    NSString * _label;
}

+ (instancetype) build:(void(^)(id<SPTimingBuilder>builder))buildBlock {
    SPTiming* event = [SPTiming new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category cannot be nil or empty."];
    [SPUtilities checkArgument:([_variable length] != 0) withMessage:@"Variable cannot be nil or empty."];
    [SPUtilities checkArgument:(_timing != nil) withMessage:@"Timing cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setCategory:(NSString *)category {
    _category = category;
}

- (void) setVariable:(NSString *)variable {
    _variable = variable;
}

- (void) setTiming:(NSInteger)timing {
    _timing = [NSNumber numberWithLong:timing];
}

- (void) setLabel:(NSString *)label {
    _label = label;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_category forKey:kSPUtCategory];
    [event setObject:_variable forKey:kSPUtVariable];
    [event setObject:_timing forKey:kSPUtTiming];
    if (_label != nil) {
        [event setObject:_label forKey:kSPUtLabel];
    }
    
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPUserTimingsSchema
                                                andData:event];
}

@end

// Ecommerce Event

@implementation SPEcommerce {
    NSString * _orderId;
    NSNumber * _totalValue;
    NSString * _affiliation;
    NSNumber * _taxValue;
    NSNumber * _shipping;
    NSString * _city;
    NSString * _state;
    NSString * _country;
    NSString * _currency;
    NSArray *  _items;
}

+ (instancetype) build:(void(^)(id<SPEcommTransactionBuilder>builder))buildBlock {
    SPEcommerce* event = [SPEcommerce new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_orderId length] != 0) withMessage:@"OrderId cannot be nil or empty."];
    [SPUtilities checkArgument:(_items != nil) withMessage:@"Items cannot be nil."];
    [SPUtilities checkArgument:(_totalValue != nil) withMessage:@"TotalValue cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setOrderId:(NSString *)orderId {
    _orderId = orderId;
}

- (void) setTotalValue:(double)totalValue {
    _totalValue = [NSNumber numberWithDouble:totalValue];
}

- (void) setAffiliation:(NSString *)affiliation {
    _affiliation = affiliation;
}

- (void) setTaxValue:(double)taxValue {
    _taxValue =  [NSNumber numberWithDouble:taxValue];
}

- (void) setShipping:(double)shipping {
    _shipping =  [NSNumber numberWithDouble:shipping];
}

- (void) setCity:(NSString *)city {
    _city = city;
}

- (void) setState:(NSString *)state {
    _state = state;
}

- (void) setCountry:(NSString *)country {
    _country = country;
}

- (void) setCurrency:(NSString *)currency {
    _currency = currency;
}

- (void) setItems:(NSArray *)items {
    _items = items;
}

// --- Public Methods

- (SPPayload *) getPayload {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventEcomm forKey:kSPEvent];
    [pb addValueToPayload:_orderId forKey:kSPEcommId];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.02f", [_totalValue doubleValue]] forKey:kSPEcommTotal];
    [pb addValueToPayload:_affiliation forKey:kSPEcommAffiliation];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.02f", [_taxValue doubleValue]] forKey:kSPEcommTax];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.02f", [_shipping doubleValue]] forKey:kSPEcommShipping];
    [pb addValueToPayload:_city forKey:kSPEcommCity];
    [pb addValueToPayload:_state forKey:kSPEcommState];
    [pb addValueToPayload:_country forKey:kSPEcommCountry];
    [pb addValueToPayload:_currency forKey:kSPEcommCurrency];
    return [self addDefaultParamsToPayload:pb];
}

- (NSArray *) getItems {
    return _items;
}

@end

// Ecommerce Item Event

@implementation SPEcommerceItem {
    NSString * _itemId;
    NSString * _sku;
    NSNumber * _price;
    NSNumber * _quantity;
    NSString * _name;
    NSString * _category;
    NSString * _currency;
}

+ (instancetype) build:(void(^)(id<SPEcommTransactionItemBuilder>builder))buildBlock {
    SPEcommerceItem* event = [SPEcommerceItem new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_itemId length] != 0) withMessage:@"ItemId cannot be nil or empty."];
    [SPUtilities checkArgument:([_sku length] != 0) withMessage:@"SKU cannot be nil or empty."];
    [SPUtilities checkArgument:(_price != nil) withMessage:@"Price cannot be nil."];
    [SPUtilities checkArgument:(_quantity != nil) withMessage:@"Quantity cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setItemId:(NSString *)itemId {
    _itemId = itemId;
}

- (void) setSku:(NSString *)sku {
    _sku = sku;
}

- (void) setPrice:(double)price {
    _price = [NSNumber numberWithDouble:price];
}

- (void) setQuantity:(NSInteger)quantity {
    _quantity = [NSNumber numberWithLong:quantity];
}

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setCategory:(NSString *)category {
    _category = category;
}

- (void) setCurrency:(NSString *)currency {
    _currency = currency;
}

// --- Public Methods

- (SPPayload *) getPayload {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventEcommItem forKey:kSPEvent];
    [pb addValueToPayload:_itemId forKey:kSPEcommItemId];
    [pb addValueToPayload:_sku forKey:kSPEcommItemSku];
    [pb addValueToPayload:_name forKey:kSPEcommItemName];
    [pb addValueToPayload:_category forKey:kSPEcommItemCategory];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.02f", [_price doubleValue]] forKey:kSPEcommItemPrice];
    [pb addValueToPayload:[NSString stringWithFormat:@"%ld", [_quantity longValue]] forKey:kSPEcommItemQuantity];
    [pb addValueToPayload:_currency forKey:kSPEcommItemCurrency];
    return [self addDefaultParamsToPayload:pb];
}

@end
