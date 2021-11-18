//
//  SPEcommerce.h
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
#import "SPEcommerceItem.h"

NS_ASSUME_NONNULL_BEGIN

/// An ecommerce event.
NS_SWIFT_NAME(Ecommerce)
@interface SPEcommerce : SPPrimitiveAbstract

/// Identifier of the order.
@property (nonatomic, readonly) NSString *orderId;
/// Total amount of the order.
@property (nonatomic, readonly) NSNumber *totalValue;
/// Items purchased.
@property (nonatomic, readonly) NSArray<SPEcommerceItem *> *items;
/// Identifies an affiliation.
@property (nonatomic, nullable) NSString *affiliation;
/// Taxes applied to the purchase.
@property (nonatomic, nullable) NSNumber *taxValue;
/// Shipping number.
@property (nonatomic, nullable) NSNumber *shipping;
/// City for shipping.
@property (nonatomic, nullable) NSString *city;
/// State for shipping.
@property (nonatomic, nullable) NSString *state;
/// Country for shipping.
@property (nonatomic, nullable) NSString *country;
/// Currency used for totalValue and taxValue.
@property (nonatomic, nullable) NSString *currency;

- (instancetype)init NS_UNAVAILABLE;

/**
 Creates an ecommerce event.
 @param orderId Identifier of the order.
 @param totalValue Total amount of the order.
 @param items Items purchased.
 */
- (instancetype)initWithOrderId:(NSString *)orderId totalValue:(NSNumber *)totalValue items:(NSArray<SPEcommerceItem *> *)items NS_SWIFT_NAME(init(orderId:totalValue:items:));

/// List of the items purchased.
- (NSArray<SPEcommerceItem *> *)getItems;

/// Identifies an affiliation.
SP_BUILDER_DECLARE_NULLABLE(NSString *, affiliation)
/// Taxes applied to the purchase.
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, taxValue)
/// Shipping number.
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, shipping)
/// City for shipping.
SP_BUILDER_DECLARE_NULLABLE(NSString *, city)
/// State for shipping.
SP_BUILDER_DECLARE_NULLABLE(NSString *, state)
/// Country for shipping.
SP_BUILDER_DECLARE_NULLABLE(NSString *, country)
/// Currency used for totalValue and taxValue.
SP_BUILDER_DECLARE_NULLABLE(NSString *, currency)

@end

NS_ASSUME_NONNULL_END
