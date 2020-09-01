//
//  SPRequestResult.m
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPRequestResult.h"

@interface SPRequestResult ()

@property (nonatomic, readwrite) BOOL isSuccessful;
@property (nonatomic, readwrite) NSArray<NSNumber *> *storeIds;

@end

@implementation SPRequestResult

- (instancetype)init {
    return [self initWithSuccess:NO storeIds:@[]];
}

- (instancetype)initWithSuccess:(BOOL)success storeIds:(NSArray<NSNumber *> *)storeIds {
    if (self = [super init]) {
        self.isSuccessful = success;
        self.storeIds = storeIds;
    }
    return self;
}

@end
