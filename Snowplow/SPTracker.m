//
//  SPTracker.m
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPUtils.h"
#import "SPSession.h"

@implementation SPTracker {
    BOOL                   _base64Encoded;
    NSMutableDictionary *  _trackerData;
    NSString *             _platformContextSchema;
    BOOL                   _dataCollection;
}

// SnowplowTracker Builder

+ (instancetype) build:(void(^)(id<SPTrackerBuilder>builder))buildBlock {
    SPTracker* tracker = [SPTracker new];
    if (buildBlock) {
        buildBlock(tracker);
    }
    [tracker setup];
    return tracker;
}

- (id) init {
    self = [super init];
    if (self) {
        _trackerNamespace = nil;
        _appId = nil;
        _base64Encoded = YES;
        _dataCollection = YES;
        
#if TARGET_OS_IPHONE
        _platformContextSchema = kMobileContextSchema;
#else
        _platformContextSchema = kDesktopContextSchema;
#endif
    }
    return self;
}

- (void) setup {
    _trackerData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     kVersion, kTrackerVersion,
                     _trackerNamespace != nil ? _trackerNamespace : [NSNull null], kNamespace,
                     _appId != nil ? _appId : [NSNull null], kAppId, nil];
}

// Required

- (void) setEmitter:(SPEmitter *)emitter {
    _emitter = emitter;
}

- (void) setSubject:(SPSubject *)subject {
    _subject = subject;
}

- (void) setBase64Encoded:(BOOL)encoded {
    _base64Encoded = encoded;
}

- (void) setAppId:(NSString *)appId {
    _appId = appId;
}

- (void) setNamespace:(NSString *)trackerNamespace {
    _trackerNamespace = trackerNamespace;
}

- (void) setSessionContext:(BOOL)sessionContext {
    if (sessionContext) {
        _session = [[SPSession alloc] init];
    }
}

// Event Decoration

- (void) decorateEventPayload:(SPPayload *)pb context:(NSMutableArray *)contextArray {
    
    // Add Tracker and Subject Data to event
    [pb addDictionaryToPayload:_trackerData];
    if (_subject != nil) {
        [pb addDictionaryToPayload:[[_subject getStandardDict] getPayloadAsDictionary]];
    } else {
        [pb addValueToPayload:[SPUtils getPlatform] forKey:kPlatform];
    }
    
    // Add the Contexts together
    if (contextArray == nil) {
        contextArray = [[NSMutableArray alloc] init];
    }
    
    if (_subject != nil) {
        NSDictionary * platformDict = [[_subject getPlatformDict] getPayloadAsDictionary];
        if (platformDict != nil) {
            [contextArray addObject:[self getContextEnvelopeWithSchema:_platformContextSchema
                                                               andData:platformDict]];
        }
    }
    
    if (_session != nil) {
        NSDictionary * sessionDict = [[_session getSessionDict] getPayloadAsDictionary];
        if (sessionDict != nil) {
            [contextArray addObject:[self getContextEnvelopeWithSchema:kSessionContextSchema
                                                               andData:sessionDict]];
        }
    }
    
    if (contextArray.count > 0) {
        NSDictionary * contextEnvelope = [self getContextEnvelopeWithSchema:kContextSchema
                                                                    andData:contextArray];
        [pb addDictionaryToPayload:contextEnvelope
                     base64Encoded:_base64Encoded
                   typeWhenEncoded:kContextEncoded
                typeWhenNotEncoded:kContext];
    }
    
    // Add an Event ID
    [pb addValueToPayload:[SPUtils getEventId] forKey:kEid];
}

- (NSDictionary *) getContextEnvelopeWithSchema:(NSString *)schema andData:(NSObject *)data {
    return [NSDictionary dictionaryWithObjectsAndKeys:schema, kSchema, data, kData, nil];
}

- (double) setTimestamp:(double)timestamp toPayload:(SPPayload *)payload {
    double tstamp = timestamp;
    if(timestamp == 0) {
        tstamp = [SPUtils getTimestamp];
    }
    [payload addValueToPayload:[NSString stringWithFormat:@"%.0f", tstamp] forKey:kTimestamp];
    return tstamp;
}

