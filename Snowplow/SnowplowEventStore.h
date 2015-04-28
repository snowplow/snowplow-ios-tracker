//
//  SnowplowTracker.m
//  Snowplow
//
//  Copyright (c) 2013-2014 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Jonathan Almeida
//  Copyright: Copyright (c) 2013-2014 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import <Foundation/Foundation.h>
#import "SnowplowPayload.h"

@interface SnowplowEventStore : NSObject

@property (retain) NSString * appId;

/**
 *  Basic initializer that creates a database event table (if one does not exist) and then closes the connection.
 *  @return A SnowplowEventStore object.
 */
- (id) init;

/**
 *  Creates an event table (if one does not exist) within the application data directory using NSLibraryDirectory. This is mainly for internal use.
 *  @return A bool if the SQL statement is executed without errors. (May return YES if executed even though a table already exists).
 */
- (BOOL) createTable;

/**
 *  Inserts events into the sqlite table for the app identified with it's bundleId (appId).
 *  @param payload A SnowplowPayload instance to be inserted into the database.
 *  @return If the insert was successful, we return the rowId of the inserted entry, otherwise -1. We explicitly do this in the case of an error, sqlite would return the previous successful insert leading to incorrect data removals.
 */
- (long long int) insertEvent:(SnowplowPayload *)payload;

/**
 *  Inserts a dictionary into to events table. Mainly used in insertEvent: for SnowplowPayload events.
 *  @param dict An NSDictionary to be inserted into the database.
 *  @return If the insert was successful, we return the rowId of the inserted entry, otherwise -1. We explicitly do this in the case of an error, sqlite would return the previous successful insert leading to incorrect data removals.
 */
- (long long int) insertDicitionaryData:(NSDictionary *)dict;

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
 *  Sets an event as pending with the ID passed in.
 *  @param id_ Unique ID of the row to be marked as pending.
 */
- (BOOL) setPendingWithId:(long long int)id_;

/**
 *  Sets an event as not pending with the ID passed in.
 *  @param id_ Unique ID of the row to remove pending.
 */
- (BOOL) removePendingWithId:(long long int)id_;

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
 *  Returns all the events that are NOT pending in an array of dictionaries.
 *  @return An array with each dictionary element containing key-value pairs of 'date', 'data', 'ID'.
 */
- (NSArray *) getAllNonPendingEvents;

/**
 *  Returns limited number the events that are NOT pending in an array of dictionaries.
 *  @return An array with each dictionary element containing key-value pairs of 'date', 'data', 'ID'.
 */
- (NSArray *) getAllNonPendingEventsLimited:(NSUInteger)limit;

/**
 *  Returns all event data of pending data.
 *  @return An array of event data with pending set as 1.
 */
- (NSArray *) getAllPendingEvents __attribute__((deprecated));

/**
 *  The row ID of the last insert made.
 *  @return The row ID of the last insert made.
 */
- (long long int) getLastInsertedRowId;

@end
