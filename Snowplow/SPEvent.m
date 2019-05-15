//
//  SPEvent.m
//  Snowplow
//
//  Copyright (c) 2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPEvent.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPScreenState.h"

NSString * stringWithSPScreenType(SPScreenType screenType) {
    NSArray * arr = @[
                      @"Default",
                      @"Navigation",
                      @"TabBar",
                      @"PageView",
                      @"SplitView",
                      @"PopoverPresentation",
                      @"Modal",
                      @"Combined"
                      ];
    return (NSString *)[arr objectAtIndex:screenType];
}

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

- (void) setTimestamp:(NSNumber *)timestamp {
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

- (NSNumber *) getTimestamp {
    return _timestamp;
}

- (NSString *) getEventId {
    return _eventId;
}

- (SPPayload *) addDefaultParamsToPayload:(SPPayload *)pb {
    [pb addValueToPayload:[NSString stringWithFormat:@"%lld", _timestamp.longLongValue] forKey:kSPTimestamp];
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
    [pb addValueToPayload:[NSString stringWithFormat:@"%.17g", [_value doubleValue]] forKey:kSPStuctValue];
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
    NSString * _type;
    NSString * _previousName;
    NSString * _previousId;
    NSString * _previousType;
    NSString * _transitionType;
}

+ (instancetype) build:(void(^)(id<SPScreenViewBuilder>builder))buildBlock {
    SPScreenView* event = [SPScreenView new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    if (!_id) {
        _id = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_name length] != 0) withMessage:@"Name cannot be empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setScreenId:(NSString *)screenId {
    _id = screenId;
}

- (void) setType:(NSString *)type {
    _type = type;
}

- (void) setPreviousScreenName:(NSString *)name {
    _previousName = name;
}

- (void) setPreviousScreenId:(NSString *)screenId {
    _previousId = screenId;
}

- (void) setPreviousScreenType:(NSString *)type {
    _previousType = type;
}

- (void) setTransitionType:(NSString *)type {
    _transitionType = type;
}

- (BOOL) setWithPreviousState:(SPScreenState *)previousState {
    if (![previousState isValid]) {
        return NO;
    }
    _previousName = previousState.name;
    _previousId = previousState.screenId;
    _previousType = previousState.type;
    return YES;
}

- (BOOL) setWithCurrentState:(SPScreenState *)currentState {
    if (![currentState isValid]) {
        return NO;
    }
    _name = currentState.name;
    _id = currentState.screenId;
    _type = currentState.type;
    _transitionType = currentState.transitionType;
    return YES;
}

- (BOOL) setWithCurrentState:(SPScreenState *)currentState previousState:(SPScreenState *)previousState {
    BOOL success = NO;
    success = [self setWithCurrentState:currentState];
    if (!success) {
        return NO;
    }

    success = [self setWithPreviousState:previousState];
    return success;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {
    SPPayload * payload = [[SPPayload alloc] init];
    [payload addValueToPayload:_name forKey:kSPSvName];
    [payload addValueToPayload:_type forKey:kSPSvType];
    [payload addValueToPayload:_id forKey:kSPSvScreenId];
    [payload addValueToPayload:_previousName forKey:kSPSvPreviousName];
    [payload addValueToPayload:_previousType forKey:kSPSvPreviousType];
    [payload addValueToPayload:_previousId forKey:kSPSvPreviousScreenId];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPScreenViewSchema
                                                andPayload:payload];
}

- (SPScreenState *) getScreenState {
    SPScreenState * state = [[SPScreenState alloc] initWithName:_name
                                                           type:_type
                                                       screenId:_id
                                                 transitionType:_transitionType];
    return state;
}

- (BOOL) definesPreviousState {
    // returns if valid previous state data exists in event
    return ([self getPreviousState] != nil);
}

- (SPScreenState *) getPreviousState {
    // returns valid previous state data in event
    SPScreenState * previousState = [[SPScreenState alloc] initWithName:_previousName
                                                                   type:_previousType
                                                               screenId:_previousId];
    return previousState;
}

@end

// ConsentWithdrawn Event

@implementation SPConsentWithdrawn {
    BOOL * _all;
    NSString * _documentId;
    NSString * _version;
    NSString * _name;
    NSString * _description;
    NSArray * _documents;
}

+ (instancetype) build:(void(^)(id<SPConsentWithdrawnBuilder>builder))buildBlock {
    SPConsentWithdrawn* event = [SPConsentWithdrawn new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [self basePreconditions];
}

// --- Builder Methods

- (void) setDocumentId:(NSString *)dId {
    _documentId = dId;
}

- (void) setVersion:(NSString *)version {
    _version = version;
}

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setDescription:(NSString *)description {
    _description = description;
}

- (void) setAll:(BOOL *)all {
    _all = all;
}

// documents should be an array of consent SDJs
- (void) setDocuments:(NSArray *)documents {
    for (NSObject * sdj in documents) {
        [SPUtilities checkArgument:([sdj isKindOfClass:[SPSelfDescribingJson class]])
                       withMessage:@"All documents must be SelfDescribingJson objects."];
    }
    _documents = documents;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload{
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    // set event
    [event setObject:(_all ? @YES: @NO) forKey:KSPCwAll];

    return [[SPSelfDescribingJson alloc] initWithSchema:kSPConsentWithdrawnSchema andData:event];
}

- (NSArray *) getDocuments {
    __weak __typeof__(self) weakSelf = self;
    
    // returns the result of appending document passed through {docId, version, name, description} builder arguments to _documents
    NSMutableArray * documents = [[NSMutableArray alloc] init];
    SPConsentDocument * document = [SPConsentDocument build:^(id<SPConsentDocumentBuilder> builder) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;

        if (strongSelf->_documentId != nil) {
            [builder setDocumentId:strongSelf->_documentId];
        }
        if (strongSelf->_version != nil) {
            [builder setVersion:strongSelf->_version];
        }
        if ([strongSelf->_name length] != 0) {
            [builder setName:strongSelf->_name];
        }
        if ([strongSelf->_description length] != 0) {
            [builder setDescription:strongSelf->_description];
        }
    }];
    [documents addObject:[document getPayload]];
    if ([self->_documents count] > 0) {
        [documents addObjectsFromArray:self->_documents];
    }
    return documents;
}

@end

// Consent Document Event

@implementation SPConsentDocument {
    NSString * _documentId;
    NSString * _version;
    NSString * _name;
    NSString * _description;
}

+ (instancetype) build:(void(^)(id<SPConsentDocumentBuilder>builder))buildBlock {
    SPConsentDocument* event = [SPConsentDocument new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_documentId != nil) withMessage:@"Document ID cannot be nil."];
    [SPUtilities checkArgument:(_version != nil) withMessage:@"Version cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setDocumentId:(NSString *)dId {
    _documentId = dId;
}

- (void) setVersion:(NSString *)version {
    _version = version;
}

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setDescription:(NSString *)description {
    _description = description;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {

    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_documentId forKey:kSPCdId];
    [event setObject:_version forKey:kSPCdVersion];
    if ([_name length] != 0) {
        [event setObject:_name forKey:kSPCdName];
    }
    if ([_description length] != 0) {
        [event setObject:_description forKey:KSPCdDescription];
    }

    return [[SPSelfDescribingJson alloc] initWithSchema:kSPConsentDocumentSchema
                                                andData:event];
}

@end

// ConsentGranted Event

@implementation SPConsentGranted {
    NSString * _documentId;
    NSString * _version;
    NSString * _name;
    NSString * _description;
    NSString * _expiry;
    NSArray * _documents;
}

+ (instancetype) build:(void(^)(id<SPConsentGrantedBuilder>builder))buildBlock {
    SPConsentGranted* event = [SPConsentGranted new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_documentId != nil) withMessage:@"Document ID cannot be nil."];
    [SPUtilities checkArgument:(_version != nil) withMessage:@"Version cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setDocumentId:(NSString *)dId {
    _documentId = dId;
}

- (void) setVersion:(NSString *)version {
    _version = version;
}

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setDescription:(NSString *)description {
    _description = description;
}

- (void) setExpiry:(NSString *)expiry {
    _expiry = expiry;
}

- (void) setDocuments:(NSArray *)documents {
    for (NSObject * sdj in documents) {
        [SPUtilities checkArgument:([sdj isKindOfClass:[SPSelfDescribingJson class]])
                       withMessage:@"All documents must be SelfDescribingJson objects."];
    }
    _documents = documents;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload{
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    if ([_expiry length] != 0) {
        [event setObject:_expiry forKey:KSPCgExpiry];
    }
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPConsentGrantedSchema
                                                andData:event];
}

- (NSArray *) getDocuments {
    __weak __typeof__(self) weakSelf = self;
    
    // returns the result of appending document passed through {docId, version, name, description} to the documents data member
    NSMutableArray * documents = [[NSMutableArray alloc] init];
    if (self == nil) {
        return documents;
    }
    SPConsentDocument * document = [SPConsentDocument build:^(id<SPConsentDocumentBuilder> builder) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        [builder setDocumentId:strongSelf->_documentId];
        [builder setVersion:strongSelf->_version];
        if ([strongSelf->_name length] != 0) {
            [builder setName:strongSelf->_name];
        }
        if ([strongSelf->_description length] != 0) {
            [builder setDescription:strongSelf->_description];
        }
    }];
    [documents addObject:[document getPayload]];
    if ([self->_documents count] > 0) {
        [documents addObjectsFromArray:self->_documents];
    }
    return documents;
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

// Push Notification Content

@implementation SPNotificationContent {
    NSString * _title;
    NSString * _subtitle;
    NSString * _body;
    NSNumber * _badge;
    NSString * _sound;
    NSString * _launchImageName;
    NSDictionary * _userInfo;
    NSArray * _attachments;
}

+ (instancetype) build:(void(^)(id<SPNotificationContentBuilder>builder))buildBlock {
    SPNotificationContent* event = [SPNotificationContent new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_title length] != 0) withMessage:@"Title cannot be nil or empty."];
    [SPUtilities checkArgument:([_body length] != 0) withMessage:@"Body cannot be nil or empty."];
    [SPUtilities checkArgument:(_badge != nil) withMessage:@"Badge cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setTitle:(NSString *)title {
    _title = title;
}

- (void) setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
}

