//
//  SNOWError.m
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

#import "SNOWError.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"

@implementation SNOWError {
    NSString * _name;
    NSString * _stackTrace;
    NSString * _message;
}

+ (instancetype) build:(void(^)(id<SPErrorBuilder>builder))buildBlock {
    SNOWError * event = [SNOWError new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:(_message != nil) withMessage:@"Message cannot be nil or empty."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setMessage:(NSString *)message {
    _message = message;
}

- (void) setStackTrace:(NSString *)stackTrace {
    _stackTrace = stackTrace;
}

- (void) setName:(NSString *)name {
    _name = name;
}

// --- Public Methods

- (NSString *)schema {
    return kSPErrorSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setValue:_message forKey:kSPErrorMessage];
    [payload setValue:_stackTrace forKey:kSPErrorStackTrace];
    [payload setValue:_name forKey:kSPErrorName];
    [payload setValue:@"OBJECTIVEC" forKey:kSPErrorLanguage];
    return payload;
}

- (SPSelfDescribingJson *) getPayload {
    SPPayload * event = [[SPPayload alloc] init];
    [event addValueToPayload:_message forKey:kSPErrorMessage];
    [event addValueToPayload:_stackTrace forKey:kSPErrorStackTrace];
    [event addValueToPayload:_name forKey:kSPErrorName];
    [event addValueToPayload:@"OBJECTIVEC" forKey:kSPErrorLanguage];
    
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPErrorSchema andPayload:event];
}

@synthesize schema;

@end
