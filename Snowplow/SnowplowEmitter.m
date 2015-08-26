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

#import "Snowplow.h"
#import "SnowplowEmitter.h"
#import "SnowplowEventStore.h"
#import "SnowplowUtils.h"
#import "SnowplowPayload.h"
#import "RequestResponse.h"
#import <FMDB.h>

@implementation SnowplowEmitter {
    NSURL *                     _urlEndpoint;
    enum SnowplowRequestOptions _httpMethod;
    enum SnowplowBufferOptions  _bufferOption;
    NSInteger                   _emitRange;
    NSInteger                   _emitThreadPoolSize;
    NSTimer *                   _timer;
    SnowplowEventStore *        _db;
    NSOperationQueue *          _dataOperationQueue;
}

static int       const kDefaultBufferTimeout = 60;
static NSString *const kPayloadDataSchema    = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-3";
static NSString *const kAcceptContentHeader  = @"text/html, application/x-www-form-urlencoded, text/plain, image/gif";
static NSString *const kContentTypeHeader    = @"application/json; charset=utf-8";

// SnowplowEmitter Builder

+ (instancetype) build:(void(^)(id<SnowplowEmitterBuilder>builder))buildBlock {
    SnowplowEmitter* emitter = [SnowplowEmitter new];
    if (buildBlock) {
        buildBlock(emitter);
    }
    [emitter setup];
    return emitter;
}

- (id) init {
    self = [super init];
    if (self) {
        _httpMethod = SnowplowRequestPost;
        _bufferOption = SnowplowBufferDefault;
        _callback = nil;
        _emitRange = 150;
        _emitThreadPoolSize = 15;
        _isSending = NO;
        _db = [[SnowplowEventStore alloc] init];
        _dataOperationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void) setup {
    _dataOperationQueue.maxConcurrentOperationCount = _emitThreadPoolSize;
    
    if (_httpMethod == SnowplowRequestGet) {
        _urlEndpoint = [_urlEndpoint URLByAppendingPathComponent:@"/i"];
    } else {
        _urlEndpoint = [_urlEndpoint URLByAppendingPathComponent:@"/com.snowplowanalytics.snowplow/tp2"];
    }
    
    [self setNewBufferTime:kDefaultBufferTimeout];
}

// Required

- (void) setURL:(NSURL *)url {
    _urlEndpoint = url;
}

// Optional

- (void) setHttpMethod:(enum SnowplowRequestOptions)method {
    _httpMethod = method;
}

- (void) setBufferOption:(enum SnowplowBufferOptions)option {
    _bufferOption = option;
}

- (void) setCallback:(id<RequestCallback>)callback {
    _callback = callback;
}

- (void) setEmitRange:(NSInteger)emitRange {
    _emitRange = emitRange;
}

- (void) setEmitThreadPoolSize:(NSInteger)emitThreadPoolSize {
    _emitThreadPoolSize = emitThreadPoolSize;
}

// Builder Finished

- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_db insertEvent:spPayload];
        [self flushBuffer];
    });
}

- (void) flushBuffer {
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendGuard];
        });
    } else {
        [self sendGuard];
    }
}

- (void) sendGuard {
    if ([SnowplowUtils isOnline] && !_isSending) {
        _isSending = YES;
        [self sendEvents];
    }
}

