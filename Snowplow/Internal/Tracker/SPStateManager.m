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
@property (nonatomic) NSMutableDictionary<NSString *, SPStateFuture *> *stateIdentifierToCurrentState;

@end

@implementation SPStateManager

- (instancetype)init {
    if (self = [super init]) {
        self.identifierToStateMachine = [NSMutableDictionary new];
        self.stateMachineToIdentifier = [NSMapTable weakToStrongObjectsMapTable];
        self.eventSchemaToStateMachine = [NSMutableDictionary new];
        self.eventSchemaToEntitiesGenerator = [NSMutableDictionary new];
        self.eventSchemaToPayloadUpdater = [NSMutableDictionary new];
        self.stateIdentifierToCurrentState = [NSMutableDictionary new];
    }
    return self;
}

- (void)addStateMachine:(id<SPStateMachineProtocol>)stateMachine identifier:(NSString *)stateMachineIdentifier {
    @synchronized (self) {
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
    [self.stateIdentifierToCurrentState removeObjectForKey:stateMachineIdentifier];
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

- (NSDictionary<NSString *, SPStateFuture *> *)trackerStateByProcessedEvent:(SPEvent *)event {
    @synchronized (self) {
        if ([event isKindOfClass:SPSelfDescribingAbstract.class]) {
            SPSelfDescribingAbstract *sdEvent = (SPSelfDescribingAbstract *)event;
            NSMutableArray<id<SPStateMachineProtocol>> *stateMachines = self.eventSchemaToStateMachine[sdEvent.schema] ?: [NSMutableArray new];
            [stateMachines addObjectsFromArray:self.eventSchemaToStateMachine[@"*"]];
            for (id<SPStateMachineProtocol> stateMachine in stateMachines) {
                NSString *stateIdentifier = [self.stateMachineToIdentifier objectForKey:stateMachine];
                SPStateFuture *previousState = self.stateIdentifierToCurrentState[stateIdentifier];
                SPStateFuture *newState = [[SPStateFuture alloc] initWithEvent:sdEvent previousState:previousState stateMachine:stateMachine];
                self.stateIdentifierToCurrentState[stateIdentifier] = newState;
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
                [newState state]; // Early state-computation
            }
        }
        return [self.stateIdentifierToCurrentState copy];
    }
}

- (NSArray<SPSelfDescribingJson *> *)entitiesByProcessedEvent:(id<SPInspectableEvent>)event {
    @synchronized (self) {
        NSMutableArray<SPSelfDescribingJson *> *result = [NSMutableArray new];
        NSMutableArray<id<SPStateMachineProtocol>> *stateMachines = self.eventSchemaToEntitiesGenerator[event.schema] ?: [NSMutableArray new];
        [stateMachines addObjectsFromArray:self.eventSchemaToEntitiesGenerator[@"*"]];
        for (id<SPStateMachineProtocol> stateMachine in stateMachines) {
            NSString *stateIdentifier = [self.stateMachineToIdentifier objectForKey:stateMachine];
            SPStateFuture *stateFuture = [event.state objectForKey:stateIdentifier];
            NSArray<SPSelfDescribingJson *> *entities = [stateMachine entitiesFromEvent:event state:stateFuture.state];
            if (entities) {
                [result addObjectsFromArray:entities];
            }
        }
        return result;
    }
}

- (BOOL)addPayloadValuesForEvent:(id<SPInspectableEvent>)event {
    @synchronized (self) {
        int failures = 0;
        NSMutableArray<id<SPStateMachineProtocol>> *stateMachines = self.eventSchemaToPayloadUpdater[event.schema] ?: [NSMutableArray new];
        [stateMachines addObjectsFromArray:self.eventSchemaToPayloadUpdater[@"*"]];
        for (id<SPStateMachineProtocol> stateMachine in stateMachines) {
            NSString *stateIdentifier = [self.stateMachineToIdentifier objectForKey:stateMachine];
            SPStateFuture *stateFuture = [event.state objectForKey:stateIdentifier];
            NSDictionary<NSString *, NSObject *> *payloadValues = [stateMachine payloadValuesFromEvent:event state:stateFuture.state];
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
