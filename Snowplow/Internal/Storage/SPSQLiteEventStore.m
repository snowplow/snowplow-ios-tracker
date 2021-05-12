//
//  SPDefaultEventStore.h
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPTrackerConstants.h"
#import "SPSQLiteEventStore.h"
#import "SPPayload.h"
#import "SPUtilities.h"
#import "SPJSONSerialization.h"
#import "SPLogger.h"

#if SWIFT_PACKAGE
    #import <FMDB.h>
#else
    #import <fmdb/FMDB.h>
#endif

@interface SPSQLiteEventStore ()

@property (nonatomic) NSString *namespace;
@property (nonatomic) NSString *sqliteFilename;
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

+ (NSArray<NSString *> *)removeUnsentEventsExceptForNamespaces:(NSArray<NSString *> *)allowedNamespaces {
#if SNOWPLOW_TARGET_TV
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
#else
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
#endif
    NSString *snowplowDirPath = [libraryPath stringByAppendingPathComponent:@"snowplow"];
    NSArray<NSString *> *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:snowplowDirPath error:nil];
    NSMutableArray<NSString *> *allowedFiles = [NSMutableArray new];
    for (NSString *namespace in allowedNamespaces) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+" options:0 error:nil];
        NSString *sqliteSuffix = [regex stringByReplacingMatchesInString:namespace options:0 range:NSMakeRange(0, namespace.length) withTemplate:@"-"];
        NSString *sqliteFilename = [NSString stringWithFormat:@"snowplowEvents-%@.sqlite", sqliteSuffix];
        [allowedFiles addObject:sqliteFilename];
    }
    NSMutableArray<NSString *> *removedFiles = [NSMutableArray new];
    for (NSString *file in files) {
        if (![allowedFiles containsObject:file]) {
            NSString *pathToRemove = [snowplowDirPath stringByAppendingPathComponent:file];
            [NSFileManager.defaultManager removeItemAtPath:pathToRemove error:nil];
            [removedFiles addObject:file];
        }
    }
    return removedFiles.copy;
}

- (instancetype)initWithNamespace:(NSString *)namespace {
    return [self initWithNamespace:namespace limit:250];
}

- (instancetype)initWithNamespace:(NSString *)namespace limit:(NSUInteger)limit {
    if (self = [super init]) {
        self.namespace = namespace;
        self.sendLimit = limit;

#if SNOWPLOW_TARGET_TV
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
#else
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
#endif
        // Create snowplow subdirectory if it doesn't exist
        NSString *snowplowDirPath = [libraryPath stringByAppendingPathComponent:@"snowplow"];
        [[NSFileManager defaultManager] createDirectoryAtPath:snowplowDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        // Create path for the database
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+" options:0 error:nil];
        NSString *sqliteSuffix = [regex stringByReplacingMatchesInString:namespace options:0 range:NSMakeRange(0, namespace.length) withTemplate:@"-"];
        self.sqliteFilename = [NSString stringWithFormat:@"snowplowEvents-%@.sqlite", sqliteSuffix];
        self.dbPath = [snowplowDirPath stringByAppendingPathComponent:self.sqliteFilename];

        // Migrate old database if it exists
        NSString *oldDbPath = [libraryPath stringByAppendingPathComponent:@"snowplowEvents.sqlite"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:oldDbPath]) {
            [[NSFileManager defaultManager] moveItemAtPath:oldDbPath toPath:self.dbPath error:nil];
        }

        // Create database
        self.queue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
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
            NSData *data = [SPJSONSerialization serializeDictionary:dict];
            if (!data) {
                return;
            }
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
                NSData *data = [s dataForColumn:@"eventData"];
                NSDictionary *dict = [SPJSONSerialization deserializeData:data];
                if (!dict) {
                    continue;
                }
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
                NSDictionary *dict = [SPJSONSerialization deserializeData:data];
                if (!dict) {
                    continue;
                }
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
