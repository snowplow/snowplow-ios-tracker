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
#import "SnowplowUtils.h"
#import <FMDB.h>

@implementation SnowplowEventStore {
    NSString *_dbPath;
    FMDatabase *_db;
}

- (id) init {
    self = [super init];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _dbPath = [libraryPath stringByAppendingPathComponent:@"snowplowEvents.sqlite"];
    if(self){
        _db = [FMDatabase databaseWithPath:_dbPath];
        
        if([_db open]) {
            NSLog(@"db description: %@", [_db databasePath]);
        } else {
            NSLog(@"Shit happened");
        }
        [_db close];
    }
    return self;
}

- (Boolean) createTableWithBundleId:(NSString *)bundleId {
    Boolean tableExists = false;
    
    if([_db open]) {
        // Create table if not exists
        [_db executeQuery:@""];
    }
    
    return tableExists;
}

@end
