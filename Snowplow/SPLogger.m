//
//  SPLogger.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPLogger.h"

@interface SPLogger ()
@property (nonatomic, weak) id<SPLoggerDelegate> delegate;
@property (nonatomic, weak) id<SPDiagnosticLogger> errorLogger;
@property (nonatomic) SPLogLevel logLevel;
@end

@implementation SPLogger

+ (void)setLoggerDelegate:(id<SPLoggerDelegate>)delegate {
    SPLogger *logger = [SPLogger shared];
    logger.delegate = delegate;
}

+ (void)setDiagnosticLogger:(id<SPDiagnosticLogger>)diagnosticLogger {
    SPLogger *logger = [SPLogger shared];
    logger.errorLogger = diagnosticLogger;
    if (diagnosticLogger && logger.logLevel == SPLogLevelOff) {
        logger.logLevel = SPLogLevelError;
    }
}

+ (void)setLogLevel:(SPLogLevel)logLevel {
    SPLogger *logger = [SPLogger shared];
    logger.logLevel = logLevel;
    if (logger.errorLogger && logLevel == SPLogLevelOff) {
        #ifdef SNOWPLOW_DEBUG
            logger.logLevel = SPLogLevelDebug;
        #elif DEBUG
            logger.logLevel = SPLogLevelError;
        #else
            logger.logLevel = SPLogLevelOff;
        #endif
    }
}

+ (void)diagnostic:(NSString *)tag message:(NSString *)message errorOrException:(id)errorOrException {
    SPLogger *logger = [SPLogger shared];
    [logger log:SPLogLevelError tag:tag message:message];
    [logger trackErrorWithTag:tag message:message errorOrException:errorOrException];
}

+ (void)error:(NSString *)tag message:(NSString *)message {
    [[SPLogger shared] log:SPLogLevelError tag:tag message:message];
}

+ (void)debug:(NSString *)tag message:(NSString *)message {
    [[SPLogger shared] log:SPLogLevelDebug tag:tag message:message];
}

+ (void)verbose:(NSString *)tag message:(NSString *)message {
    [[SPLogger shared] log:SPLogLevelVerbose tag:tag message:message];
}

#pragma mark - Private methods

+ (SPLogger *)shared {
    static SPLogger *sharedLogger = nil;
    @synchronized(self) {
        if (!sharedLogger) {
            sharedLogger = [[self alloc] init];
            sharedLogger.logLevel = SPLogLevelOff;
        }
    }
    return sharedLogger;
}

- (void)log:(SPLogLevel)level tag:(NSString *)tag message:(NSString *)message {
    if (level > self.logLevel) {
        return;
    }
    if (self.delegate) {
        switch (level) {
            case SPLogLevelOff:
                // do nothing.
                break;
            case SPLogLevelError:
                [self.delegate error:tag message:message];
                break;
            case SPLogLevelDebug:
                [self.delegate debug:tag message:message];
                break;
            case SPLogLevelVerbose:
                [self.delegate verbose:tag message:message];
                break;
        }
        return;
    }
    #if SNOWPLOW_TEST
        // NSLog doesn't work on test target
        NSString *output = [NSString stringWithFormat:@"[%@] %@: %@", @[@"Off", @"Error", @"Error", @"Debug", @"Verbose"][level], tag, message];
        printf("%s", [output UTF8String]);
    #elif DEBUG
        // Log should be printed only during debugging
        NSLog(@"[%@] %@: %@", @[@"Off", @"Error", @"Debug", @"Verbose"][level], tag, message);
    #endif
}

- (void)trackErrorWithTag:(NSString *)tag message:(NSString *)message errorOrException:(id)errorOrException {
    if (self.errorLogger) {
        NSError *error;
        NSException *exception;
        if ([errorOrException isKindOfClass:NSError.class]) {
            error = (NSError *)errorOrException;
        } else if ([errorOrException isKindOfClass:NSException.class]) {
            exception = (NSException *)errorOrException;
        }
        [self.errorLogger logWithTag:tag message:message error:error exception:exception];
    }
}

@end
