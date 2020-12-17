//
//  SPSessionConfiguration.h
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SessionConfigurationProtocol)
@protocol SPSessionConfigurationProtocol

@property NSInteger foregroundTimeoutInSeconds;
@property NSInteger backgroundTimeoutInSeconds;

@property NSMeasurement<NSUnitDuration *> *foregroundTimeout API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0));
@property NSMeasurement<NSUnitDuration *> *backgroundTimeout API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0));

@end

NS_SWIFT_NAME(SessionConfiguration)
@interface SPSessionConfiguration : SPConfiguration <SPSessionConfigurationProtocol>

- (instancetype)initWithForegroundTimeoutInSeconds:(NSInteger)foregroundTimeout backgroundTimeoutInSeconds:(NSInteger)backgroundTimeout;

- (instancetype)initWithForegroundTimeout:(NSMeasurement<NSUnitDuration *> *)foregroundTimeout
                        backgroundTimeout:(NSMeasurement<NSUnitDuration *> *)backgroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0));

@end

NS_ASSUME_NONNULL_END
