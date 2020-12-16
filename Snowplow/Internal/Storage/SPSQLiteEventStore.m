//
//  SPDefaultEventStore.h
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

#import "Snowplow.h"
#import "SPSQLiteEventStore.h"
#import "SPPayload.h"
#import "SPUtilities.h"
#import "SPLogger.h"

#if SWIFT_PACKAGE
    #import <FMDB.h>
#else
    #import <fmdb/FMDB.h>
#endif

@interface SPSQLiteEventStore ()

@property (nonatomic) NSString *dbPath;
@property (nonatomic) FMDatabaseQueue *queue;
@property NSUInteger sendLimit;

@end

@implementation SPSQLiteEventStore

static NSString * const _queryCreateTable = @"CREATE TABLE IF NOT EXISTS 'events' (id INTEGER PRIMARY KEY, eventData BLOB, dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
static NSString * const _querySelectAll   = @"SELECT * FROM 'events'";
static NSString * const _querySelectCount = @"SELECT Count(*) FROM 'events'";
static NSString * const _queryInsertEvent = @"INSERT INTO 'events' (eventData) VALUES (?)";
static NSString * const _querySelectId    = @"SELECT * FROM 'events' WHERE id=?";
static NSString * const _queryDeleteId    = @"DELETE FROM 'events' WHERE id=?";
static NSString * const _queryDeleteIds   = @"DELETE FROM 'events' WHERE id IN (%@)";
static NSString * const _queryDeleteAll   = @"DELETE FROM 'events'";

- (instancetype)init {
    return [self initWithLimit:250];
}

- (instancetype)initWithLimit:(NSUInteger)limit {
    if (self = [super init]) {
#if SNOWPLOW_TARGET_TV
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
#else
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
#endif
        self.dbPath = [libraryPath stringByAppendingPathComponent:@"snowplowEvents.sqlite"];
        self.queue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
        self.sendLimit = limit;
        [self createTable];
    }
    return self;
}

- (void) dealloc {
    [self.queue close];
}

// MARK: SPEventStore implementation methods

- (void)addEvent:(SPPayload *)payload {
    [self insertDictionaryData:[payload getAsDictionary]];
}

- (BOOL)removeEventWithId:(long long)storeId {
    __block BOOL res = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            SPLogDebug(@"Removing %@ from database now.", [@(storeId) stringValue]);
            res = [db executeUpdate:_queryDeleteId, [NSNumber numberWithLongLong:storeId]];
        }
    }];
    return res;
}

- (BOOL)removeEventsWithIds:(NSArray<NSNumber *> *)storeIds {
    __block BOOL res = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open] && storeIds.count) {
            NSString *ids = [storeIds componentsJoinedByString:@","];
            SPLogDebug(@"Removing [%@] from database now.", ids);
            NSString *query = [NSString stringWithFormat:_queryDeleteIds, ids];
            res = [db executeUpdate:query];
        }
    }];
    return res;
}

- (BOOL)removeAllEvents {
    __block BOOL res = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            SPLogDebug(@"Removing all events from database now.");
            res = [db executeUpdate:_queryDeleteAll];
        }
    }];
    return res;
}

- (NSUInteger)count {
    __block NSUInteger num = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *s = [db executeQuery:_querySelectCount];
            while ([s next]) {
                num = [[NSNumber numberWithInt:[s intForColumnIndex:0]] integerValue];
            }
            [s close];
        }
    }];
    return num;
}

- (NSArray<SPEmitterEvent *> *)emittableEventsWithQueryLimit:(NSUInteger)queryLimit {
    return [self getAllEventsLimited:self.sendLimit];
}

// MARK: SPSQLiteEventStore methods

- (BOOL) createTable {
    __block BOOL res = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            res = [db executeStatements:_queryCreateTable];
        }
    }];
    return res;
}

- (long long int) insertEvent:(SPPayload *)payload {
    return [self insertDictionaryData:[payload getAsDictionary]];
}

- (long long int) insertDictionaryData:(NSDictionary *)dict {
    __block long long int res = -1;
    if (!dict) {
      return res;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            [db executeUpdate:_queryInsertEvent, data];
            res = (long long int) [db lastInsertRowId];
        }
    }];
    return res;
}

- (SPEmitterEvent *) getEventWithId:(long long int)id_ {
    __block SPEmitterEvent *event = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *s = [db executeQuery:_querySelectId, [NSNumber numberWithLongLong:id_]];
            while ([s next]) {
                NSData * data = [s dataForColumn:@"eventData"];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
                SPPayload *payload = [[SPPayload alloc] initWithNSDictionary:dict];
                event = [[SPEmitterEvent alloc] initWithPayload:payload storeId:id_];
            }
            [s close];
        }
    }];
    return event;
}

- (NSArray<SPEmitterEvent *> *)getAllEvents {
    return [self getAllEventsWithQuery:_querySelectAll];
}

- (NSArray<SPEmitterEvent *> *)getAllEventsLimited:(NSUInteger)limit {
    NSString *query = [NSString stringWithFormat:@"%@ LIMIT %@", _querySelectAll, [@(limit) stringValue]];
    return [self getAllEventsWithQuery:query];
}

- (NSArray<SPEmitterEvent *> *) getAllEventsWithQuery:(NSString *)query {
    __block NSMutableArray *res = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *s = [db executeQuery:query];
            while ([s next]) {
                long long int index = [s longLongIntForColumn:@"ID"];
                NSData *data = [s dataForColumn:@"eventData"];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
                SPPayload *payload = [[SPPayload alloc] initWithNSDictionary:dict];
                SPEmitterEvent *event = [[SPEmitterEvent alloc] initWithPayload:payload storeId:index];
                [res addObject:event];
            }
            [s close];
        }
    }];
    return res;
}

- (long long int) getLastInsertedRowId {
    __block long long int res = -1;
    [self.queue inDatabase:^(FMDatabase *db) {
        res = [db lastInsertRowId];
    }];
    return res;
}

@end
