//
//  SPState.h
//  Snowplow
//
//  Created by Alex Benini on 26/06/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPStateMachineProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPStateFuture : NSObject

@property (readonly, atomic) id<SPState> state;

- (instancetype)initWithEvent:(SPEvent *)event previousState:(SPStateFuture *)previousState stateMachine:(id<SPStateMachineProtocol>)stateMachine;

@end

NS_ASSUME_NONNULL_END
