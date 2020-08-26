//
//  SPRequest.m
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

#import "SPRequest.h"
#import "Snowplow.h"
#import "SPSelfDescribingJson.h"

@interface SPRequest ()

@property (nonatomic,readwrite) SPPayload *payload;
@property (nonatomic,readwrite) NSArray<NSNumber *> *emitterEventIds;
@property (nonatomic,readwrite) BOOL oversize;
@property (nonatomic,readwrite) NSString *customUserAgent;

@end

@implementation SPRequest

- (instancetype)initWithPayload:(SPPayload *)payload emitterEventId:(long long)emitterEventId {
    return [self initWithPayload:payload emitterEventId:emitterEventId oversize:NO];
}

- (instancetype)initWithPayload:(SPPayload *)payload emitterEventId:(long long)emitterEventId oversize:(BOOL)oversize {
    if (self = [super init]) {
        self.payload = payload;
        self.emitterEventIds = @[[NSNumber numberWithLongLong:emitterEventId]];
        self.customUserAgent = [self userAgentFromPayload:payload];
        self.oversize = oversize;
    }
    return self;
}

- (instancetype)initWithPayloads:(NSArray<SPPayload *> *)payloads emitterEventIds:(NSArray<NSNumber *> *)emitterEventIds {
    if (self = [super init]) {
        NSString *tempUserAgent = nil;
        NSMutableArray<NSDictionary<NSString *, NSObject *> *> *payloadData = [NSMutableArray new];
        for (SPPayload *payload in payloads) {
            [payloadData addObject:[payload getAsDictionary]];
            tempUserAgent = [self userAgentFromPayload:payload];
        }
        SPSelfDescribingJson *payloadBundle = [[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema andData:payloadData];
        self.payload = [[SPPayload alloc] initWithNSDictionary:[payloadBundle getAsDictionary]];
        self.emitterEventIds = emitterEventIds;
        self.customUserAgent = tempUserAgent;
        self.oversize = NO;
    }
    return self;
}

// MARK: Private methods

- (NSString *)userAgentFromPayload:(SPPayload *)payload {
    return (NSString *)[[payload getAsDictionary] valueForKey:kSPUseragent];
}

@end
