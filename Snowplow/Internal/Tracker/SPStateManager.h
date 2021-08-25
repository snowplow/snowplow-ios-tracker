//
//  SPStateManager.h
//  Snowplow
//
//  Created by Alex Benini on 20/08/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPStateFuture.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPStateManager : NSObject

- (void)addStateMachine:(id<SPStateMachineProtocol>)stateMachine identifier:(NSString *)stateMachineIdentifier;
- (BOOL)removeStateMachine:(NSString *)stateMachineIdentifier;

- (NSMutableDictionary<NSString *, SPStateFuture *> *)trackerStateByProcessedEvent:(SPEvent *)event;

- (NSArray<SPSelfDescribingJson *> *)entitiesByProcessedEvent:(id<SPInspectableEvent>)event;

@end

NS_ASSUME_NONNULL_END
