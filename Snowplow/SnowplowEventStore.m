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

static NSString * const _queryCreateTable   = @"CREATE TABLE IF NOT EXISTS 'events' (id INTEGER PRIMARY KEY AUTOINCREMENT, eventData BLOB, pending INTEGER, dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
static NSString * const _querySelectAll     = @"SELECT * FROM 'events'";
static NSString * const _queryInsertEvent   = @"INSERT INTO 'events' (eventData, pending) VALUES (?, 0)";
static NSString * const _querySelectId      = @"SELECT * FROM 'events' WHERE ID=?";
static NSString * const _queryDeleteId      = @"DELETE FROM 'events' WHERE ID=?";


@synthesize appId;

- (id) init {
    self = [super init];
    if(self) {
        self = [self initWithAppId:[SnowplowUtils getAppId]];
    }
    return self;
}

- (id) initWithAppId:(NSString *)appId_ {
    self = [super init];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _dbPath = [libraryPath stringByAppendingPathComponent:@"snowplowEvents.sqlite"];
    if(self){
        _db = [FMDatabase databaseWithPath:_dbPath];
        appId = appId_;
        if([_db open]) {
            NSLog(@"db description: %@", [_db databasePath]);
        } else {
            NSLog(@"Failed to open database. Events in memory will not persist!");
        }
        [_db close];
    }
    return self;
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
    if([_db open]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:[payload getPayloadAsDictionary] options:0 error:nil];
        [_db executeUpdate:_queryInsertEvent, data];
        return [_db lastInsertRowId];
    } else {
        return -1;
    }
}

- (BOOL) deleteEventWithId:(int)id_ {
    if([_db open]) {
        return [_db executeUpdate:_queryDeleteId, [NSNumber numberWithInt:id_]];
    } else {
        return false;
    }
}

- (void) getTable {
    if([_db open]) {
        FMResultSet *s = [_db executeQuery:_querySelectAll];
        while ([s next]) {
            int index = [s intForColumn:@"ID"];
            NSData * data =[s dataForColumn:@"eventData"];
            NSDate * date = [s dateForColumn:@"dateCreated"];
            NSString * actualData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Item: %d %@ %@", index, date, actualData);
        }
    }
}

- (NSDictionary *) getEventWithId:(int)id_ {
    if([_db open]) {
        FMResultSet *s = [_db executeQuery:_querySelectId, [NSNumber numberWithInt:id_]];
        while ([s next]) {
            int index = [s intForColumn:@"ID"];
            NSData * data = [s dataForColumn:@"eventData"];
            NSDate * date = [s dateForColumn:@"dateCreated"];
            NSString * actualData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Item: %d %@ %@", index, date, actualData);
            return [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
        }
    }
    return nil;
}

- (NSArray *) getAllEvents {
    NSMutableArray *res = [[NSMutableArray alloc] init];
    if([_db open]) {
        FMResultSet *s = [_db executeQuery:_querySelectAll];
        while ([s next]) {
            int index = [s intForColumn:@"ID"];
            NSData * data =[s dataForColumn:@"eventData"];
            NSDate * date = [s dateForColumn:@"dateCreated"];
            NSString * actualData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Item: %d %@ %@", index, [date description], actualData);
            [res addObject:[NSJSONSerialization JSONObjectWithData:data options:0 error:0]];
        }
    }
    return res;
}

@end
