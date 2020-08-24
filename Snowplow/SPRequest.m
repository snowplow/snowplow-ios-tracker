//
//  SPRequest.m
//  Snowplow
//
//  Created by Alex Benini on 21/08/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
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
    return (NSString *)[[payload getAsDictionary] valueForKey:kSPUseragent];  //$ Check if it works - On Android too!
}

@end