- (void) addTracker:(SPPayload *)event {
    [_emitter addPayloadToBuffer:event];
}

- (void) pauseEventTracking {
    _dataCollection = NO;
    [_session stopChecker];
}

- (void) resumeEventTracking {
    _dataCollection = YES;
    [_session startChecker];
}

// Getters & Setters

- (NSInteger) getSessionIndex {
    return [_session getSessionIndex];
}

- (BOOL) getInBackground {
    return [_session getInBackground];
}

- (BOOL) getIsTracking {
    return _dataCollection;
}

// Event Tracking Functions

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer {
    [self trackPageView:pageUrl title:pageTitle referrer:referrer context:nil timestamp:0];
}

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
               context:(NSMutableArray *)context {
    [self trackPageView:pageUrl title:pageTitle referrer:referrer context:context timestamp:0];
}

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
             timestamp:(double)timestamp {
    [self trackPageView:pageUrl title:pageTitle referrer:referrer context:nil timestamp:timestamp];
}

- (void) trackPageView:(NSString *)pageUrl
                 title:(NSString *)pageTitle
              referrer:(NSString *)referrer
               context:(NSMutableArray *)context
             timestamp:(double)timestamp {
    if (!_dataCollection) {
        return;
    }
    
    SPPayload *pb = [[SPPayload alloc] init];
    
    [self decorateEventPayload:pb context:context];
    [self setTimestamp:timestamp toPayload:pb];
    
    [pb addValueToPayload:kEventPageView forKey:kEvent];
    [pb addValueToPayload:pageUrl        forKey:kPageUrl];
    [pb addValueToPayload:pageTitle      forKey:kPageTitle];
    [pb addValueToPayload:referrer       forKey:kPageRefr];

    [self addTracker:pb];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value {
    [self trackStructuredEvent:category action:action label:label property:property value:value context:nil timestamp:0];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                      context:(NSMutableArray *)context {
    [self trackStructuredEvent:category action:action label:label property:property value:value context:context timestamp:0];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                    timestamp:(double)timestamp {
    [self trackStructuredEvent:category action:action label:label property:property value:value context:nil timestamp:timestamp];
}

- (void) trackStructuredEvent:(NSString *)category
                       action:(NSString *)action
                        label:(NSString *)label
                     property:(NSString *)property
                        value:(float)value
                      context:(NSMutableArray *)context
                    timestamp:(double)timestamp {
    if (!_dataCollection) {
        return;
    }
    
    SPPayload *pb = [[SPPayload alloc] init];
    
    [self decorateEventPayload:pb context:context];
    [self setTimestamp:timestamp toPayload:pb];

    [pb addValueToPayload:kEventStructured forKey:kEvent];
    [pb addValueToPayload:category         forKey:kStuctCategory];
    [pb addValueToPayload:action           forKey:kStuctAction];
    [pb addValueToPayload:label            forKey:kStuctLabel];
    [pb addValueToPayload:property         forKey:kStuctProperty];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", value] forKey:kStuctValue];

    [self addTracker:pb];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson {
    [self trackUnstructuredEvent:eventJson context:nil timestamp:0];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSMutableArray *)context {
    [self trackUnstructuredEvent:eventJson context:context timestamp:0];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                      timestamp:(double)timestamp {
    [self trackUnstructuredEvent:eventJson context:nil timestamp:timestamp];
}

- (void) trackUnstructuredEvent:(NSDictionary *)eventJson
                        context:(NSMutableArray *)context
                      timestamp:(double)timestamp {
    if (!_dataCollection) {
        return;
    }
    
    SPPayload *pb = [[SPPayload alloc] init];
    
    [self decorateEventPayload:pb context:context];
    [self setTimestamp:timestamp toPayload:pb];
    
    [pb addValueToPayload:kEventUnstructured forKey:kEvent];

    NSDictionary *envelope = [NSDictionary dictionaryWithObjectsAndKeys:
                              kUnstructSchema, kSchema,
                              eventJson, kData, nil];
    [pb addDictionaryToPayload:envelope
                 base64Encoded:_base64Encoded
               typeWhenEncoded:kUnstructuredEncoded
            typeWhenNotEncoded:kUnstructured];

    [self addTracker:pb];
}

- (SPPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                          sku:(NSString *)sku
                                         name:(NSString *)name
                                     category:(NSString *)category
                                        price:(float)price
                                     quantity:(int)quantity
                                     currency:(NSString *)currency {
    return [self trackEcommerceTransactionItem:orderId sku:sku name:name category:category price:price quantity:quantity currency:currency context:nil timestamp:0];
}

- (SPPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                          sku:(NSString *)sku
                                         name:(NSString *)name
                                     category:(NSString *)category
                                        price:(float)price
                                     quantity:(int)quantity
                                     currency:(NSString *)currency
                                      context:(NSMutableArray *)context {
    return [self trackEcommerceTransactionItem:orderId sku:sku name:name category:category price:price quantity:quantity currency:currency context:context timestamp:0];
}

- (SPPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                          sku:(NSString *)sku
                                         name:(NSString *)name
                                     category:(NSString *)category
                                        price:(float)price
                                     quantity:(int)quantity
                                     currency:(NSString *)currency
                                    timestamp:(double)timestamp {
    return [self trackEcommerceTransactionItem:orderId sku:sku name:name category:category price:price quantity:quantity currency:currency context:nil timestamp:timestamp];
}

- (SPPayload *) trackEcommerceTransactionItem:(NSString *)orderId
                                          sku:(NSString *)sku
                                         name:(NSString *)name
                                     category:(NSString *)category
                                        price:(float)price
                                     quantity:(int)quantity
                                     currency:(NSString *)currency
                                      context:(NSMutableArray *)context
                                    timestamp:(double)timestamp {
    SPPayload *pb = [[SPPayload alloc] init];
    
    [self decorateEventPayload:pb context:context];
    [self setTimestamp:timestamp toPayload:pb];

    [pb addValueToPayload:kEventEcommItem forKey:kEvent];
    [pb addValueToPayload:orderId         forKey:kEcommItemId];
    [pb addValueToPayload:sku             forKey:kEcommItemSku];
    [pb addValueToPayload:name            forKey:kEcommItemName];
    [pb addValueToPayload:category        forKey:kEcommItemCategory];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", price]    forKey:kEcommItemPrice];
    [pb addValueToPayload:[NSString stringWithFormat:@"%d", quantity] forKey:kEcommItemQuantity];
    [pb addValueToPayload:currency        forKey:kEcommItemCurrency];

    return pb;
}

- (void) trackEcommerceTransaction:(NSString *)orderId
                        totalValue:(float)totalValue
                       affiliation:(NSString *)affiliation
                          taxValue:(float)taxValue
                          shipping:(float)shipping
                              city:(NSString *)city
                             state:(NSString *)state
                           country:(NSString *)country
                          currency:(NSString *)currency
                             items:(NSArray *)items {
    [self trackEcommerceTransaction:orderId totalValue:totalValue affiliation:affiliation taxValue:taxValue shipping:shipping city:city state:state country:country currency:currency items:items context:nil timestamp:0];
}

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
                           context:(NSMutableArray *)context {
    [self trackEcommerceTransaction:orderId totalValue:totalValue affiliation:affiliation taxValue:taxValue shipping:shipping city:city state:state country:country currency:currency items:items context:context timestamp:0];
}

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
                         timestamp:(double)timestamp {
    [self trackEcommerceTransaction:orderId totalValue:totalValue affiliation:affiliation taxValue:taxValue shipping:shipping city:city state:state country:country currency:currency items:items context:nil timestamp:timestamp];
}

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
                         timestamp:(double)timestamp {
    if (!_dataCollection) {
        return;
    }
    
    SPPayload *pb =  [[SPPayload alloc] init];
    
    [self decorateEventPayload:pb context:context];

    [pb addValueToPayload:KEventEcomm forKey:kEvent];
    [pb addValueToPayload:orderId     forKey:kEcommId];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", totalValue] forKey:kEcommTotal];
    [pb addValueToPayload:affiliation forKey:kEcommAffiliation];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", taxValue]   forKey:kEcommTax];
    [pb addValueToPayload:[NSString stringWithFormat:@"%f", shipping]   forKey:kEcommShipping];
    [pb addValueToPayload:city        forKey:kEcommCity];
    [pb addValueToPayload:state       forKey:kEcommState];
    [pb addValueToPayload:country     forKey:kEcommCountry];
    [pb addValueToPayload:currency    forKey:kEcommCurrency];

    double tstamp = [self setTimestamp:timestamp toPayload:pb];

    for (SPPayload *item in items) {
        [item addValueToPayload:[NSString stringWithFormat:@"%.0f", tstamp] forKey:kTimestamp];
        [item addValueToPayload:orderId  forKey:kEcommItemId];
        [item addValueToPayload:currency forKey:kEcommItemCurrency];
        [self addTracker:item];
    }

    [self addTracker:pb];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_ {
    [self trackScreenView:name id:id_ context:nil timestamp:0];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSMutableArray *)context {
    [self trackScreenView:name id:id_ context:context timestamp:0];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
               timestamp:(double)timestamp {
    [self trackScreenView:name id:id_ context:nil timestamp:timestamp];
}

- (void) trackScreenView:(NSString *)name
                      id:(NSString *)id_
                 context:(NSMutableArray *)context
               timestamp:(double)timestamp {
    if (!_dataCollection) {
        return;
    }
    
    NSMutableDictionary *screenViewProperties = [[NSMutableDictionary alloc] init];
    
    if (id_ != nil) {
        [screenViewProperties setObject:id_ forKey:kSvId];
    }
    if (name != nil) {
        [screenViewProperties setObject:name forKey:kSvName];
    }

    NSDictionary *eventJson = [NSDictionary dictionaryWithObjectsAndKeys:
                               kScreenViewSchema, kSchema,
                               screenViewProperties, kData, nil];
    
    [self trackUnstructuredEvent:eventJson context:context timestamp:timestamp];
}

- (void) trackTimingWithCategory:(NSString *)category
            variable:(NSString *)variable
              timing:(NSUInteger)timing
               label:(NSString *)label {
    [self trackTimingWithCategory:category variable:variable timing:timing label:label context:nil timestamp:0];
}

- (void) trackTimingWithCategory:(NSString *)category
            variable:(NSString *)variable
              timing:(NSUInteger)timing
               label:(NSString *)label
             context:(NSMutableArray *)context {
    [self trackTimingWithCategory:category variable:variable timing:timing label:label context:context timestamp:0];
}

- (void) trackTimingWithCategory:(NSString *)category
            variable:(NSString *)variable
              timing:(NSUInteger)timing
               label:(NSString *)label
           timestamp:(double)timestamp {
    [self trackTimingWithCategory:category variable:variable timing:timing label:label context:nil timestamp:timestamp];
}

- (void) trackTimingWithCategory:(NSString *)category
            variable:(NSString *)variable
              timing:(NSUInteger)timing
               label:(NSString *)label
             context:(NSMutableArray *)context
           timestamp:(double)timestamp {
    if (!_dataCollection) {
        return;
    }
    
    NSMutableDictionary *timingProperties = [[NSMutableDictionary alloc] init];

    [timingProperties setObject:category forKey:kUtCategory];
    [timingProperties setObject:variable forKey:kUtVariable];
    [timingProperties setObject:[NSNumber numberWithInteger:timing] forKey:kUtTiming];
    
    if (label != nil) {
        [timingProperties setObject:label forKey:kUtLabel];
    }

    NSDictionary *eventJson = [NSDictionary dictionaryWithObjectsAndKeys:
                               kUserTimingsSchema, kSchema,
                               timingProperties, kData, nil];

    [self trackUnstructuredEvent:eventJson context:context timestamp:timestamp];
}

@end
