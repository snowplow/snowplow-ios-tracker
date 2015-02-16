//
//  SnowplowEventStore.h
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

#import "SnowplowEventStore.h"
#import "SnowplowPayload.h"
#import "SnowplowUtils.h"
#import <FMDB.h>

@implementation SnowplowEventStore {
    @private
    NSString *      _dbPath;
    FMDatabase *    _db;
}

static NSString * const _queryCreateTable       = @"CREATE TABLE IF NOT EXISTS 'events' (id INTEGER PRIMARY KEY, eventData BLOB, pending INTEGER, dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
static NSString * const _querySelectAll         = @"SELECT * FROM 'events'";
static NSString * const _querySelectCount       = @"SELECT Count(*) FROM 'events'";
static NSString * const _queryInsertEvent       = @"INSERT INTO 'events' (eventData, pending) VALUES (?, 0)";
static NSString * const _querySelectId          = @"SELECT * FROM 'events' WHERE id=?";
static NSString * const _queryDeleteId          = @"DELETE FROM 'events' WHERE id=?";
static NSString * const _querySelectPending     = @"SELECT * FROM 'events' WHERE pending=1";
static NSString * const _querySelectNonPending  = @"SELECT * FROM 'events' WHERE pending=0";
static NSString * const _querySetPending        = @"UPDATE events SET pending=1 WHERE id=?";
static NSString * const _querySetNonPending     = @"UPDATE events SET pending=0 WHERE id=?";


@synthesize appId;

- (id) init {
    self = [super init];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _dbPath = [libraryPath stringByAppendingPathComponent:@"snowplowEvents.sqlite"];
    if(self){
        _db = [FMDatabase databaseWithPath:_dbPath];
        if([_db open]) {
            DLog(@"db description: %@", [_db databasePath]);
            [self createTable];
        } else {
            DLog(@"Failed to open database. Events in memory will not persist!");
        }
        [_db close];
    }
    return self;
}

- (void) dealloc {
    [_db close];
}

- (BOOL) createTable {
    if([_db open]) {
        // Create table if not exists
        return [_db executeStatements:_queryCreateTable];
    } else {
        return false;
    }
}

- (long long int) insertEvent:(SnowplowPayload *)payload {
    return [self insertDicitionaryData:[payload getPayloadAsDictionary]];
}

- (long long int) insertDicitionaryData:(NSDictionary *)dict {
    if([_db open]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        [_db executeUpdate:_queryInsertEvent, data];
        return (long long int) [_db lastInsertRowId];
    } else {
        return -1;
    }
}

- (BOOL) removeEventWithId:(long long int)id_ {
    if([_db open]) {
        DLog(@"Removing %lld from database now.", id_);
        return [_db executeUpdate:_queryDeleteId, [NSNumber numberWithLongLong:id_]];
    } else {
        return false;
    }
}

- (void) removeAllEvents {
    if ([_db open]) {
        FMResultSet *s = [_db executeQuery:_querySelectAll];
        while ([s next]) {
            long long int index = [s longLongIntForColumn:@"ID"];
            [self removeEventWithId:index];
        }
    }
}

- (BOOL) setPendingWithId:(long long int)id_ {
    if ([_db open]) {
        return [_db executeUpdate:_querySetPending, id_];
    } else {
        return false;
    }
}

- (BOOL) removePendingWithId:(long long int)id_ {
    if ([_db open]) {
        return [_db executeUpdate:_querySetPending, id_];
    } else {
        return false;
    }
}

- (NSUInteger) count {
    NSUInteger num = 0;
    if ([_db open]) {
        FMResultSet *s = [_db executeQuery:_querySelectCount];
        while ([s next]) {
            num = [[NSNumber numberWithInt:[s intForColumnIndex:0]] integerValue];
        }
    }
    return num;
}

- (NSDictionary *) getEventWithId:(long long int)id_ {
    if([_db open]) {
        FMResultSet *s = [_db executeQuery:_querySelectId, [NSNumber numberWithLongLong:id_]];
        while ([s next]) {
            int index = [s intForColumn:@"ID"];
            NSData * data = [s dataForColumn:@"eventData"];
            NSDate * date = [s dateForColumn:@"dateCreated"];
            NSString * actualData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DLog(@"Item: %d %@ %@", index, date, actualData);
            return [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
        }
    }
    return nil;
}

- (NSArray *) getAllEvents {
    return [self getAllEventsWithQuery:_querySelectAll];
}

- (NSArray *) getAllNonPendingEvents {
    return [self getAllEventsWithQuery:_querySelectNonPending];
}

- (NSArray *) getAllPendingEvents {
    NSMutableArray *res = [[NSMutableArray alloc] init];
    if([_db open]) {
        FMResultSet *s = [_db executeQuery:_querySelectPending];
        while ([s next]) {
            [res addObject:[s dataForColumn:@"eventData"]];
        }
    }
    return res;
}

- (NSArray *) getAllEventsWithQuery:(NSString *)query {
    NSMutableArray *res = [[NSMutableArray alloc] init];
    if([_db open]) {
        FMResultSet *s = [_db executeQuery:query];
        while ([s next]) {
            long long int index = [s longLongIntForColumn:@"ID"];
            NSData * data =[s dataForColumn:@"eventData"];
            NSDate * date = [s dateForColumn:@"dateCreated"];
            NSString * actualData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DLog(@"Item: %lld %@ %@", index, [date description], actualData);
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
            NSMutableDictionary * eventWithSqlMetadata = [[NSMutableDictionary alloc] init];
            [eventWithSqlMetadata setValue:dict forKey:@"eventData"];
            [eventWithSqlMetadata setValue:[NSNumber numberWithLongLong:index] forKey:@"ID"];
            [eventWithSqlMetadata setValue:date forKey:@"dateCreated"];
            [res addObject:eventWithSqlMetadata];
        }
    }
    return res;
}

- (long long int) getLastInsertedRowId {
    return (long long int) [_db lastInsertRowId];
}

@end
