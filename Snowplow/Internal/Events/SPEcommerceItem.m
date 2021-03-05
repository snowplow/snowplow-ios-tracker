//
//  SPEcommerceItem.m
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPEcommerceItem.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"

@implementation SPEcommerceItem {
    NSString * _orderId;
    NSString * _sku;
    NSNumber * _price;
    NSNumber * _quantity;
    NSString * _name;
    NSString * _category;
    NSString * _currency;
}

+ (instancetype)build:(void(^)(id<SPEcommTransactionItemBuilder> builder))buildBlock {
    SPEcommerceItem* event = [SPEcommerceItem new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithSku:(NSString *)sku price:(NSNumber *)price quantity:(NSNumber *)quantity {
    if (self = [super init]) {
        _sku = sku;
        _price = price;
        _quantity = quantity;
        [SPUtilities checkArgument:([_sku length] != 0) withMessage:@"SKU cannot be nil or empty."];
    }
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_sku length] != 0) withMessage:@"SKU cannot be nil or empty."];
    [SPUtilities checkArgument:(_price != nil) withMessage:@"Price cannot be nil."];
    [SPUtilities checkArgument:(_quantity != nil) withMessage:@"Quantity cannot be nil."];
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, name)
SP_BUILDER_METHOD(NSString *, category)
SP_BUILDER_METHOD(NSString *, currency)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (void) setItemId:(NSString *)itemId __deprecated {
    [self setOrderId:itemId];
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

#pragma clang diagnostic pop

// --- Public Methods

- (void)setOrderId:(NSString *)orderId {
    [SPUtilities checkArgument:([orderId length] != 0) withMessage:@"OrderId cannot be nil or empty."];
    _orderId = orderId;
}

- (NSString *)name {
    return kSPEventEcommItem;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_orderId forKey:kSPEcommItemId];
    [payload setValue:_sku forKey:kSPEcommItemSku];
    [payload setValue:_name forKey:kSPEcommItemName];
    [payload setValue:_category forKey:kSPEcommItemCategory];
    [payload setValue:_currency forKey:kSPEcommItemCurrency];
    if (_price) [payload setObject:[NSString stringWithFormat:@"%.02f", [_price doubleValue]] forKey:kSPEcommItemPrice];
    if (_quantity) [payload setObject:[NSString stringWithFormat:@"%ld", [_quantity longValue]] forKey:kSPEcommItemQuantity];
    return payload;
}

@end
