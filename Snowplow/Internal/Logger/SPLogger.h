//
//  SPLogger.h
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

#import <Foundation/Foundation.h>
#import "SPDiagnosticLogger.h"
#import "SPTracker.h"

#define SPLogTrack(optionalErrorOrException, format, ...) [SPLogger diagnostic:NSStringFromClass(self.class) message:[[NSString alloc] initWithFormat:format, ##__VA_ARGS__] errorOrException:optionalErrorOrException]
#define SPLogError(format, ...) [SPLogger error:NSStringFromClass(self.class) message:[[NSString alloc] initWithFormat:format, ##__VA_ARGS__]]
#define SPLogDebug(format, ...) [SPLogger debug:NSStringFromClass(self.class) message:[[NSString alloc] initWithFormat:format, ##__VA_ARGS__]]
#define SPLogVerbose(format, ...) [SPLogger verbose:NSStringFromClass(self.class) message:[[NSString alloc] initWithFormat:format, ##__VA_ARGS__]]

NS_ASSUME_NONNULL_BEGIN

@interface SPLogger : NSObject

+ (void)setLoggerDelegate:(nullable id<SPLoggerDelegate>)delegate;
+ (void)setDiagnosticLogger:(nullable id<SPDiagnosticLogger>)diagnosticLogger;
+ (void)setLogLevel:(SPLogLevel)logLevel;

+ (void)diagnostic:(NSString *)tag message:(NSString *)message errorOrException:(nullable id)errorOrException;
+ (void)error:(NSString *)tag message:(NSString *)message;
+ (void)debug:(NSString *)tag message:(NSString *)message;
+ (void)verbose:(NSString *)tag message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
