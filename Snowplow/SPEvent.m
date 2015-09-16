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
#import "SPUtils.h"
#import "SPPayload.h"

// PageView Event

@implementation SPPageView {
    NSString *       _pageUrl;
    NSString *       _pageTitle;
    NSString *       _referrer;
    NSInteger        _timestamp;
    NSMutableArray * _contexts;
}

+ (instancetype) build:(void(^)(id<SPPageViewBuilder>builder))buildBlock {
    SPPageView* event = [SPPageView new];
    if (buildBlock) { buildBlock(event); }
    return event;
}

- (id) init {
    self = [super init];
    if (self) {
        _timestamp = [SPUtils getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
    }
    return self;
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

- (void) setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
}

- (void) setContexts:(NSMutableArray *)contexts {
    _contexts = contexts;
}

// --- Public Methods

- (SPPayload *) getPayload {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventPageView forKey:kSPEvent];
    [pb addValueToPayload:_pageUrl forKey:kSPPageUrl];
    [pb addValueToPayload:_pageTitle forKey:kSPPageTitle];
    [pb addValueToPayload:_referrer forKey:kSPPageRefr];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.0ld", (long)_timestamp] forKey:kSPTimestamp];
    return pb;
}

- (NSMutableArray *) getContexts {
    return _contexts;
}

@end

// Structured Event

@implementation SPStructured {
    NSString *       _category;
    NSString *       _action;
    NSString *       _label;
    NSString *       _property;
    double           _value;
    NSInteger        _timestamp;
    NSMutableArray * _contexts;
}

+ (instancetype) build:(void(^)(id<SPStructuredBuilder>builder))buildBlock {
    SPStructured* event = [SPStructured new];
    if (buildBlock) { buildBlock(event); }
    return event;
}

- (id) init {
    self = [super init];
    if (self) {
        _timestamp = [SPUtils getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
    }
    return self;
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
    _value = value;
}

- (void) setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
}

- (void) setContexts:(NSMutableArray *)contexts {
    _contexts = contexts;
}

// --- Public Methods

- (SPPayload *) getPayload {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventStructured forKey:kSPEvent];
    [pb addValueToPayload:_category forKey:kSPStuctCategory];
    [pb addValueToPayload:_action forKey:kSPStuctAction];
    [pb addValueToPayload:_label forKey:kSPStuctLabel];
    [pb addValueToPayload:_property forKey:kSPStuctProperty];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", _value] forKey:kSPStuctValue];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.0ld", (long)_timestamp] forKey:kSPTimestamp];
    return pb;
}

- (NSMutableArray *) getContexts {
    return _contexts;
}

@end

// Unstructured Event

@implementation SPUnstructured {
    NSDictionary *   _eventData;
    NSInteger        _timestamp;
    NSMutableArray * _contexts;
}

+ (instancetype) build:(void(^)(id<SPUnstructuredBuilder>builder))buildBlock {
    SPUnstructured* event = [SPUnstructured new];
    if (buildBlock) { buildBlock(event); }
    return event;
}

- (id) init {
    self = [super init];
    if (self) {
        _timestamp = [SPUtils getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
    }
    return self;
}

// --- Builder Methods

- (void) setEventData:(NSDictionary *)eventData {
    _eventData = eventData;
}

- (void) setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
}

- (void) setContexts:(NSMutableArray *)contexts {
    _contexts = contexts;
}

// --- Public Methods

- (SPPayload *) getPayloadWithEncoding:(BOOL)encoding {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventUnstructured forKey:kSPEvent];
    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                              kSPUnstructSchema, kSPSchema,
                              _eventData, kSPData, nil];
    [pb addDictionaryToPayload:envelope
                 base64Encoded:encoding
               typeWhenEncoded:kSPUnstructuredEncoded
            typeWhenNotEncoded:kSPUnstructured];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.0ld", (long)_timestamp] forKey:kSPTimestamp];
    return pb;
}

- (NSMutableArray *) getContexts {
    return _contexts;
}

@end

// ScreenView Event

@implementation SPScreenView {
    NSString *       _name;
    NSString *       _id;
    NSInteger        _timestamp;
    NSMutableArray * _contexts;
}

+ (instancetype) build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock {
    SPScreenView* event = [SPScreenView new];
    if (buildBlock) { buildBlock(event); }
    return event;
}

- (id) init {
    self = [super init];
    if (self) {
        _timestamp = [SPUtils getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
    }
    return self;
}

// --- Builder Methods

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setId:(NSString *)sId {
    _id = sId;
}

- (void) setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
}

- (void) setContexts:(NSMutableArray *)contexts {
    _contexts = contexts;
}

// --- Public Methods

- (NSDictionary *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    if (_id != nil) {
        [event setObject:_id forKey:kSPSvId];
    }
    if (_name != nil) {
        [event setObject:_name forKey:kSPSvName];
    }
    NSDictionary * eventJson = [NSDictionary dictionaryWithObjectsAndKeys:
                               kSPScreenViewSchema, kSPSchema,
                               event, kSPData, nil];
    return eventJson;
}

- (NSMutableArray *) getContexts {
    return _contexts;
}

- (NSInteger) getTimestamp {
    return _timestamp;
}

@end

// Timing Event

@implementation SPTiming {
    NSString *       _category;
    NSString *       _variable;
    NSInteger        _timing;
    NSString *       _label;
    NSInteger        _timestamp;
    NSMutableArray * _contexts;
}

+ (instancetype) build:(void(^)(id<SPTimingBuilder>builder))buildBlock {
    SPTiming* event = [SPTiming new];
    if (buildBlock) { buildBlock(event); }
    return event;
}