- (void) setBody:(NSString *)body {
    _body = body;
}

- (void) setBadge:(NSNumber *)badge {
    _badge = badge;
}

- (void) setSound:(NSString *)sound {
    _sound = sound;
}

- (void) setLaunchImageName:(NSString *)name {
    _launchImageName = name;
}

- (void) setUserInfo:(NSDictionary *)userInfo {
    _userInfo = [SPUtilities replaceHyphenatedKeysWithCamelcase:userInfo];
}

- (void) setAttachments:(NSArray *)attachments {
    _attachments = attachments;
}

// --- Public Methods

- (NSDictionary *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_title forKey:kSPPnTitle];
    [event setObject:_body forKey:kSPPnBody];
    [event setValue:_badge forKey:kSPPnBadge];
    if (_subtitle != nil) {
        [event setObject:_subtitle forKey:kSPPnSubtitle];
    }
    if (_subtitle != nil) {
        [event setObject:_subtitle forKey:kSPPnSubtitle];
    }
    if (_sound != nil) {
        [event setObject:_sound forKey:kSPPnSound];
    }
    if (_launchImageName != nil) {
        [event setObject:_launchImageName forKey:kSPPnLaunchImageName];
    }
    if (_userInfo != nil) {
        NSMutableDictionary * aps = nil;
        NSMutableDictionary * newUserInfo = nil;

        // modify contentAvailable value "1" and "0" to @YES and @NO to comply with schema
        if (![[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:nil] &&
            [[_userInfo objectForKey:@"aps"] isKindOfClass:[NSDictionary class]]) {
            aps = [[NSMutableDictionary alloc] initWithDictionary:_userInfo[@"aps"]];

            if ([[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:@1]) {
                [aps setObject:@YES forKey:@"contentAvailable"];
            } else if ([[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:@0]) {
                [aps setObject:@NO forKey:@"contentAvailable"];
            }
            newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:_userInfo];
            [newUserInfo setObject:aps forKey:@"aps"];
        }
        [event setObject:[[NSDictionary alloc] initWithDictionary:newUserInfo] forKey:kSPPnUserInfo];
    }
    if (_attachments != nil) {
        [event setObject:_attachments forKey:kSPPnAttachments];
    }

    return [[NSDictionary alloc] initWithDictionary:event copyItems:YES];
}

@end

// Push Notification Event

@implementation SPPushNotification {
    NSString * _action;
    NSString * _trigger;
    NSString * _date;
    NSString * _category;
    NSString * _thread;
    SPNotificationContent * _notification;
}

+ (instancetype) build:(void(^)(id<SPPushNotificationBuilder>builder))buildBlock {
    SPPushNotification* event = [SPPushNotification new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_date length] != 0) withMessage:@"Delivery date cannot be nil or empty."];
    [SPUtilities checkArgument:([_action length] != 0) withMessage:@"Action cannot be nil or empty."];
    [SPUtilities checkArgument:([_trigger length] != 0) withMessage:@"Trigger cannot be nil or empty."];
    [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category identifier cannot be nil or empty."];
    [SPUtilities checkArgument:([_thread length] != 0) withMessage:@"Thread identifier cannot be nil or empty."];
    [SPUtilities checkArgument:(_notification != nil) withMessage:@"Notification cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setAction:(NSString *)action {
    _action = action;
}

- (void) setDeliveryDate:(NSString *)date {
    _date = date;
}

- (void) setTrigger:(NSString *)trigger {
    _trigger = trigger;
}

- (void) setCategoryIdentifier:(NSString *)category {
    _category = category;
}

- (void) setThreadIdentifier:(NSString *)thread {
    _thread = thread;
}

- (void) setNotification:(SPNotificationContent *)content {
    _notification = content;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    [event setObject:[_notification getPayload] forKey:kSPPushNotification];
    [event setObject:_trigger forKey:kSPPushTrigger];
    [event setObject:_action forKey:kSPPushAction];
    [event setObject:_date forKey:kSPPushDeliveryDate];
    [event setObject:_category forKey:kSPPushCategoryId];
    [event setObject:_thread forKey:kSPPushThreadId];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPPushNotificationSchema andData:event];
}

