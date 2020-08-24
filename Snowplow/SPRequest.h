//
//  SPRequest.h
//  Snowplow
//
//  Created by Alex Benini on 21/08/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPayload.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPRequest : NSObject

@property (nonatomic,readonly) SPPayload *payload;
@property (nonatomic,readonly) NSArray<NSNumber *> *emitterEventIds;
@property (nonatomic,readonly) BOOL oversize;
@property (nonatomic,readonly) NSString *customUserAgent;

- (instancetype)initWithPayload:(SPPayload *)payload emitterEventId:(long long)emitterEventId;

- (instancetype)initWithPayload:(SPPayload *)payload emitterEventId:(long long)emitterEventId oversize:(BOOL)oversize;

- (instancetype)initWithPayloads:(NSArray<SPPayload *> *)payloads emitterEventIds:(NSArray<NSNumber *> *)emitterEventIds;

@end

NS_ASSUME_NONNULL_END
