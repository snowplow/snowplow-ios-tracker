//
//  SPEcommerceItem.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import "SPEcommerceItem.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"

@interface SPEcommerceItem ()

@property (nonatomic, readwrite) NSString *sku;
@property (nonatomic, readwrite) NSNumber *price;
@property (nonatomic, readwrite) NSNumber *quantity;

@end

@implementation SPEcommerceItem

- (instancetype)initWithSku:(NSString *)sku price:(NSNumber *)price quantity:(NSNumber *)quantity {
    if (self = [super init]) {
        _sku = sku;
        _price = price;
        _quantity = quantity;
        [SPUtilities checkArgument:([_sku length] != 0) withMessage:@"SKU cannot be nil or empty."];
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, name)
SP_BUILDER_METHOD(NSString *, category)
SP_BUILDER_METHOD(NSString *, currency)
SP_BUILDER_METHOD(NSString *, orderId)

// --- Public Methods

- (NSString *)eventName {
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