- (void) sendEvents {
    SnowplowDLog(@"Sending events...");
    
    if ([self getDbCount] == 0) {
        SnowplowDLog(@"Database empty. Returning..");
        _isSending = NO;
        return;
    }
    
    NSArray *listValues = [[NSArray alloc] initWithArray:[_db getAllEventsLimited:_emitRange]];
    NSMutableArray *sendResults = [[NSMutableArray alloc] init];
    
    if (_httpMethod == SnowplowRequestPost) {
        for (int i = 0; i < listValues.count; i += _bufferOption) {
            NSMutableArray *eventArray = [[NSMutableArray alloc] init];
            NSMutableArray *indexArray = [[NSMutableArray alloc] init];
            double stm = [SnowplowUtils getTimestamp];
            
            for (int j = i; j < (i + _bufferOption) && j < listValues.count; j++) {
                NSMutableDictionary *eventPayload = [[listValues[j] objectForKey:@"eventData"] mutableCopy];
                [eventPayload setValue:[NSString stringWithFormat:@"%.0f", stm] forKey:@"stm"];
                [eventArray addObject:eventPayload];
                [indexArray addObject:[listValues[j] objectForKey:@"ID"]];
            }
            
            NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
            [payload setValue:kPayloadDataSchema forKey:@"schema"];
            [payload setValue:eventArray forKey:@"data"];
            [self sendSyncRequest:[self getRequestPostWithData:payload] withIndex:indexArray withResultPointer:sendResults];
        }
    } else if (_httpMethod == SnowplowRequestGet) {
        for (NSDictionary * eventWithMetaData in listValues) {
            NSMutableDictionary *eventPayload = [[eventWithMetaData objectForKey:@"eventData"] mutableCopy];
            [eventPayload setValue:[NSString stringWithFormat:@"%.0f", [SnowplowUtils getTimestamp]] forKey:@"stm"];
            
            NSArray *indexArray = [NSArray arrayWithObject:[eventWithMetaData objectForKey:@"ID"]];
            [self sendSyncRequest:[self getRequestGetWithData:eventPayload] withIndex:indexArray withResultPointer:sendResults];
        }
    } else {
        NSLog(@"Invalid httpMethod provided. Use \"POST\" or \"GET\".");
        [NSThread sleepForTimeInterval:5];
        _isSending = NO;
        return;
    }
    
    [_dataOperationQueue waitUntilAllOperationsAreFinished];
    
    NSInteger success = 0;
    NSInteger failure = 0;
    
    for (int i = 0; i < sendResults.count; i++) {
        RequestResponse * result = [sendResults objectAtIndex:i];
        NSArray * resultIndexArray = [result getIndexArray];
        
        if ([result getSuccess]) {
            success += resultIndexArray.count;
            [self processSuccessResult:resultIndexArray];
        } else {
            failure += resultIndexArray.count;
        }
    }
    
    [_dataOperationQueue waitUntilAllOperationsAreFinished];
    
    SnowplowDLog(@"Success Count: %@", success);
    SnowplowDLog(@"Failure Count: %@", failure);
    
    if (_callback != nil) {
        if (failure == 0) {
            [_callback onSuccessWithCount:success];
        } else {
            [_callback onFailureWithCount:failure successCount:success];
        }
    }
    
    [sendResults removeAllObjects];
    
    if (success == 0 && failure > 0) {
        SnowplowDLog(@"Ending emitter run as all requests failed...");
        
        // Required to allow all send results to be properly de-allocated
        // Sleep also prevents excessive work if device is not able to send
        [NSThread sleepForTimeInterval:5];
        _isSending = NO;
        return;
    } else {
        [self sendEvents];
    }
}

- (void) sendSyncRequest:(NSMutableURLRequest *)request withIndex:(NSArray *)indexArray withResultPointer:(NSMutableArray *)results {
    [_dataOperationQueue addOperationWithBlock:^{
        NSHTTPURLResponse *response = nil;
        NSError *connectionError = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        if ([response statusCode] >= 200 && [response statusCode] < 300) {
            [results addObject:[[RequestResponse alloc] initWithBool:true withIndex:indexArray]];
        } else {
            NSLog(@"Error: %@", connectionError);
            [results addObject:[[RequestResponse alloc] initWithBool:false withIndex:indexArray]];
        }
    }];
}

- (void) processSuccessResult:(NSArray *)indexArray {
    [_dataOperationQueue addOperationWithBlock:^{
        for (int i = 0; i < indexArray.count;  i++) {
            SnowplowDLog(@"Removing event at index: %@", indexArray[i]);
            [_db removeEventWithId:[[indexArray objectAtIndex:i] longLongValue]];
        }
    }];
}

- (NSMutableURLRequest *) getRequestPostWithData:(NSDictionary *)data {
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_urlEndpoint absoluteString]]];
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:kAcceptContentHeader forHTTPHeaderField:@"Accept"];
    [request setValue:kContentTypeHeader forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    return request;
}

- (NSMutableURLRequest *) getRequestGetWithData:(NSDictionary *)data {
    NSString *url = [NSString stringWithFormat:@"%@?%@", [_urlEndpoint absoluteString], [SnowplowUtils urlEncodeDictionary:data]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:kAcceptContentHeader forHTTPHeaderField:@"Accept"];
    return request;
}

// Setters

- (void) setNewHttpMethod:(enum SnowplowRequestOptions)method {
    _httpMethod = method;
}

- (void) setNewBufferOption:(enum SnowplowBufferOptions)buffer {
    _bufferOption = buffer;
}

- (void) setNewBufferTime:(int) userTime {
    int time = kDefaultBufferTimeout;
    if (userTime <= 300) {
        time = userTime; // 5 minute intervals
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(flushBuffer) userInfo:nil repeats:YES];
}

// Getters

- (NSUInteger) getDbCount {
    return [_db count];
}

- (BOOL) getSendingStatus {
    return _isSending;
}

@end
