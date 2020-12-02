//
//  SPSessionConfiguration.h
//  Snowplow
//
//  Created by Alex Benini on 29/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SessionConfiguration.Protocol)
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
