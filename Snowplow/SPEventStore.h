//
//  SPEventStore.h
//  Snowplow
//
//  Copyright (c) 2013-2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>

@class SPPayload;
@class FMDatabaseQueue;

@interface SPEventStore : NSObject

/**
 *  Basic initializer that creates a database event table (if one does not exist) and then closes the connection.
 *  @return A SnowplowEventStore object.
 */
- (id) init;

/**
 *  Inserts events into the sqlite table for the app identified with it's bundleId (appId).
 *  @param payload A SnowplowPayload instance to be inserted into the database.
 *  @return If the insert was successful, we return the rowId of the inserted entry, otherwise -1. We explicitly do this in the case of an error, sqlite would return the previous successful insert leading to incorrect data removals.
 */
- (long long int) insertEvent:(SPPayload *)payload;

/**
 *  Removes an event from the table with the supplied id.
 *  @param id_ Unique ID of the row in the events table to be deleted.
 *  @return Returns the status of the SQL query sent.
 */
- (BOOL) removeEventWithId:(long long int)id_;

/**
 *  Finds the row in the event table with the supplied ID.
 *  @param id_ Unique ID of the row in the events table to be returned.
 *  @return A dictionary containing data with keys: 'ID', 'eventData', and 'dateCreated'.
 */
- (NSDictionary *) getEventWithId:(long long int)id_;

/**
 *  Removes ALL events in the database. USE WITH CARE!
 */
- (void) removeAllEvents;

/**
 *  Number of events in the database.
 *  @return An integer of the number of events currently in the database.
 */
- (NSUInteger) count;

/**
 *  Returns all the events in an array of dictionaries.
 *  @return An array with each dictionary element containing key-value pairs of 'date', 'data', 'ID'.
 */
- (NSArray *) getAllEvents;

/**
 *  Returns limited number the events that are NOT pending in an array of dictionaries.
 *  @return An array with each dictionary element containing key-value pairs of 'date', 'data', 'ID'.
 */
- (NSArray *) getAllEventsLimited:(NSUInteger)limit;

/**
 *  The row ID of the last insert made.
 *  @return The row ID of the last insert made.
 */
- (long long int) getLastInsertedRowId;

@end
