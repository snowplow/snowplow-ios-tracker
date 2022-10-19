//
//  SPMockLoggerDelegate.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Alex Benini, Matus Tomlein
//  License: Apache License Version 2.0
//

#import "SPMockLoggerDelegate.h"

@implementation SPMockLoggerDelegate

- (instancetype)init {
    if (self = [super init]) {
        self.errorLogs = [NSMutableArray new];
        self.debugLogs = [NSMutableArray new];
        self.verboseLogs = [NSMutableArray new];
    }
    return self;
}

- (void)debug:(nonnull NSString *)tag message:(nonnull NSString *)message {
    [self.debugLogs addObject:message];
}

- (void)error:(nonnull NSString *)tag message:(nonnull NSString *)message {
    [self.errorLogs addObject:message];
}

- (void)verbose:(nonnull NSString *)tag message:(nonnull NSString *)message {
    [self.verboseLogs addObject:message];
}

@end
