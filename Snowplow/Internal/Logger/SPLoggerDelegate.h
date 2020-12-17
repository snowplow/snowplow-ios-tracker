//
//  SPLoggerDelegate.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SPLogLevel) {
    SPLogLevelOff = 0,
    SPLogLevelError,
    SPLogLevelDebug,
    SPLogLevelVerbose,
} NS_SWIFT_NAME(LogLevel);

/*!
 @brief Logger delegate to implement in oder to receive logs from the tracker.
*/
NS_SWIFT_NAME(LoggerDelegate)
@protocol SPLoggerDelegate <NSObject>
- (void)error:(NSString *)tag message:(NSString *)message;
- (void)debug:(NSString *)tag message:(NSString *)message;
- (void)verbose:(NSString *)tag message:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
