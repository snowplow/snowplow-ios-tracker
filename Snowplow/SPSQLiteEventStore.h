//
//  SPSQLiteEventStore.h
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida, Joshua Beemster
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SPEventStore.h"
#import "SPEmitterEvent.h"

@class SPPayload;
@class FMDatabaseQueue;

@interface SPSQLiteEventStore :NSObject <SPEventStore>

/**
 *  Basic initializer that creates a database event table (if one does not exist) and then closes the connection.
 */
- (instancetype)init;

/**
 *  Inserts events into the sqlite table for the app identified with it's bundleId (appId).
 *  @param payload A SnowplowPayload instance to be inserted into the database.
 *  @return If the insert was successful, we return the rowId of the inserted entry, otherwise -1. We explicitly do this in the case of an error, sqlite would return the previous successful insert leading to incorrect data removals.
 */
- (long long int)insertEvent:(SPPayload *)payload;

/**
 *  Finds the row in the event table with the supplied ID.
 *  @param id_ Unique ID of the row in the events table to be returned.
 *  @return A dictionary containing data with keys: 'ID', 'eventData', and 'dateCreated'.
 */
- (SPEmitterEvent *)getEventWithId:(long long int)id_;

/**
 *  Returns all the events in an array of dictionaries.
 *  @return An array with each dictionary element containing key-value pairs of 'date', 'data', 'ID'.
 */
- (NSArray<SPEmitterEvent *> *)getAllEvents;

/**
 *  Returns limited number the events that are NOT pending in an array of dictionaries.
 *  @return An array with each dictionary element containing key-value pairs of 'date', 'data', 'ID'.
 */
- (NSArray<SPEmitterEvent *> *)getAllEventsLimited:(NSUInteger)limit;

/**
 *  The row ID of the last insert made.
 *  @return The row ID of the last insert made.
 */
- (long long int)getLastInsertedRowId;

@end