- (id) init {
    self = [super init];
    if (self) {
        _timestamp = [SPUtils getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
    }
    return self;
}

// --- Builder Methods

- (void) setCategory:(NSString *)category {
    _category = category;
}

- (void) setVariable:(NSString *)variable {
    _variable = variable;
}

- (void) setTiming:(NSInteger)timing {
    _timing = timing;
}

- (void) setLabel:(NSString *)label {
    _label = label;
}

- (void) setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
}

- (void) setContexts:(NSMutableArray *)contexts {
    _contexts = contexts;
}

// --- Public Methods

- (NSDictionary *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_category forKey:kSPUtCategory];
    [event setObject:_variable forKey:kSPUtVariable];
    [event setObject:[NSNumber numberWithInteger:_timing] forKey:kSPUtTiming];
    if (_label != nil) {
        [event setObject:_label forKey:kSPUtLabel];
    }
    
    NSDictionary *eventJson = [NSDictionary dictionaryWithObjectsAndKeys:
                               kSPUserTimingsSchema, kSPSchema,
                               event, kSPData, nil];
    return eventJson;
}

- (NSMutableArray *) getContexts {
    return _contexts;
}

- (NSInteger) getTimestamp {
    return _timestamp;
}

@end

// Ecommerce Event

@implementation SPEcommerce {
    NSString *       _orderId;
    double           _totalValue;
    NSString *       _affiliation;
    double           _taxValue;
    double           _shipping;
    NSString *       _city;
    NSString *       _state;
    NSString *       _country;
    NSString *       _currency;
    NSArray *        _items;
    NSInteger        _timestamp;
    NSMutableArray * _contexts;
}

+ (instancetype) build:(void(^)(id<SPEcommTransactionBuilder>builder))buildBlock {
    SPEcommerce* event = [SPEcommerce new];
    if (buildBlock) { buildBlock(event); }
    return event;
}

- (id) init {
    self = [super init];
    if (self) {
        _timestamp = [SPUtils getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
    }
    return self;
}

// --- Builder Methods

- (void) setOrderId:(NSString *)orderId {
    _orderId = orderId;
}

- (void) setTotalValue:(double)totalValue {
    _totalValue = totalValue;
}

- (void) setAffiliation:(NSString *)affiliation {
    _affiliation = affiliation;
}

- (void) setTaxValue:(double)taxValue {
    _taxValue = taxValue;
}

- (void) setShipping:(double)shipping {
    _shipping = shipping;
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

- (void) setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
}

- (void) setContexts:(NSMutableArray *)contexts {
    _contexts = contexts;
}

// --- Public Methods

- (SPPayload *) getPayload {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventEcomm forKey:kSPEvent];
    [pb addValueToPayload:_orderId forKey:kSPEcommId];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", _totalValue] forKey:kSPEcommTotal];
    [pb addValueToPayload:_affiliation forKey:kSPEcommAffiliation];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", _taxValue] forKey:kSPEcommTax];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", _shipping] forKey:kSPEcommShipping];
    [pb addValueToPayload:_city forKey:kSPEcommCity];
    [pb addValueToPayload:_state forKey:kSPEcommState];
    [pb addValueToPayload:_country forKey:kSPEcommCountry];
    [pb addValueToPayload:_currency forKey:kSPEcommCurrency];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.0ld", (long)_timestamp] forKey:kSPTimestamp];
    return pb;
}

- (NSMutableArray *) getContexts {
    return _contexts;
}

- (NSInteger) getTimestamp {
    return _timestamp;
}

- (NSArray *) getItems {
    return _items;
}

@end

// Ecommerce Item Event

@implementation SPEcommerceItem {
    NSString *       _itemId;
    NSString *       _sku;
    double           _price;
    NSInteger        _quantity;
    NSString *       _name;
    NSString *       _category;
    NSString *       _currency;
    NSInteger        _timestamp;
    NSMutableArray * _contexts;
}

+ (instancetype) build:(void(^)(id<SPEcommTransactionItemBuilder>builder))buildBlock {
    SPEcommerceItem* event = [SPEcommerceItem new];
    if (buildBlock) { buildBlock(event); }
    return event;
}

- (id) init {
    self = [super init];
    if (self) {
        _timestamp = [SPUtils getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
    }
    return self;
}

// --- Builder Methods

- (void) setItemId:(NSString *)itemId {
    _itemId = itemId;
}

- (void) setSku:(NSString *)sku {
    _sku = sku;
}

- (void) setPrice:(double)price {
    _price = price;
}

- (void) setQuantity:(NSInteger)quantity {
    _quantity = quantity;
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

- (void) setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
}

- (void) setContexts:(NSMutableArray *)contexts {
    _contexts = contexts;
}

// --- Public Methods

- (SPPayload *) getPayloadWithTimestamp:(NSInteger)tstamp {
    SPPayload *pb = [[SPPayload alloc] init];
    [pb addValueToPayload:kSPEventEcommItem forKey:kSPEvent];
    [pb addValueToPayload:_itemId forKey:kSPEcommItemId];
    [pb addValueToPayload:_sku forKey:kSPEcommItemSku];
    [pb addValueToPayload:_name forKey:kSPEcommItemName];
    [pb addValueToPayload:_category forKey:kSPEcommItemCategory];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", _price] forKey:kSPEcommItemPrice];
    [pb addValueToPayload:[NSString stringWithFormat:@"%ld", (long)_quantity] forKey:kSPEcommItemQuantity];
    [pb addValueToPayload:_currency forKey:kSPEcommItemCurrency];
    [pb addValueToPayload:[NSString stringWithFormat:@"%.0ld", (long)tstamp] forKey:kSPTimestamp];
    return pb;
}

- (NSMutableArray *) getContexts {
    return _contexts;
}

@end
