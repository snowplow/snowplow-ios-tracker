//
//  SPEventStore.h
//  Snowplow
//
//  Created by Alex Benini on 20/08/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPPayload.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SPEventStore <NSObject>

/**
 * Adds an event to the store.
 * @param payload the payload to be added
 */
- (void)addEvent:(SPPayload *)payload;

/**
 * Removes an event from the store.
 * @param storeId the identifier of the event in the store.
 * @return a boolean of success to remove.
 */
- (BOOL)removeEventWithId:(long long int)storeId;

/**
 * Removes a range of events from the store.
 * @param storeIds the events' identifiers in the store.
 * @return a boolean of success to remove.
 */
- (BOOL)removeEventsWithIds:(NSArray<NSNumber *> *)storeIds;

/**
 * Empties the store of all the events.
 * @return a boolean of success to remove.
 */
- (BOOL)removeAllEvents;

/**
 * Returns amount of events currently in the store.
 * @return the count of events in the store.
 */
- (NSUInteger)count;

/**
 * Returns a list of EmitterEvent objects which contains events and related ids.
 * @param queryLimit is the maximum number of events returned.
 * @return EmitterEvent objects containing storeIds and event payloads.
 */
- (NSArray *)emittableEventsWithQueryLimit:(NSUInteger)queryLimit;

@end

NS_ASSUME_NONNULL_END