@end

// Background Event

@implementation SPBackground {
    NSNumber * _index;
}

+ (instancetype) build:(void(^)(id<SPBackgroundBuilder>builder))buildBlock {
    SPBackground* event = [SPBackground new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_index != nil) withMessage:@"Index cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setIndex:(NSNumber *)index {
    _index = index;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    [event setObject:_index forKey:kSPBackgroundIndex];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPBackgroundSchema andData:event];
}

@end

// Foreground Event

@implementation SPForeground {
    NSNumber * _index;
}

+ (instancetype) build:(void(^)(id<SPForegroundBuilder>builder))buildBlock {
    SPForeground* event = [SPForeground new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_index != nil) withMessage:@"Index cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setIndex:(NSNumber *)index {
    _index = index;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    [event setObject:_index forKey:kSPForegroundIndex];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPForegroundSchema andData:event];
}

@end

// Error event

@implementation SNOWError {
    NSString * _name;
    NSString * _stackTrace;
    NSString * _message;
}

+ (instancetype) build:(void(^)(id<SPErrorBuilder>builder))buildBlock {
    SNOWError * event = [SNOWError new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_message != nil) withMessage:@"Message cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setMessage:(NSString *)message {
    _message = message;
}

- (void) setStackTrace:(NSString *)stackTrace {
    _stackTrace = stackTrace;
}

- (void) setName:(NSString *)name {
    _name = name;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {
    SPPayload * event = [[SPPayload alloc] init];
    [event addValueToPayload:_message forKey:kSPErrorMessage];
    [event addValueToPayload:_stackTrace forKey:kSPErrorStackTrace];
    [event addValueToPayload:_name forKey:kSPErrorName];
    [event addValueToPayload:@"OBJECTIVEC" forKey:kSPErrorLanguage];
    
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPErrorSchema andPayload:event];
}

@end

