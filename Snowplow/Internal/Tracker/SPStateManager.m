//
//  SPStateManager.m
//  Snowplow
//
//  Created by Alex Benini on 20/08/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPStateManager.h"

@interface SPStateManager ()

@property (nonatomic) NSMutableDictionary<NSString *, id<SPStateMachineProtocol>> *identifierToStateMachine;
@property (nonatomic) NSMapTable<id<SPStateMachineProtocol>, NSString *> *stateMachineToIdentifier;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray<id<SPStateMachineProtocol>> *> *eventSchemaToStateMachine;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray<id<SPStateMachineProtocol>> *> *eventSchemaToEntitiesGenerator;
@property (nonatomic) NSMutableDictionary<NSString *, SPStateFuture *> *stateIdentifierToCurrentState;

@end

@implementation SPStateManager

- (instancetype)init {
    if (self = [super init]) {
        self.identifierToStateMachine = [NSMutableDictionary new];
        self.stateMachineToIdentifier = [NSMapTable weakToStrongObjectsMapTable];
        self.eventSchemaToStateMachine = [NSMutableDictionary new];
        self.eventSchemaToEntitiesGenerator = [NSMutableDictionary new];
        self.stateIdentifierToCurrentState = [NSMutableDictionary new];
    }
    return self;
}

- (void)addStateMachine:(id<SPStateMachineProtocol>)stateMachine identifier:(NSString *)stateMachineIdentifier {
    @synchronized (self) {
        self.identifierToStateMachine[stateMachineIdentifier] = stateMachine;
        [self.stateMachineToIdentifier setObject:stateMachineIdentifier forKey:stateMachine];
        for (NSString *eventSchema in [stateMachine subscribedEventSchemasForTransitions]) {
            NSMutableArray *array = self.eventSchemaToStateMachine[eventSchema];
            if (!array) {
                array = [NSMutableArray new];
                self.eventSchemaToStateMachine[eventSchema] = array;
            }
            [array addObject:stateMachine];
        }
        for (NSString *eventSchema in [stateMachine subscribedEventSchemasForEntitiesGeneration]) {
            NSMutableArray *array = self.eventSchemaToEntitiesGenerator[eventSchema];
            if (!array) {
                array = [NSMutableArray new];
                self.eventSchemaToEntitiesGenerator[eventSchema] = array;
            }
            [array addObject:stateMachine];
        }
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
    for (NSString *eventSchema in [stateMachine subscribedEventSchemasForTransitions]) {
        NSMutableArray *array = self.eventSchemaToStateMachine[eventSchema];
        [array removeObject:stateMachine];
    }
    for (NSString *eventSchema in [stateMachine subscribedEventSchemasForEntitiesGeneration]) {
        NSMutableArray *array = self.eventSchemaToEntitiesGenerator[eventSchema];
        [array removeObject:stateMachine];
    }
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
                if (newState) {
                    self.stateIdentifierToCurrentState[stateIdentifier] = newState;
                } else {
                    [self.stateIdentifierToCurrentState removeObjectForKey:stateIdentifier];
                }
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
            [result addObjectsFromArray:entities];
        }
        return result;
    }
}

@end
