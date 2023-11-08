//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
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

import Foundation

class StateManager {
    private var identifierToStateMachine: [String : StateMachineProtocol] = [:]
    private var eventSchemaToStateMachine: [String : [StateMachineProtocol]] = [:]
    private var eventSchemaToEntitiesGenerator: [String : [StateMachineProtocol]] = [:]
    private var eventSchemaToPayloadUpdater: [String : [StateMachineProtocol]] = [:]
    private var eventSchemaToAfterTrackCallback: [String : [StateMachineProtocol]] = [:]
    private var eventSchemaToFilter: [String : [StateMachineProtocol]] = [:]
    private var trackerState = TrackerState()

    func addOrReplaceStateMachine(_ stateMachine: StateMachineProtocol) {
        if let previousStateMachine = identifierToStateMachine[stateMachine.identifier] {
            if type(of: stateMachine) == type(of: previousStateMachine) {
                return
            }
            let _ = removeStateMachine(stateMachine.identifier)
        }
        identifierToStateMachine[stateMachine.identifier] = stateMachine
        add(
            toSchemaRegistry: &eventSchemaToStateMachine,
            schemas: stateMachine.subscribedEventSchemasForTransitions,
            stateMachine: stateMachine)
        add(
            toSchemaRegistry: &eventSchemaToEntitiesGenerator,
            schemas: stateMachine.subscribedEventSchemasForEntitiesGeneration,
            stateMachine: stateMachine)
        add(
            toSchemaRegistry: &eventSchemaToPayloadUpdater,
            schemas: stateMachine.subscribedEventSchemasForPayloadUpdating,
            stateMachine: stateMachine)
        add(
            toSchemaRegistry: &eventSchemaToAfterTrackCallback,
            schemas: stateMachine.subscribedEventSchemasForAfterTrackCallback,
            stateMachine: stateMachine)
        add(
            toSchemaRegistry: &eventSchemaToFilter,
            schemas: stateMachine.subscribedEventSchemasForFiltering,
            stateMachine: stateMachine)
    }

    func removeStateMachine(_ stateMachineIdentifier: String) -> Bool {
        guard let stateMachine = identifierToStateMachine[stateMachineIdentifier] else {
            return false
        }
        identifierToStateMachine.removeValue(forKey: stateMachineIdentifier)
        trackerState.remove(withIdentifier: stateMachineIdentifier)
        remove(
            fromSchemaRegistry: &eventSchemaToStateMachine,
            schemas: stateMachine.subscribedEventSchemasForTransitions,
            stateMachine: stateMachine)
        remove(
            fromSchemaRegistry: &eventSchemaToEntitiesGenerator,
            schemas: stateMachine.subscribedEventSchemasForEntitiesGeneration,
            stateMachine: stateMachine)
        remove(
            fromSchemaRegistry: &eventSchemaToPayloadUpdater,
            schemas: stateMachine.subscribedEventSchemasForPayloadUpdating,
            stateMachine: stateMachine)
        remove(
            fromSchemaRegistry: &eventSchemaToAfterTrackCallback,
            schemas: stateMachine.subscribedEventSchemasForAfterTrackCallback,
            stateMachine: stateMachine)
        remove(
            fromSchemaRegistry: &eventSchemaToFilter,
            schemas: stateMachine.subscribedEventSchemasForFiltering,
            stateMachine: stateMachine)
        return true
    }

    func trackerState(forProcessedEvent event: Event) -> TrackerStateSnapshot? {
        if let sdEvent = event as? SelfDescribingAbstract {
            var stateMachines = Array(eventSchemaToStateMachine[sdEvent.schema] ?? [])
            stateMachines.append(contentsOf: eventSchemaToStateMachine["*"] ?? [])

            for stateMachine in stateMachines {
                let previousStateFuture = trackerState.stateFuture(withIdentifier: stateMachine.identifier)
                let currentStateFuture = StateFuture(
                    event: sdEvent,
                    previousState: previousStateFuture,
                    stateMachine: stateMachine)
                
                trackerState.setStateFuture(currentStateFuture, identifier: stateMachine.identifier)
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
                _ = currentStateFuture.computeState() // Early state-computation
            }
        }
        return trackerState.snapshot()
    }
    
    func filter(event: InspectableEvent & StateMachineEvent) -> Bool {
        guard let schema = event.schema ?? event.eventName else { return true }
        var stateMachines = eventSchemaToFilter[schema] ?? []
        stateMachines.append(contentsOf: eventSchemaToFilter["*"] ?? [])

        for stateMachine in stateMachines {
            let state = event.state.state(withIdentifier: stateMachine.identifier)
            if let filter = stateMachine.filter(event: event, state: state) {
                if !filter { return false }
            }
        }
        return true
    }

    func entities(forProcessedEvent event: InspectableEvent & StateMachineEvent) -> [SelfDescribingJson] {
        guard let schema = event.schema ?? event.eventName else { return [] }
        var result: [SelfDescribingJson] = []
        var stateMachines = eventSchemaToEntitiesGenerator[schema] ?? []
        stateMachines.append(contentsOf: eventSchemaToEntitiesGenerator["*"] ?? [])

        for stateMachine in stateMachines {
            let state = event.state.state(withIdentifier: stateMachine.identifier)
            if let entities = stateMachine.entities(from: event, state: state) {
                result.append(contentsOf: entities)
            }
        }
        return result
    }

    func addPayloadValues(to event: InspectableEvent & StateMachineEvent) -> Bool {
        guard let schema = event.schema else { return true }
        var failures = 0
        var stateMachines = eventSchemaToPayloadUpdater[schema] ?? []
        stateMachines.append(contentsOf: eventSchemaToPayloadUpdater["*"] ?? [])
        for stateMachine in stateMachines {
            let state = event.state.state(withIdentifier: stateMachine.identifier)
            if let payloadValues = stateMachine.payloadValues(from: event, state: state) {
                if !event.addPayloadValues(payloadValues) {
                    failures += 1
                }
            }
        }
        return failures == 0
    }

    func afterTrack(event: InspectableEvent & StateMachineEvent) {
        guard let schema = event.schema ?? event.eventName else { return }

        var stateMachines = eventSchemaToAfterTrackCallback[schema] ?? []
        stateMachines.append(contentsOf: eventSchemaToAfterTrackCallback["*"] ?? [])

        if !stateMachines.isEmpty {
            DispatchQueue.global(qos: .default).async {
                for stateMachine in stateMachines {
                    stateMachine.afterTrack(event: event)
                }
            }
        }
    }

    // MARK: - Private methods

    private func add(toSchemaRegistry schemaRegistry: inout [String : [StateMachineProtocol]], schemas: [String], stateMachine: StateMachineProtocol?) {
        for eventSchema in schemas {
            var array = schemaRegistry[eventSchema] ?? []
            if let stateMachine = stateMachine {
                array.append(stateMachine)
            }
            schemaRegistry[eventSchema] = array
        }
    }

    private func remove(fromSchemaRegistry schemaRegistry: inout [String : [StateMachineProtocol]], schemas: [String], stateMachine: StateMachineProtocol) {
        for eventSchema in schemas {
            var array = schemaRegistry[eventSchema]
            array?.removeAll { $0.identifier == stateMachine.identifier }
            schemaRegistry[eventSchema] = array
        }
    }
}
