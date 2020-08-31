//
//  SPEmitterEvent.m
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
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPEmitterEvent.h"

@interface SPEmitterEvent ()

@property (nonatomic, readwrite) SPPayload *payload;
@property (nonatomic, readwrite) long long storeId;

@end

@implementation SPEmitterEvent

- (instancetype)initWithPayload:(SPPayload *)payload storeId:(long long)storeId {
    if (self = [super init]) {
        self.payload = payload;
        self.storeId = storeId;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"EmitterEvent{ %lld }", self.storeId];
}

@end
