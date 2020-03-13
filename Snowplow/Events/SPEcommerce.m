//
//  SPEcommerce.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEcommerce.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"

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

- (NSString *)name {
    return kSPEventEcomm;
}

- (NSDictionary *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    if (_totalValue) [payload setObject:[NSString stringWithFormat:@"%.02f", [_totalValue doubleValue]] forKey:kSPEcommTotal];
    if (_taxValue) [payload setObject:[NSString stringWithFormat:@"%.02f", [_taxValue doubleValue]] forKey:kSPEcommTax];
    if (_shipping) [payload setObject:[NSString stringWithFormat:@"%.02f", [_shipping doubleValue]] forKey:kSPEcommShipping];
    [payload setValue:_orderId forKey:kSPEcommId];
    [payload setValue:_affiliation forKey:kSPEcommAffiliation];
    [payload setValue:_city forKey:kSPEcommCity];
    [payload setValue:_state forKey:kSPEcommState];
    [payload setValue:_country forKey:kSPEcommCountry];
    [payload setValue:_currency forKey:kSPEcommCurrency];
    return payload;
}

- (SPPayload *) getPayload {
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:kSPEventEcomm forKey:kSPEvent];
    [payload addValueToPayload:_orderId forKey:kSPEcommId];
    [payload addValueToPayload:[NSString stringWithFormat:@"%.02f", [_totalValue doubleValue]] forKey:kSPEcommTotal];
    [payload addValueToPayload:_affiliation forKey:kSPEcommAffiliation];
    [payload addValueToPayload:[NSString stringWithFormat:@"%.02f", [_taxValue doubleValue]] forKey:kSPEcommTax];
    [payload addValueToPayload:[NSString stringWithFormat:@"%.02f", [_shipping doubleValue]] forKey:kSPEcommShipping];
    [payload addValueToPayload:_city forKey:kSPEcommCity];
    [payload addValueToPayload:_state forKey:kSPEcommState];
    [payload addValueToPayload:_country forKey:kSPEcommCountry];
    [payload addValueToPayload:_currency forKey:kSPEcommCurrency];
    return [self addDefaultParamsToPayload:payload];
}

- (NSArray *) getItems {
    return _items;
}

@end
