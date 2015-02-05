//
//  SnowplowEmitter.m
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

#import "SnowplowEmitter.h"
#import "SnowplowEventStore.h"
#import "SnowplowUtils.h"
#import <FMDB.h>
#import <AFNetworking/AFNetworking.h>

@implementation SnowplowEmitter {
    NSURL *                     _urlEndpoint;
    NSString *                  _httpMethod;
    NSMutableArray *            _buffer; // TODO: Convert to counter instead of array
    enum SnowplowBufferOptions  _bufferOption;
    NSTimer *                   _timer;
    SnowplowEventStore *        _db;
    FMDatabaseQueue *           _dbQueue;
}

static int       const kDefaultBufferTimeout = 60;
static NSString *const kPayloadDataSchema    = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0";

- (id) init {
    return [self initWithURLRequest:nil httpMethod:@"POST" bufferOption:SnowplowBufferDefault];
}

- (id) initWithURLRequest:(NSURL *)url {
    return [self initWithURLRequest:url httpMethod:@"POST" bufferOption:SnowplowBufferDefault];
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method {
    return [self initWithURLRequest:url httpMethod:method bufferOption:SnowplowBufferDefault];
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferOption:(enum SnowplowBufferOptions)option {
    self = [super init];
    if(self) {
        _urlEndpoint = url;
        _httpMethod = method;
        _bufferOption = option;
        _buffer = [[NSMutableArray alloc] init];
        _db = [[SnowplowEventStore alloc] init];
        if([method isEqual: @"GET"]) {
            _urlEndpoint = [url URLByAppendingPathComponent:@"/i"];
        } else {
            _urlEndpoint = [url URLByAppendingPathComponent:@"/com.snowplowanalytics.snowplow/tp2"];
        }
        
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [libraryPath stringByAppendingPathComponent:@"snowplowEvents.sqlite"];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        
        [self setBufferTime:kDefaultBufferTimeout];
    }
    return self;
}

- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload {
    [_buffer addObject:spPayload.getPayloadAsDictionary];
    [_db insertEvent:spPayload];
    if([_buffer count] == _bufferOption || [_db count] != 0)
        [self flushBuffer];
}

- (void) addToOutQueue:(SnowplowPayload *)payload {
    [_db insertEvent:payload];
}

- (void) popFromOutQueue {
    [_db removeEventWithId:[_db getLastInsertedRowId]];
}

- (void) setHttpMethod:(NSString *)method {
    _httpMethod = method;
}

- (void) setBufferOption:(enum SnowplowBufferOptions) buffer {
    _bufferOption = buffer;
}

- (void) setBufferTime:(int) userTime {
    int time = kDefaultBufferTimeout;
    if(userTime <= 300) time = userTime; // 5 minute intervals
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(flushBuffer) userInfo:nil repeats:YES];
}

- (void) setUrlEndpoint:(NSURL *) url {
    _urlEndpoint = [url URLByAppendingPathComponent:@"/i"];
}

- (void) flushBuffer {
    DLog(@"Flushing buffer..");
    // Avoid calling flush to send an empty buffer
    if ([_buffer count] == 0 && [_db count] == 0) {
        DLog(@"Database empty. Returning..");
        return;
    }
    
    //Empties the buffer and sends the contents to the collector
    if([_httpMethod isEqual:@"POST"]) {
        
        NSMutableArray *eventArray = [[NSMutableArray alloc] init];
        NSMutableArray *indexArray = [[NSMutableArray alloc] init];
        for (NSDictionary * eventWithMetaData in [_db getAllNonPendingEvents]) {
            [eventArray addObject:[eventWithMetaData objectForKey:@"eventData"]];
            [indexArray addObject:[eventWithMetaData objectForKey:@"ID"]];
            [_db setPendingWithId:(long long int)[eventWithMetaData objectForKey:@"ID"]];
        }
        NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
        [payload setValue:kPayloadDataSchema forKey:@"schema"];
        [payload setValue:eventArray forKey:@"data"];
        
        [self sendPostData:payload withDbIndexArray:indexArray];
    } else if ([_httpMethod isEqual:@"GET"]) {
        
        NSMutableArray *indexArray = [[NSMutableArray alloc] init];
        for (NSDictionary * eventWithMetaData in [_db getAllNonPendingEvents]) {
            [indexArray addObject:[eventWithMetaData objectForKey:@"ID"]];
            [_db setPendingWithId:(long long int)[eventWithMetaData objectForKey:@"ID"]];
            [self sendGetData:[eventWithMetaData objectForKey:@"eventData"] withDbIndexArray:indexArray];
        }
        
    } else {
        DLog(@"Invalid httpMethod provided. Use \"POST\" or \"GET\".");
    }
    [_buffer removeAllObjects];
}

- (void) sendPostData:(NSDictionary *)data withDbIndexArray:(NSMutableArray *)dbIndexArray {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[_urlEndpoint absoluteString] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"JSON: %@", responseObject);
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSMutableArray *removedIDs = [NSMutableArray arrayWithArray:dbIndexArray];
            for (int i=0; i < dbIndexArray.count; i++) {
                DLog(@"Removing event at index: %@", dbIndexArray[i]);
                [_db removeEventWithId:[[dbIndexArray objectAtIndex:i] longLongValue]];
                [removedIDs addObject:dbIndexArray[i]];
            }
            [dbIndexArray removeObjectsInArray:removedIDs];

        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
        for (int i=0; i < dbIndexArray.count;  i++) {
            [_db removePendingWithId:(long long int)dbIndexArray[i]];
        }
    }];
}

- (void) sendGetData:(NSDictionary *)data withDbIndexArray:(NSMutableArray *)dbIndexArray {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/x-www-form-urlencoded", @"text/plain", @"image/gif", nil];
    
    [manager GET:[_urlEndpoint absoluteString] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"JSON: %@", responseObject);
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSMutableArray *removedIDs = [NSMutableArray arrayWithArray:dbIndexArray];
            for (int i=0; i < dbIndexArray.count; i++) {
                DLog(@"Removing event at index: %@", dbIndexArray[i]);
                [_db removeEventWithId:[[dbIndexArray objectAtIndex:i] longLongValue]];
                [removedIDs addObject:dbIndexArray[i]];
            }
            [dbIndexArray removeObjectsInArray:removedIDs];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
        for (int i=0; i < dbIndexArray.count;  i++) {
            [_db removePendingWithId:(long long int)dbIndexArray[i]];
        }
    }];
}

@end
