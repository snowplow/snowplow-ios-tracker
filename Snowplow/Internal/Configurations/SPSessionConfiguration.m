//
//  SPSessionConfiguration.m
//  Snowplow
//
//  Created by Alex Benini on 29/11/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPSessionConfiguration.h"

@implementation SPSessionConfiguration

@synthesize foregroundTimeoutInSeconds;
@synthesize backgroundTimeoutInSeconds;

- (instancetype)init {
    return [self initWithForegroundTimeoutInSeconds:1800 backgroundTimeoutInSeconds:1800];
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

- (id)copyWithZone:(NSZone *)zone {
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

