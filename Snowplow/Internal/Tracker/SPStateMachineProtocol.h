//
//  SPStateMachineProtocol.h
//  Snowplow
//
//  Created by Alex Benini on 23/08/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEventBase.h"

@protocol SPState <NSObject>
@end

NS_ASSUME_NONNULL_BEGIN

@protocol SPStateMachineProtocol <NSObject>

- (NSArray<NSString *> *)subscribedEventSchemasForTransitions;
- (NSArray<NSString *> *)subscribedEventSchemasForEntitiesGeneration;
- (NSArray<NSString *> *)subscribedEventSchemasForPayloadUpdating;

- (nullable id<SPState>)transitionFromEvent:(SPEvent *)event currentState:(nullable id<SPState>)currentState;

- (nullable NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(nullable id<SPState>)state;

- (nullable NSDictionary<NSString *, NSObject *> *)payloadValuesFromEvent:(id<SPInspectableEvent>)event state:(nullable id<SPState>)state;

@end

NS_ASSUME_NONNULL_END
