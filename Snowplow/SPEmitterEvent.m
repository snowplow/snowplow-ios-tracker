//
//  SPEmitterEvent.m
//  Snowplow
//
//  Created by Alex Benini on 20/08/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPEmitterEvent.h"

@interface SPEmitterEvent ()

@property (nonatomic, readwrite) SPPayload *payload;
@property (nonatomic, readwrite) long storeId;

@end

@implementation SPEmitterEvent

- (instancetype)initWithPayload:(SPPayload *)payload storeId:(long)storeId {
    if (self = [super init]) {
        self.payload = payload;
        self.storeId = storeId;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"EmitterEvent{ %ld }", self.storeId];
}

@end
