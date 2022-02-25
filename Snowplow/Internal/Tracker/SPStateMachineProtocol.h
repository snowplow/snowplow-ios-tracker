//
//  SPStateMachineProtocol.h
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.
//
//  Authors: Alex Benini
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPEventBase.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SPStateMachineProtocol <NSObject>

- (NSArray<NSString *> *)subscribedEventSchemasForTransitions;
- (NSArray<NSString *> *)subscribedEventSchemasForEntitiesGeneration;
- (NSArray<NSString *> *)subscribedEventSchemasForPayloadUpdating;

- (nullable id<SPState>)transitionFromEvent:(SPEvent *)event state:(nullable id<SPState>)state;

- (nullable NSArray<SPSelfDescribingJson *> *)entitiesFromEvent:(id<SPInspectableEvent>)event state:(nullable id<SPState>)state;

- (nullable NSDictionary<NSString *, NSObject *> *)payloadValuesFromEvent:(id<SPInspectableEvent>)event state:(nullable id<SPState>)state;

@end

NS_ASSUME_NONNULL_END
