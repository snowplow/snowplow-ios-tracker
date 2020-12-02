//
//  SPSessionController.m
//  Snowplow
//
//  Created by Alex Benini on 01/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPSessionController.h"
#import "SPSession.h"

@interface SPSessionController ()

@property (nonatomic) SPSession *sessionManager;

@end


@implementation SPSessionController

@synthesize backgroundTimeoutInSeconds;
@synthesize foregroundTimeoutInSeconds;

- (instancetype)initWithSession:(SPSession *)sessionManager {
    if (self = [super init]) {
        self.sessionManager = sessionManager;
    }
    return self;
}

- (void)pause {
    [self.sessionManager stopChecker];
}

- (void)resume {
    [self.sessionManager startChecker];
}

- (void)startNewSession {
    [self.sessionManager startNewSession];
}

// MARK: - Properties

- (void)setForegroundTimeout:(NSMeasurement<NSUnitDuration *> *)foregroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    NSMeasurement<NSUnitDuration *> *foreground = [foregroundTimeout measurementByConvertingToUnit:NSUnitDuration.seconds];
    self.foregroundTimeoutInSeconds = floor(foreground.doubleValue);
}

- (void)setForegroundTimeoutInSeconds:(NSInteger)foregroundTimeoutInSeconds {
    [self.sessionManager setForegroundTimeout:foregroundTimeoutInSeconds * 1000];
}

- (void)setBackgroundTimeout:(NSMeasurement<NSUnitDuration *> *)backgroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    NSMeasurement<NSUnitDuration *> *background = [backgroundTimeout measurementByConvertingToUnit:NSUnitDuration.seconds];
    self.backgroundTimeoutInSeconds = floor(background.doubleValue);
}

- (void)setBackgroundTimeoutInSeconds:(NSInteger)backgroundTimeoutInSeconds {
    [self.sessionManager setBackgroundTimeout:backgroundTimeoutInSeconds * 1000];
}

- (NSMeasurement<NSUnitDuration *> *)foregroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    return [[NSMeasurement alloc] initWithDoubleValue:self.foregroundTimeoutInSeconds unit:NSUnitDuration.seconds];
}

- (NSInteger)foregroundTimeoutInSeconds {
    return floor([self.sessionManager getForegroundTimeout] / 1000);
}

- (NSMeasurement<NSUnitDuration *> *)backgroundTimeout
API_AVAILABLE(ios(10), macosx(10.12), tvos(10.0), watchos(3.0))
{
    return [[NSMeasurement alloc] initWithDoubleValue:self.backgroundTimeoutInSeconds unit:NSUnitDuration.seconds];
}

- (NSInteger)backgroundTimeoutInSeconds {
    return floor([self.sessionManager getBackgroundTimeout] / 1000);
}

- (NSInteger)sessionIndex {
    return self.sessionManager.getSessionIndex;
}

- (NSString *)sessionId {
    return self.sessionManager.getSessionId;
}

- (NSString *)userId {
    return self.sessionManager.getUserId;
}

@end
