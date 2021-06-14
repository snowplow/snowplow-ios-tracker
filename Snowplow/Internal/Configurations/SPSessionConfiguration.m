//
//  SPSessionConfiguration.m
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

#import "SPSessionConfiguration.h"
#import "NSDictionary+SP_TypeMethods.h"

@implementation SPSessionConfiguration

@synthesize foregroundTimeoutInSeconds;
@synthesize backgroundTimeoutInSeconds;

- (instancetype)init {
    return [self initWithForegroundTimeoutInSeconds:1800 backgroundTimeoutInSeconds:1800];
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *,NSObject *> *)dictionary {
    NSInteger foregroundTimeout = [dictionary sp_numberForKey:SP_STR_PROP(foregroundTimeout) defaultValue:@1800].integerValue;
    NSInteger backgroundTimeout = [dictionary sp_numberForKey:SP_STR_PROP(backgroundTimeout) defaultValue:@1800].integerValue;
    return [self initWithForegroundTimeoutInSeconds:foregroundTimeout backgroundTimeoutInSeconds:backgroundTimeout];
}

- (instancetype)initWithForegroundTimeout:(NSMeasurement<NSUnitDuration *> *)foregroundTimeout backgroundTimeout:(NSMeasurement<NSUnitDuration *> *)backgroundTimeout {
    NSMeasurement<NSUnitDuration *> *foreground = [foregroundTimeout measurementByConvertingToUnit:NSUnitDuration.seconds];
    NSInteger foregroundInSeconds = floor(foreground.doubleValue);
    NSMeasurement<NSUnitDuration *> *background = [backgroundTimeout measurementByConvertingToUnit:NSUnitDuration.seconds];
    NSInteger backgroundInSeconds = floor(background.doubleValue);
    return [self initWithForegroundTimeoutInSeconds:foregroundInSeconds backgroundTimeoutInSeconds:backgroundInSeconds];
}

- (instancetype)initWithForegroundTimeoutInSeconds:(NSInteger)foregroundTimeout backgroundTimeoutInSeconds:(NSInteger)backgroundTimeout {
    if (self = [super init]) {
        self.backgroundTimeoutInSeconds = backgroundTimeout;
        self.foregroundTimeoutInSeconds = foregroundTimeout;
    }
    return self;
}

- (void)setForegroundTimeout:(NSMeasurement<NSUnitDuration *> *)foregroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    NSMeasurement<NSUnitDuration *> *foreground = [foregroundTimeout measurementByConvertingToUnit:NSUnitDuration.seconds];
    self.foregroundTimeoutInSeconds = floor(foreground.doubleValue);
}

- (void)setBackgroundTimeout:(NSMeasurement<NSUnitDuration *> *)backgroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    NSMeasurement<NSUnitDuration *> *background = [backgroundTimeout measurementByConvertingToUnit:NSUnitDuration.seconds];
    self.backgroundTimeoutInSeconds = floor(background.doubleValue);
}

- (NSMeasurement<NSUnitDuration *> *)foregroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    return [[NSMeasurement alloc] initWithDoubleValue:self.foregroundTimeoutInSeconds unit:NSUnitDuration.seconds];
}

- (NSMeasurement<NSUnitDuration *> *)backgroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    return [[NSMeasurement alloc] initWithDoubleValue:self.backgroundTimeoutInSeconds unit:NSUnitDuration.seconds];
}

// MARK: - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SPSessionConfiguration *copy = [[SPSessionConfiguration allocWithZone:zone] init];
    copy.backgroundTimeoutInSeconds = self.backgroundTimeoutInSeconds;
    copy.foregroundTimeoutInSeconds = self.foregroundTimeoutInSeconds;
    return copy;
}

// MARK: - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeInteger:self.backgroundTimeoutInSeconds forKey:SP_STR_PROP(backgroundTimeoutInSeconds)];
    [coder encodeInteger:self.foregroundTimeoutInSeconds forKey:SP_STR_PROP(foregroundTimeoutInSeconds)];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.backgroundTimeoutInSeconds = [coder decodeIntegerForKey:SP_STR_PROP(backgroundTimeoutInSeconds)];
        self.foregroundTimeoutInSeconds = [coder decodeIntegerForKey:SP_STR_PROP(foregroundTimeoutInSeconds)];
    }
    return self;
}

@end

