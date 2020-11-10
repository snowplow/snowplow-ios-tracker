//
//  SPTrackerError.m
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

#import "SPTrackerError.h"
#import "Snowplow.h"

const int kMaxMessageLength = 2048;
const int kMaxStackLength = 8192;
const int kMaxExceptionNameLength = 1024;

@interface SPTrackerError ()

@property (nonatomic) NSString *source;
@property (nonatomic) NSString *message;
@property (nonatomic) NSError *error;
@property (nonatomic) NSException *exception;

@end

@implementation SPTrackerError

- (instancetype)initWithSource:(NSString *)source message:(NSString *)message {
    return [self initWithSource:source message:message];
}

- (instancetype)initWithSource:(NSString *)source message:(NSString *)message error:(NSError *)error exception:(NSException *)exception {
    if (self = [super init]) {
        self.source = source;
        self.message = message;
        self.error = error;
        self.exception = exception;
    }
    return self;
}

// -- Public methods

- (NSString *)schema {
    return kSPDiagnosticErrorSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:self.source forKey:kSPDiagnosticErrorClassName];
    [payload setValue:[self truncate:self.message maxLength:kMaxMessageLength] forKey:kSPDiagnosticErrorMessage];
    if (self.error) {
        [payload setValue:self.error forKey:kSPDiagnosticErrorExceptionName];
    }
    if (self.exception) {
        [payload setValue:[self truncate:self.exception.name maxLength:kMaxExceptionNameLength] forKey:kSPDiagnosticErrorExceptionName];
        NSArray<NSString *> *symbols = [self.exception callStackSymbols];
        if ([symbols count]) {
            NSString *stackTrace = [NSString stringWithFormat:@"Stacktrace:\n%@", symbols];
            [payload setValue:[self truncate:stackTrace maxLength:kMaxStackLength] forKey:kSPDiagnosticErrorStack];
        }
    }
    return payload;
}

// -- Private methods

- (NSString *)truncate:(NSString *)s maxLength:(int)maxLength {
    return [s substringToIndex:MIN(s.length, maxLength)];
}

@end
