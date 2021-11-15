//
//  SNOWError.m
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
//  Copyright: Copyright © 2021 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SNOWError.h"

#import "SPTrackerConstants.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"


@interface SNOWError ()

@property (nonatomic, readwrite) NSString *message;

@end

@implementation SNOWError

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithMessage:(NSString *)message {
    if (self = [super init]) {
        _message = message;
        [SPUtilities checkArgument:(_message != nil) withMessage:@"Message cannot be nil or empty."];
    }
    return self;
}

// --- Builder Methods

SP_BUILDER_METHOD(NSString *, name)
SP_BUILDER_METHOD(NSString *, stackTrace)

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

@synthesize schema;

@end
