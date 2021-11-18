//
//  SPEcommerce.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Alex Benini
//  Copyright: Copyright © 2021 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPEcommerce.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPTracker.h"

@interface SPEcommerce ()

@property (nonatomic, readwrite) NSString *orderId;
@property (nonatomic, readwrite) NSNumber *totalValue;
@property (nonatomic, readwrite) NSArray<SPEcommerceItem *> *items;

@end

@implementation SPEcommerce

- (instancetype)initWithOrderId:(NSString *)orderId totalValue:(NSNumber *)totalValue items:(NSArray<SPEcommerceItem *> *)items {
    if (self = [super init]) {
        _orderId = orderId;
        _totalValue = totalValue;
        _items = items.copy;
        [SPUtilities checkArgument:([_orderId length] != 0) withMessage:@"OrderId cannot be nil or empty."];
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, affiliation)
SP_BUILDER_METHOD(NSNumber *, taxValue)
SP_BUILDER_METHOD(NSNumber *, shipping)
SP_BUILDER_METHOD(NSString *, city)
SP_BUILDER_METHOD(NSString *, state)
SP_BUILDER_METHOD(NSString *, country)
SP_BUILDER_METHOD(NSString *, currency)

// --- Public Methods

- (NSString *)eventName {
    return kSPEventEcomm;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
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

- (NSArray<SPEcommerceItem *> *)getItems {
    return _items;
}

- (void)endProcessingWithTracker:(SPTracker *)tracker {
    for (SPEcommerceItem *item in _items) {
        item.orderId  = _orderId;
        [tracker track:item];
    }
}

@end
