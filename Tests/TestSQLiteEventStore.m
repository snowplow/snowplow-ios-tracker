//
//  TestSQLiteEventStore.m
//  Snowplow
//
//  Copyright (c) 2013-2022 Snowplow Analytics Ltd. All rights reserved.
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
//  License: Apache License Version 2.0
//

#import <XCTest/XCTest.h>
#import "SPSQLiteEventStore.h"
#import "SPPayload.h"

@interface TestSQLiteEventStore : XCTestCase
@end

@implementation TestSQLiteEventStore

- (void)setUp {
    [SPSQLiteEventStore removeUnsentEventsExceptForNamespaces:@[]];
}

- (void)testInit {
    SPSQLiteEventStore * eventStore = [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace"];
    XCTAssertNotNil(eventStore);
}

- (void)testInsertPayload {
    SPSQLiteEventStore * eventStore = [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace"];
    [eventStore removeAllEvents];
    
    // Build an event
    SPPayload * payload = [[SPPayload alloc] init];
    [payload addValueToPayload:@"pv"                 forKey:@"e"];
    [payload addValueToPayload:@"www.foobar.com"     forKey:@"url"];
    [payload addValueToPayload:@"Welcome to foobar!" forKey:@"page"];
    [payload addValueToPayload:@"MEEEE"              forKey:@"refr"];
    
    // Insert an event
    [eventStore insertEvent:payload];
    
    XCTAssertEqual([eventStore count], 1);
    XCTAssertEqualObjects([[eventStore getEventWithId:1].payload getAsDictionary], [payload getAsDictionary]);
    XCTAssertEqual([eventStore getLastInsertedRowId], 1);
    [eventStore removeEventWithId:1];
    
    XCTAssertEqual([eventStore count], 0);
}

- (void)testInsertManyPayloads {
    SPSQLiteEventStore * eventStore = [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace"];
    [eventStore removeAllEvents];
    
    // Build an event
    SPPayload * payload = [[SPPayload alloc] init];
    [payload addValueToPayload:@"pv"                 forKey:@"e"];
    [payload addValueToPayload:@"www.foobar.com"     forKey:@"url"];
    [payload addValueToPayload:@"Welcome to foobar!" forKey:@"page"];
    [payload addValueToPayload:@"MEEEE"              forKey:@"refr"];
    
    for (int i = 0; i < 250; i++) {
        [eventStore insertEvent:payload];
    }
    
    XCTAssertEqual([eventStore count], 250);
    XCTAssertEqual([eventStore getAllEventsLimited:600].count, 250);
    XCTAssertEqual([eventStore getAllEventsLimited:150].count, 150);
    XCTAssertEqual([eventStore getAllEvents].count, 250);
    
    [eventStore removeAllEvents];
    XCTAssertEqual([eventStore count], 0);
}

- (void)testSQLiteEventStoreCreateSQLiteFile {
    [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace"];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *snowplowDirPath = [libraryPath stringByAppendingPathComponent:@"snowplow"];
    NSString *dbPath = [snowplowDirPath stringByAppendingPathComponent:@"snowplowEvents-aNamespace.sqlite"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:dbPath]);
}

- (void)testSQLiteEventStoreRemoveFiles {
    [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace1"];
    [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace2"];
    [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace3"];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *snowplowDirPath = [libraryPath stringByAppendingPathComponent:@"snowplow"];
    [SPSQLiteEventStore removeUnsentEventsExceptForNamespaces:@[@"aNamespace2"]];
    NSString *dbPath = [snowplowDirPath stringByAppendingPathComponent:@"snowplowEvents-aNamespace1.sqlite"];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:dbPath]);
    dbPath = [snowplowDirPath stringByAppendingPathComponent:@"snowplowEvents-aNamespace2.sqlite"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:dbPath]);
    dbPath = [snowplowDirPath stringByAppendingPathComponent:@"snowplowEvents-aNamespace3.sqlite"];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:dbPath]);
}

- (void)testSQLiteEventStoreInvalidNamespaceConversion {
    [[SPSQLiteEventStore alloc] initWithNamespace:@"namespace*.^?1ò2@"];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *snowplowDirPath = [libraryPath stringByAppendingPathComponent:@"snowplow"];
    NSString *dbPath = [snowplowDirPath stringByAppendingPathComponent:@"snowplowEvents-namespace-1-2-.sqlite"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:dbPath]);
}

- (void)testMigrationFromLegacyToNamespacedEventStore {
    SPSQLiteEventStore *eventStore = [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace"];
    [eventStore addEvent:[[SPPayload alloc] initWithNSDictionary:@{@"key": @"value"}]];
    XCTAssertEqual(1, [eventStore count]);
    
    // Create fake legacy database
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *snowplowDirPath = [libraryPath stringByAppendingPathComponent:@"snowplow"];
    NSString *newDbPath = [snowplowDirPath stringByAppendingPathComponent:@"snowplowEvents-aNamespace.sqlite"];
    NSString *oldDbPath = [libraryPath stringByAppendingPathComponent:@"snowplowEvents.sqlite"];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:oldDbPath]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:newDbPath]);
    [[NSFileManager defaultManager] moveItemAtPath:newDbPath toPath:oldDbPath error:nil];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:oldDbPath]);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:newDbPath]);
    
    // Migrate database when SQLiteEventStore is launched the first time
    eventStore = [[SPSQLiteEventStore alloc] initWithNamespace:@"aNewNamespace"];
    newDbPath = [snowplowDirPath stringByAppendingPathComponent:@"snowplowEvents-aNewNamespace.sqlite"];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:oldDbPath]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:newDbPath]);
    XCTAssertEqual(1, [eventStore count]);
    for (SPEmitterEvent *event in [eventStore getAllEvents]) {
        XCTAssertEqualObjects(@"value", [[event.payload getAsDictionary] objectForKey:@"key"]);
    }
}

- (void)testMultipleAccessToSameSQLiteFile {
    SPSQLiteEventStore *eventStore1 = [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace"];
    [eventStore1 addEvent:[[SPPayload alloc] initWithNSDictionary:@{@"key1": @"value1"}]];
    XCTAssertEqual(1, [eventStore1 count]);

    SPSQLiteEventStore *eventStore2 = [[SPSQLiteEventStore alloc] initWithNamespace:@"aNamespace"];
    [eventStore2 addEvent:[[SPPayload alloc] initWithNSDictionary:@{@"key2": @"value2"}]];
    XCTAssertEqual(2, [eventStore2 count]);
}

@end
