//
//  SPSessionControllerImpl.m
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

#import "SPSessionControllerImpl.h"
#import "SPSession.h"
#import "SPLogger.h"
#import "SPSessionConfigurationUpdate.h"

@implementation SPSessionControllerImpl

@synthesize backgroundTimeoutInSeconds;
@synthesize foregroundTimeoutInSeconds;

- (BOOL)isEnabled {
    return self.session != nil;
}

- (void)pause {
    self.dirtyConfig.isPaused = YES;
    [self.session stopChecker];
}

- (void)resume {
    self.dirtyConfig.isPaused = NO;
    [self.session startChecker];
}

- (void)startNewSession {
    [self.session startNewSession];
}

// MARK: - Properties

- (void)setForegroundTimeout:(NSMeasurement<NSUnitDuration *> *)foregroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    NSMeasurement<NSUnitDuration *> *foreground = [foregroundTimeout measurementByConvertingToUnit:NSUnitDuration.seconds];
    self.foregroundTimeoutInSeconds = floor(foreground.doubleValue);
}

- (void)setForegroundTimeoutInSeconds:(NSInteger)foregroundTimeoutInSeconds {
    self.dirtyConfig.foregroundTimeoutInSeconds = foregroundTimeoutInSeconds;
    self.dirtyConfig.foregroundTimeoutInSecondsUpdated = YES;
    [self.session setForegroundTimeout:foregroundTimeoutInSeconds * 1000];
}

- (void)setBackgroundTimeout:(NSMeasurement<NSUnitDuration *> *)backgroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    NSMeasurement<NSUnitDuration *> *background = [backgroundTimeout measurementByConvertingToUnit:NSUnitDuration.seconds];
    self.backgroundTimeoutInSeconds = floor(background.doubleValue);
}

- (void)setBackgroundTimeoutInSeconds:(NSInteger)backgroundTimeoutInSeconds {
    self.dirtyConfig.backgroundTimeoutInSeconds = backgroundTimeoutInSeconds;
    self.dirtyConfig.backgroundTimeoutInSecondsUpdated = YES;
    [self.session setBackgroundTimeout:backgroundTimeoutInSeconds * 1000];
}

- (NSMeasurement<NSUnitDuration *> *)foregroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    return [[NSMeasurement alloc] initWithDoubleValue:self.foregroundTimeoutInSeconds unit:NSUnitDuration.seconds];
}

- (NSInteger)foregroundTimeoutInSeconds {
    if (!self.isEnabled) {
        SPLogTrack(nil, @"Attempt to access SessionController fields when disabled");
        return -1;
    }
    return floor([self.session getForegroundTimeout] / 1000);
}

- (NSMeasurement<NSUnitDuration *> *)backgroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    return [[NSMeasurement alloc] initWithDoubleValue:self.backgroundTimeoutInSeconds unit:NSUnitDuration.seconds];
}

- (NSInteger)backgroundTimeoutInSeconds {
    if (!self.isEnabled) {
        SPLogTrack(nil, @"Attempt to access SessionController fields when disabled");
        return -1;
    }
    return floor([self.session getBackgroundTimeout] / 1000);
}

- (NSInteger)sessionIndex {
    if (!self.isEnabled) {
        SPLogTrack(nil, @"Attempt to access SessionController fields when disabled");
        return -1;
    }
    return self.session.getSessionIndex;
}

- (NSString *)sessionId {
    if (!self.isEnabled) {
        SPLogTrack(nil, @"Attempt to access SessionController fields when disabled");
        return nil;
    }
    return self.session.getSessionId;
}

- (NSString *)userId {
    if (!self.isEnabled) {
        SPLogTrack(nil, @"Attempt to access SessionController fields when disabled");
        return nil;
    }
    return self.session.getUserId;
}

- (BOOL)isInBackground {
    if (!self.isEnabled) {
        SPLogTrack(nil, @"Attempt to access SessionController fields when disabled");
        return NO;
    }
    return self.session.getInBackground;
}

- (NSInteger)backgroundIndex {
    if (!self.isEnabled) {
        SPLogTrack(nil, @"Attempt to access SessionController fields when disabled");
        return -1;
    }
    return self.session.getBackgroundIndex;
}

- (NSInteger)foregroundIndex {
    if (!self.isEnabled) {
        SPLogTrack(nil, @"Attempt to access SessionController fields when disabled");
        return -1;
    }
    return self.session.getForegroundIndex;
}

// MARK: - Private methods

- (SPSession *)session {
    return self.serviceProvider.tracker.session;
}

- (SPSessionConfigurationUpdate *)dirtyConfig {
    return self.serviceProvider.sessionConfigurationUpdate;
}

@end
