//
//  SPEcommerceItem.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPEcommerceItem.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"

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

- (NSString *)name {
    return kSPEventEcommItem;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_itemId forKey:kSPEcommItemId];
    [payload setValue:_sku forKey:kSPEcommItemSku];
    [payload setValue:_name forKey:kSPEcommItemName];
    [payload setValue:_category forKey:kSPEcommItemCategory];
    [payload setValue:_currency forKey:kSPEcommItemCurrency];
    if (_price) [payload setObject:[NSString stringWithFormat:@"%.02f", [_price doubleValue]] forKey:kSPEcommItemPrice];
    if (_quantity) [payload setObject:[NSString stringWithFormat:@"%ld", [_quantity longValue]] forKey:kSPEcommItemQuantity];
    return payload;
}

- (SPPayload *) getPayload {
    SPPayload *payload = [SPPayload new];
    [payload addValueToPayload:kSPEventEcommItem forKey:kSPEvent];
    [payload addValueToPayload:_itemId forKey:kSPEcommItemId];
    [payload addValueToPayload:_sku forKey:kSPEcommItemSku];
    [payload addValueToPayload:_name forKey:kSPEcommItemName];
    [payload addValueToPayload:_category forKey:kSPEcommItemCategory];
    [payload addValueToPayload:[NSString stringWithFormat:@"%.02f", [_price doubleValue]] forKey:kSPEcommItemPrice];
    [payload addValueToPayload:[NSString stringWithFormat:@"%ld", [_quantity longValue]] forKey:kSPEcommItemQuantity];
    [payload addValueToPayload:_currency forKey:kSPEcommItemCurrency];
    return [self addDefaultParamsToPayload:payload];
}

@end
