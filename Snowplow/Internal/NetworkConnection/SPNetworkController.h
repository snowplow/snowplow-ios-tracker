//
//  SPNetworkController.h
//  Snowplow
//
//  Created by Alex Benini on 14/12/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPNetworkControlling.h"
#import "SPEmitter.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(NetworkController)
@interface SPNetworkController : NSObject <SPNetworkControlling>

- (instancetype)initWithEmitter:(SPEmitter *)emitter;

@end

NS_ASSUME_NONNULL_END

