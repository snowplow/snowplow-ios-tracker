//
//  SPEmitterEventProcessing.h
//  Snowplow
//
//  Created by Alex Benini on 14/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(EmitterControlling)
@protocol SPEmitterEventProcessing

- (void)addPayloadToBuffer:(SPPayload *)eventPayload;
- (void)pause;
- (void)resume;
- (void)flush;

@end

NS_ASSUME_NONNULL_END
