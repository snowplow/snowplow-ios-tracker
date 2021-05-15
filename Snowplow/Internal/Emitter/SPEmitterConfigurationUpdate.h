//
//  SPEmitterConfigurationUpdate.h
//  Snowplow
//
//  Created by Alex Benini on 15/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPEmitterConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPEmitterConfigurationUpdate : SPEmitterConfiguration

SP_DIRTYFLAG(bufferOption)

SP_DIRTYFLAG(byteLimitGet)
SP_DIRTYFLAG(byteLimitPost)
SP_DIRTYFLAG(emitRange)
SP_DIRTYFLAG(threadPoolSize)

@end

NS_ASSUME_NONNULL_END
