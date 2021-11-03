//
//  SPStructured.h
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

/// A structured event.
NS_SWIFT_NAME(Structured)
@interface SPStructured : SPPrimitiveAbstract

@property (nonatomic, readonly) NSString *category;
@property (nonatomic, readonly) NSString *action;
@property (nonatomic, nullable) NSString *label;
@property (nonatomic, nullable) NSString *property;
@property (nonatomic, nullable) NSNumber *value;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCategory:(NSString *)category action:(NSString *)action NS_SWIFT_NAME(init(category:action:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, label)
SP_BUILDER_DECLARE_NULLABLE(NSString *, property)
SP_BUILDER_DECLARE_NULLABLE(NSNumber *, value)

@end

NS_ASSUME_NONNULL_END
