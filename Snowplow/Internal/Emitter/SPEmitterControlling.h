//
//  SPEmitterControlling.h
//  Snowplow
//
//  Created by Alex Benini on 03/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEmitterConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(EmitterControlling)
@protocol SPEmitterControlling <SPEmitterConfigurationProtocol>

- (void)flush;

@end

NS_ASSUME_NONNULL_END
