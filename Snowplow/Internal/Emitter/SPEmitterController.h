//
//  SPEmitterController.h
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEmitterControlling.h"
#import "SPEmitter.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(EmitterController)
@interface SPEmitterController : NSObject <SPEmitterControlling>

- (instancetype)initWithEmitter:(SPEmitter *)emitter;

@end

NS_ASSUME_NONNULL_END
