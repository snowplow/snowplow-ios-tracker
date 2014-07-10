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

- (id) init;

- (id) initWithAppId:(NSString *)appId;

- (BOOL) createTable;

/**
 * Inserts events into the sqlite table for the app identified with it's bundleId (appId).
 * @param payload A SnowplowPayload instance to be inserted into the database.
 * @return If the insert was successful, we return the rowId of the inserted entry, otherwise -1. We explicitly do this in the case of an error, sqlite would return the previous successful insert leading to incorrect data removals.
 */
- (long long int) insertEvent:(SnowplowPayload *)payload;

- (BOOL) removeEventWithId:(long long int)id_;

- (void) getTable;

- (NSDictionary *) getEventWithId:(long long int)id_;

- (BOOL) removeAllEvents;

- (NSDictionary *) getAllEvents;

- (NSArray *) getAllPendingEvents;

- (long long int) getLastInsertedRowId;

@end
