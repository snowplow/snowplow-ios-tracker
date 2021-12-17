//
//  SPStateManager.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPStateManager.h"

@interface SPStateManager ()

@property (nonatomic) NSMutableDictionary<NSString *, id<SPStateMachineProtocol>> *identifierToStateMachine;
@property (nonatomic) NSMapTable<id<SPStateMachineProtocol>, NSString *> *stateMachineToIdentifier;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray<id<SPStateMachineProtocol>> *> *eventSchemaToStateMachine;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray<id<SPStateMachineProtocol>> *> *eventSchemaToEntitiesGenerator;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray<id<SPStateMachineProtocol>> *> *eventSchemaToPayloadUpdater;
@property (nonatomic) SPTrackerState *trackerState;

@end

@implementation SPStateManager

- (instancetype)init {
    if (self = [super init]) {
        self.identifierToStateMachine = [NSMutableDictionary new];
        self.stateMachineToIdentifier = [NSMapTable weakToStrongObjectsMapTable];
        self.eventSchemaToStateMachine = [NSMutableDictionary new];
        self.eventSchemaToEntitiesGenerator = [NSMutableDictionary new];
        self.eventSchemaToPayloadUpdater = [NSMutableDictionary new];
        self.trackerState = [SPTrackerState new];
    }
    return self;
}

- (void)addOrReplaceStateMachine:(id<SPStateMachineProtocol>)stateMachine identifier:(NSString *)stateMachineIdentifier {
    @synchronized (self) {
        id<SPStateMachineProtocol> previousStateMachine = [self.identifierToStateMachine objectForKey:stateMachineIdentifier];
        if (previousStateMachine) {
            if ([stateMachine isMemberOfClass:[previousStateMachine class]]) {
                return;
            }
            [self removeStateMachine:stateMachineIdentifier];
        }
        self.identifierToStateMachine[stateMachineIdentifier] = stateMachine;
        [self.stateMachineToIdentifier setObject:stateMachineIdentifier forKey:stateMachine];
        [self addToSchemaRegistry:self.eventSchemaToStateMachine
                          schemas:[stateMachine subscribedEventSchemasForTransitions]
                     stateMachine:stateMachine];
        [self addToSchemaRegistry:self.eventSchemaToEntitiesGenerator
                          schemas:[stateMachine subscribedEventSchemasForEntitiesGeneration]
                     stateMachine:stateMachine];
        [self addToSchemaRegistry:self.eventSchemaToPayloadUpdater
                          schemas:[stateMachine subscribedEventSchemasForPayloadUpdating]
                     stateMachine:stateMachine];
    }
}

- (BOOL)removeStateMachine:(NSString *)stateMachineIdentifier {
    id<SPStateMachineProtocol> stateMachine = self.identifierToStateMachine[stateMachineIdentifier];
    if (!stateMachine) {
        return NO;
    }
    [self.identifierToStateMachine removeObjectForKey:stateMachineIdentifier];
    [self.stateMachineToIdentifier removeObjectForKey:stateMachine];
    [self.trackerState removeStateWithIdentifier:stateMachineIdentifier];
    [self removeFromSchemaRegistry:self.eventSchemaToStateMachine
                           schemas:[stateMachine subscribedEventSchemasForTransitions]
                      stateMachine:stateMachine];
    [self removeFromSchemaRegistry:self.eventSchemaToEntitiesGenerator
                           schemas:[stateMachine subscribedEventSchemasForEntitiesGeneration]
                      stateMachine:stateMachine];
    [self removeFromSchemaRegistry:self.eventSchemaToPayloadUpdater
                           schemas:[stateMachine subscribedEventSchemasForPayloadUpdating]
                      stateMachine:stateMachine];
    return YES;
}

