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
#import "SPDefaultEventStore.h"
#import "SPPayload.h"
#import "SPUtilities.h"
#import "SPLogger.h"

#if SWIFT_PACKAGE
    #import <FMDB.h>
#else
    #import <fmdb/FMDB.h>
#endif

@interface SPDefaultEventStore ()

@property (nonatomic) NSString *dbPath;
@property (nonatomic) FMDatabaseQueue *queue;
@property NSUInteger sendLimit;

@end

@implementation SPDefaultEventStore

static NSString * const _queryCreateTable = @"CREATE TABLE IF NOT EXISTS 'events' (id INTEGER PRIMARY KEY, eventData BLOB, dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
static NSString * const _querySelectAll   = @"SELECT * FROM 'events'";
static NSString * const _querySelectCount = @"SELECT Count(*) FROM 'events'";
static NSString * const _queryInsertEvent = @"INSERT INTO 'events' (eventData) VALUES (?)";
static NSString * const _querySelectId    = @"SELECT * FROM 'events' WHERE id=?";
static NSString * const _queryDeleteId    = @"DELETE FROM 'events' WHERE id=?";

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

- (BOOL)removeEvent:(long long int)storeId {
    __block BOOL res = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            SPLogDebug(@"Removing %@ from database now.", [@(storeId) stringValue]);
            res = [db executeUpdate:_queryDeleteId, [NSNumber numberWithLongLong:storeId]];
        }
    }];
    return res;
}

- (BOOL)removeEvents:(NSArray<NSNumber *> *)storeIds {
    BOOL result = YES;
    for (NSNumber *storeId in storeIds) {
        BOOL localResult = [self removeEventWithId:storeId.longLongValue];
        result &= localResult;
    }
    return result;
}

- (BOOL)removeAllEvents {
    __block BOOL result = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *s = [db executeQuery:_querySelectAll];
            while ([s next]) {
                long long int index = [s longLongIntForColumn:@"ID"];
                [db executeUpdate:_queryDeleteId, [NSNumber numberWithLongLong:index]];
            }
            [s close];
            result = YES;
        }
    }];
    return result;
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

- (NSArray *)emittableEvents {
    return [self getAllEventsLimited:self.sendLimit];
}

// MARK: SPDefaultEventStore methods

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

- (BOOL) removeEventWithId:(long long int)id_ {
    __block BOOL res = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            SPLogDebug(@"Removing %@ from database now.", [@(id_) stringValue]);
            res = [db executeUpdate:_queryDeleteId, [NSNumber numberWithLongLong:id_]];
        }
    }];
    return res;
}

- (NSDictionary *) getEventWithId:(long long int)id_ {
    __block NSDictionary *dict = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *s = [db executeQuery:_querySelectId, [NSNumber numberWithLongLong:id_]];
            while ([s next]) {
                NSData * data = [s dataForColumn:@"eventData"];
                SPLogDebug(@"Item: %@ %@ %@",
                     [NSNumber numberWithInt:[s intForColumn:@"ID"]],
                     [s dateForColumn:@"dateCreated"],
                     [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
            }
            [s close];
        }
    }];
    return dict;
}

- (NSArray *) getAllEvents {
    return [self getAllEventsWithQuery:_querySelectAll];
}

- (NSArray *) getAllEventsLimited:(NSUInteger)limit {
    NSString *query = [NSString stringWithFormat:@"%@ LIMIT %@", _querySelectAll, [@(limit) stringValue]];
    return [self getAllEventsWithQuery:query];
}

- (NSArray *) getAllEventsWithQuery:(NSString *)query {
    __block NSMutableArray *res = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *s = [db executeQuery:query];
            while ([s next]) {
                long long int index = [s longLongIntForColumn:@"ID"];
                NSData * data =[s dataForColumn:@"eventData"];
                NSDate * date = [s dateForColumn:@"dateCreated"];
                SPLogDebug(@"Item: %@ %@ %@",
                     [@(index) stringValue],
                     [date description],
                     [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
                NSMutableDictionary * eventWithSqlMetadata = [[NSMutableDictionary alloc] init];
                [eventWithSqlMetadata setValue:dict forKey:@"eventData"];
                [eventWithSqlMetadata setValue:[NSNumber numberWithLongLong:index] forKey:@"ID"];
                [eventWithSqlMetadata setValue:date forKey:@"dateCreated"];
                [res addObject:eventWithSqlMetadata];
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
