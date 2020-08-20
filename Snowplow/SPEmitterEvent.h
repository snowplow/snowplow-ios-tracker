//
//  SPEmitterEvent.h
//  Snowplow
//
//  Created by Alex Benini on 20/08/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPPayload.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPEmitterEvent : NSObject

@property (nonatomic, readonly) SPPayload *payload;
@property (nonatomic, readonly) long storeId;

- (instancetype)initWithPayload:(SPPayload *)payload storeId:(long)storeId;

@end

NS_ASSUME_NONNULL_END
