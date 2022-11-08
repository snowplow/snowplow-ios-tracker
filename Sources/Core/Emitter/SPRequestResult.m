//
//  SPRequestResult.m
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
//  Authors: Joshua Beemster
//  License: Apache License Version 2.0
//

#import "SPTrackerConstants.h"
#import "SPRequestResult.h"

@interface SPRequestResult ()

@property (nonatomic, readwrite) NSInteger statusCode;
@property (nonatomic, readwrite) BOOL isOversize;
@property (nonatomic, readwrite) NSArray<NSNumber *> *storeIds;

@end

@implementation SPRequestResult

- (instancetype)init {
    return [self initWithStatusCode:-1 oversize:NO storeIds:@[]];
}

- (instancetype)initWithStatusCode:(NSInteger)statusCode oversize:(BOOL)isOversize storeIds:(NSArray<NSNumber *> *)storeIds {
    if (self = [super init]) {
        self.statusCode = statusCode;
        self.isOversize = isOversize;
        self.storeIds = storeIds;
    }
    return self;
}

- (BOOL)isSuccessful {
    return _statusCode >= 200 && _statusCode < 300;
}

- (BOOL)shouldRetry:(NSDictionary<NSNumber *, NSNumber *> *)customRetryForStatusCodes {
    // don't retry if successful
    if ([self isSuccessful]) {
        return false;
    }

    // don't retry if request is larger than max byte limit
    if ([self isOversize]) {
        return false;
    }

    // status code has a custom retry rule
    NSNumber *code = [NSNumber numberWithInteger:_statusCode];
    if ([customRetryForStatusCodes objectForKey:code]) {
        return [[customRetryForStatusCodes objectForKey:code] boolValue];
    }

    // retry if status code is not in the list of no-retry status codes
    NSArray *dontRetryStatusCodes = @[@400, @401, @403, @410, @422];
    return ![dontRetryStatusCodes containsObject:code];
}

@end
