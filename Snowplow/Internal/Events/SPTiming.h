//
//  SPTiming.h
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
#import "SPSelfDescribingJson.h"

NS_ASSUME_NONNULL_BEGIN

/// A timing event.
NS_SWIFT_NAME(Timing)
@interface SPTiming : SPSelfDescribingAbstract

@property (nonatomic, readonly) NSString *category;
@property (nonatomic, readonly) NSString *variable;
@property (nonatomic, readonly) NSNumber *timing;
@property (nonatomic, nullable) NSString *label;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCategory:(NSString *)category variable:(NSString *)variable timing:(NSNumber *)timing NS_SWIFT_NAME(init(category:variable:timing:));

SP_BUILDER_DECLARE_NULLABLE(NSString *, label)

@end

NS_ASSUME_NONNULL_END