- (id<SPTrackerStateSnapshot>)trackerStateForProcessedEvent:(SPEvent *)event {
    @synchronized (self) {
        if ([event isKindOfClass:SPSelfDescribingAbstract.class]) {
            SPSelfDescribingAbstract *sdEvent = (SPSelfDescribingAbstract *)event;
            NSMutableArray<id<SPStateMachineProtocol>> *stateMachines = self.eventSchemaToStateMachine[sdEvent.schema].mutableCopy ?: [NSMutableArray new];
            [stateMachines addObjectsFromArray:self.eventSchemaToStateMachine[@"*"]];
            for (id<SPStateMachineProtocol> stateMachine in stateMachines) {
                NSString *stateIdentifier = [self.stateMachineToIdentifier objectForKey:stateMachine];
                SPStateFuture *previousStateFuture = [self.trackerState stateFutureWithIdentifier:stateIdentifier];
                SPStateFuture *currentStateFuture = [[SPStateFuture alloc] initWithEvent:sdEvent previousState:previousStateFuture stateMachine:stateMachine];
                [self.trackerState setStateFuture:currentStateFuture identifier:stateIdentifier];
                // TODO: Remove early state computation.
                /*
                The early state-computation causes low performance as it's executed synchronously on
                the track method thread. Ideally, the state computation should be executed only on
                entities generation or payload updating (outputs). In that case there are two problems
                to address:
                 - long chains of StateFuture filling the memory (in case the outputs are not generated)
                 - event object reuse by the user (the event object in the StateFuture could be modified
                   externally)
                 Remove the early state-computation only when these two problems are fixed.
                 */
                [currentStateFuture state]; // Early state-computation
            }
        }
        return self.trackerState.snapshot;
    }
}

- (NSArray<SPSelfDescribingJson *> *)entitiesForProcessedEvent:(id<SPInspectableEvent>)event {
    @synchronized (self) {
        NSMutableArray<SPSelfDescribingJson *> *result = [NSMutableArray new];
        NSMutableArray<id<SPStateMachineProtocol>> *stateMachines = self.eventSchemaToEntitiesGenerator[event.schema].mutableCopy ?: [NSMutableArray new];
        [stateMachines addObjectsFromArray:self.eventSchemaToEntitiesGenerator[@"*"]];
        for (id<SPStateMachineProtocol> stateMachine in stateMachines) {
            NSString *stateIdentifier = [self.stateMachineToIdentifier objectForKey:stateMachine];
            id<SPState> state = [event.state stateWithIdentifier:stateIdentifier];
            NSArray<SPSelfDescribingJson *> *entities = [stateMachine entitiesFromEvent:event state:state];
            if (entities) {
                [result addObjectsFromArray:entities];
            }
        }
        return result;
    }
}

- (BOOL)addPayloadValuesToEvent:(id<SPInspectableEvent>)event {
    @synchronized (self) {
        int failures = 0;
        NSMutableArray<id<SPStateMachineProtocol>> *stateMachines = self.eventSchemaToPayloadUpdater[event.schema] ?: [NSMutableArray new];
        [stateMachines addObjectsFromArray:self.eventSchemaToPayloadUpdater[@"*"]];
        for (id<SPStateMachineProtocol> stateMachine in stateMachines) {
            NSString *stateIdentifier = [self.stateMachineToIdentifier objectForKey:stateMachine];
            id<SPState> state = [event.state stateWithIdentifier:stateIdentifier];
            NSDictionary<NSString *, NSObject *> *payloadValues = [stateMachine payloadValuesFromEvent:event state:state];
            if (payloadValues && ![event addPayloadValues:payloadValues]) {
                failures++;
            }
        }
        return failures == 0;
    }
}

// MARK: - Private methods

- (void)addToSchemaRegistry:(NSMutableDictionary<NSString *, NSMutableArray<id<SPStateMachineProtocol>> *> *)schemaRegistry schemas:(NSArray<NSString *> *)schemas stateMachine:(id<SPStateMachineProtocol>)stateMachine {
    for (NSString *eventSchema in schemas) {
        NSMutableArray *array = schemaRegistry[eventSchema];
        if (!array) {
            array = [NSMutableArray new];
            schemaRegistry[eventSchema] = array;
        }
        [array addObject:stateMachine];
    }
}

- (void)removeFromSchemaRegistry:(NSMutableDictionary<NSString *, NSMutableArray<id<SPStateMachineProtocol>> *> *)schemaRegistry schemas:(NSArray<NSString *> *)schemas stateMachine:(id<SPStateMachineProtocol>)stateMachine {
    for (NSString *eventSchema in schemas) {
        NSMutableArray *array = schemaRegistry[eventSchema];
        [array removeObject:stateMachine];
    }
}

@end
