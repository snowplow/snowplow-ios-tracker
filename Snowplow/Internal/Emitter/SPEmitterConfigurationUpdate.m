//
//  SPEmitterConfigurationUpdate.m
//  Snowplow
//
//  Created by Alex Benini on 15/05/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPEmitterConfigurationUpdate.h"

@implementation SPEmitterConfigurationUpdate

- (id<SPEventStore>)eventStore { return self.sourceConfig.eventStore; }
- (id<SPRequestCallback>)requestCallback { return self.sourceConfig.requestCallback; }

SP_DIRTY_GETTER(SPBufferOption, bufferOption)
SP_DIRTY_GETTER(NSInteger, emitRange)
SP_DIRTY_GETTER(NSInteger, threadPoolSize)
SP_DIRTY_GETTER(NSInteger, byteLimitGet)
SP_DIRTY_GETTER(NSInteger, byteLimitPost)

@end
