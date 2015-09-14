//
//  SPEmitter.m
//  Snowplow
//
//  Copyright (c) 2013-2015 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2013-2015 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPEmitter.h"
#import "SPEventStore.h"
#import "SPUtils.h"
#import "SPPayload.h"
#import "SPRequestResponse.h"
#import "SPWeakTimerTarget.h"
#import "FMDB.h"

@interface SPEmitter ()

@property (nonatomic) enum    SPRequestOptions      httpMethod;
@property (nonatomic) enum    SPBufferOptions       bufferOption;
@property (nonatomic, retain) NSURL *               urlEndpoint;
@property (nonatomic)         NSInteger             emitRange;
@property (nonatomic)         NSInteger             emitThreadPoolSize;
@property (nonatomic, weak)   id<SPRequestCallback> callback;

@end

@implementation SPEmitter {
    SPEventStore *     _db;
    NSURL *            _url;
    NSTimer *          _timer;
    BOOL               _isSending;
    NSOperationQueue * _dataOperationQueue;
    BOOL               _builderFinished;
}

// SnowplowEmitter Builder

+ (instancetype) build:(void(^)(id<SPEmitterBuilder>builder))buildBlock {
    SPEmitter* emitter = [SPEmitter new];
    if (buildBlock) {
        buildBlock(emitter);
    }
    [emitter setup];
    return emitter;
}

- (id) init {
    self = [super init];
    if (self) {
        _httpMethod = SPRequestPost;
        _bufferOption = SPBufferDefault;
        _callback = nil;
        _emitRange = 150;
        _emitThreadPoolSize = 15;
        _isSending = NO;
        _db = [[SPEventStore alloc] init];
        _dataOperationQueue = [[NSOperationQueue alloc] init];
        _builderFinished = NO;
    }
    return self;
}

- (void) setup {
    _dataOperationQueue.maxConcurrentOperationCount = _emitThreadPoolSize;
    [self setupUrlEndpoint];
    [self setFutureBufferFlushWithTime:kSPDefaultBufferTimeout];
    _builderFinished = YES;
}

- (void) setupUrlEndpoint {
    if (_url && _url.scheme && _url.host) {
        if (_httpMethod == SPRequestGet) {
            _urlEndpoint = [_url URLByAppendingPathComponent:kSPEndpointGet];
        } else {
            _urlEndpoint = [_url URLByAppendingPathComponent:kSPEndpointPost];
        }
    } else {
        [NSException raise:@"Invalid SPEmitter Endpoint" format:@"An invalid Emitter URL was found: %@", _url];
    }
}

// Required

- (void) setUrlEndpoint:(NSURL *)urlEndpoint {
    _url = urlEndpoint;
    if (_builderFinished) {
        [self setupUrlEndpoint];
    }
}

- (void) setHttpMethod:(enum SPRequestOptions)method {
    _httpMethod = method;
    if (_builderFinished && _urlEndpoint != nil) {
        [self setupUrlEndpoint];
    }
}

- (void) setBufferOption:(enum SPBufferOptions)option {
    _bufferOption = option;
}

- (void) setCallback:(id<SPRequestCallback>)callback {
    _callback = callback;
}

- (void) setEmitRange:(NSInteger)emitRange {
    _emitRange = emitRange;
}

- (void) setEmitThreadPoolSize:(NSInteger)emitThreadPoolSize {
    _emitThreadPoolSize = emitThreadPoolSize;
    if (_dataOperationQueue.maxConcurrentOperationCount != emitThreadPoolSize) {
        _dataOperationQueue.maxConcurrentOperationCount = _emitThreadPoolSize;
    }
}

// Builder Finished

- (void) addPayloadToBuffer:(SPPayload *)spPayload {
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
    if ([SPUtils isOnline] && !_isSending) {
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
    
    if (_httpMethod == SPRequestPost) {
        for (int i = 0; i < listValues.count; i += _bufferOption) {
            NSMutableArray *eventArray = [[NSMutableArray alloc] init];
            NSMutableArray *indexArray = [[NSMutableArray alloc] init];
            double stm = [SPUtils getTimestamp];
            
            for (int j = i; j < (i + _bufferOption) && j < listValues.count; j++) {
                NSMutableDictionary *eventPayload = [[listValues[j] objectForKey:@"eventData"] mutableCopy];
                [eventPayload setValue:[NSString stringWithFormat:@"%.0f", stm] forKey:kSPSentTimestamp];
                [eventArray addObject:eventPayload];
                [indexArray addObject:[listValues[j] objectForKey:@"ID"]];
            }
            
            NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
            [payload setValue:kSPPayloadDataSchema forKey:@"schema"];
            [payload setValue:eventArray forKey:@"data"];
            [self sendSyncRequest:[self getRequestPostWithData:payload] withIndex:indexArray withResultPointer:sendResults];
        }
    } else {
        for (NSDictionary * eventWithMetaData in listValues) {
            NSMutableDictionary *eventPayload = [[eventWithMetaData objectForKey:@"eventData"] mutableCopy];
            [eventPayload setValue:[NSString stringWithFormat:@"%.0f", [SPUtils getTimestamp]] forKey:kSPSentTimestamp];
            
            NSArray *indexArray = [NSArray arrayWithObject:[eventWithMetaData objectForKey:@"ID"]];
            [self sendSyncRequest:[self getRequestGetWithData:eventPayload] withIndex:indexArray withResultPointer:sendResults];
        }
    }
    
    [_dataOperationQueue waitUntilAllOperationsAreFinished];
    
    NSInteger success = 0;
    NSInteger failure = 0;
    
    for (int i = 0; i < sendResults.count; i++) {
        SPRequestResponse * result = [sendResults objectAtIndex:i];
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
        
        @synchronized (results) {
            if ([response statusCode] >= 200 && [response statusCode] < 300) {
                [results addObject:[[SPRequestResponse alloc] initWithBool:true withIndex:indexArray]];
            } else {
                NSLog(@"Error: %@", connectionError);
                [results addObject:[[SPRequestResponse alloc] initWithBool:false withIndex:indexArray]];
            }
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
    [request setValue:kSPAcceptContentHeader forHTTPHeaderField:@"Accept"];
    [request setValue:kSPContentTypeHeader forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    return request;
}

- (NSMutableURLRequest *) getRequestGetWithData:(NSDictionary *)data {
    NSString *url = [NSString stringWithFormat:@"%@?%@", [_urlEndpoint absoluteString], [SPUtils urlEncodeDictionary:data]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:kSPAcceptContentHeader forHTTPHeaderField:@"Accept"];
    return request;
}

// Setters

- (void) setFutureBufferFlushWithTime:(NSInteger)userTime {
    NSInteger time = kSPDefaultBufferTimeout;
    if (userTime <= 300) {
        time = userTime; // 5 minute intervals
    }
    
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _timer = [NSTimer scheduledTimerWithTimeInterval:time
                                                  target:[[SPWeakTimerTarget alloc] initWithTarget:self andSelector:@selector(flushBuffer)]
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    });
}

// Getters

- (NSUInteger) getDbCount {
    return [_db count];
}

- (BOOL) getSendingStatus {
    return _isSending;
}

- (void) dealloc {
    [_timer invalidate];
    _timer = nil;
}

@end
