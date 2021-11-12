//
//  SPEcommerceItem.h
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

#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

/// An ecommerce item event.
NS_SWIFT_NAME(EcommerceItem)
@interface SPEcommerceItem : SPPrimitiveAbstract

/// Stock Keeping Unit of the item.
@property (nonatomic, readonly) NSString *sku;
/// Price of the item.
@property (nonatomic, readonly) NSNumber *price;
/// Quantity of the item.
@property (nonatomic, readonly) NSNumber *quantity;
/// Name of the item.
@property (nonatomic, nullable) NSString *name;
/// Category of the item.
@property (nonatomic, nullable) NSString *category;
/// Currency used for the price of the item.
@property (nonatomic, nullable) NSString *currency;
/// OrderID of the order that contains this item.
@property (nonatomic, nullable) NSString *orderId;

- (instancetype)init NS_UNAVAILABLE;

/**
 Creates an ecommerce item event.
 @param sku Stock Keeping Unit of the item.
 @param price Price of the item.
 @param quantity Quantity of the item.
 */
- (instancetype)initWithSku:(NSString *)sku price:(NSNumber *)price quantity:(NSNumber *)quantity NS_SWIFT_NAME(init(sku:price:quantity:));

/// Name of the item.
SP_BUILDER_DECLARE_NULLABLE(NSString *, name)
/// Category of the item.
SP_BUILDER_DECLARE_NULLABLE(NSString *, category)
/// Currency used for the price of the item.
SP_BUILDER_DECLARE_NULLABLE(NSString *, currency)
/// OrderID of the order that contains this item.
SP_BUILDER_DECLARE_NULLABLE(NSString *, orderId)

@end

NS_ASSUME_NONNULL_END
