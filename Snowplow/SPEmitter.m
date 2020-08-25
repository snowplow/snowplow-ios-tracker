//
//  SPEmitter.m
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
#import "SPEmitter.h"
#import "SPSQLiteEventStore.h"
#import "SPDefaultNetworkConnection.h"
#import "SPEventStore.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPRequestResponse.h"
#import "SPWeakTimerTarget.h"
#import "SPRequestCallback.h"
#import "SPRequest.h"
#import "SPLogger.h"

@implementation SPEmitter {
    id<SPEventStore> _eventStore;
    id<SPNetworkConnection> _networkConnection;
    NSString *         _url;
    NSTimer *          _timer;
    BOOL               _isSending;
    NSOperationQueue * _dataOperationQueue;
    BOOL               _builderFinished;
}

const NSUInteger POST_WRAPPER_BYTES = 88;

// SnowplowEmitter Builder

+ (instancetype) build:(void(^)(id<SPEmitterBuilder>builder))buildBlock {
    SPEmitter* emitter = [[SPEmitter alloc] initWithDefaultValues];
    if (buildBlock) {
        buildBlock(emitter);
    }
    [emitter setup];
    return emitter;
}

- (instancetype) initWithDefaultValues {
    self = [super init];
    if (self) {
        _httpMethod = SPRequestPost;
        _protocol = SPHttps;
        _callback = nil;
        _emitRange = 150;
        _emitThreadPoolSize = 15;
        _byteLimitGet = 40000;
        _byteLimitPost = 40000;
        _isSending = NO;
        _dataOperationQueue = [[NSOperationQueue alloc] init];
        _builderFinished = NO;
        _customPostPath = nil;
        _eventStore = nil;
        _networkConnection = nil;;
    }
    return self;
}

- (void) setup {
    _eventStore = _eventStore ?: [[SPSQLiteEventStore alloc] init];
    _dataOperationQueue.maxConcurrentOperationCount = _emitThreadPoolSize;
    [self setupNetworkConnection];
    [self startTimerFlush];
    _builderFinished = YES;
}

- (void)setupNetworkConnection {
    if (!_builderFinished && _networkConnection) {
        return;
    }
    __weak __typeof__(self) weakSelf = self;
    _networkConnection = [SPDefaultNetworkConnection build:^(id<SPDefaultNetworkConnectionBuilder> builder) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        [builder setHttpMethod:strongSelf->_httpMethod];
        [builder setProtocol:strongSelf->_protocol];
        [builder setUrlEndpoint:strongSelf->_url];
        [builder setCustomPostPath:strongSelf->_customPostPath];
        [builder setEmitThreadPoolSize:strongSelf->_emitThreadPoolSize];
        [builder setByteLimitGet:strongSelf->_byteLimitGet];
        [builder setByteLimitPost:strongSelf->_byteLimitPost];
    }];
}

// Required

- (void) setUrlEndpoint:(NSString *)urlEndpoint {
    _url = urlEndpoint;
    if (_builderFinished) {
        [self setupNetworkConnection];
    }
}

- (void) setHttpMethod:(SPRequestOptions)method {
    _httpMethod = method;
    if (_builderFinished && _networkConnection) {
        [self setupNetworkConnection];
    }
}

- (void) setProtocol:(SPProtocol)protocol {
    _protocol = protocol;
    if (_builderFinished && _networkConnection) {
        [self setupNetworkConnection];
    }
}

- (void) setCallback:(id<SPRequestCallback>)callback {
    _callback = callback;
}

- (void) setEmitRange:(NSInteger)emitRange {
    if (emitRange > 0) {
        _emitRange = emitRange;
    }
}

- (void) setEmitThreadPoolSize:(NSInteger)emitThreadPoolSize {
    if (emitThreadPoolSize > 0) {
        _emitThreadPoolSize = emitThreadPoolSize;
        if (_dataOperationQueue.maxConcurrentOperationCount != emitThreadPoolSize) {
            _dataOperationQueue.maxConcurrentOperationCount = _emitThreadPoolSize;
        }
        if (_builderFinished && _networkConnection) {
            [self setupNetworkConnection];
        }
    }
}

- (void) setByteLimitGet:(NSInteger)byteLimitGet {
    _byteLimitGet = byteLimitGet;
    if (_builderFinished && _networkConnection) {
        [self setupNetworkConnection];
    }
}

- (void) setByteLimitPost:(NSInteger)byteLimitPost {
    _byteLimitPost = byteLimitPost;
    if (_builderFinished && _networkConnection) {
        [self setupNetworkConnection];
    }
}

- (void) setCustomPostPath:(NSString *)customPath {
    _customPostPath = customPath;
    if (_builderFinished && _networkConnection) {
        [self setupNetworkConnection];
    }
}

- (void)setNetworkConnection:(id<SPNetworkConnection>)networkConnection {
    _networkConnection = networkConnection;
    if (_builderFinished && _networkConnection) {
        [self setupNetworkConnection];
    }
}

- (void)setEventStore:(id<SPEventStore>)eventStore {
    if (!_builderFinished || !_eventStore || [_eventStore count] == 0 ) {
        _eventStore = eventStore;
    }
}

// Builder Finished

- (void) addPayloadToBuffer:(SPPayload *)spPayload {
    __weak __typeof__(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        
        [strongSelf->_eventStore addEvent:spPayload];
        [strongSelf flushBuffer];
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
    if (_isSending) {
        return;
    }
    @synchronized (self) {
        if (!_isSending) {  //$ does it make sense the use of isSending? rather than a serial dispatcher
            _isSending = YES;
            [self attemptEmit];
        }
    }
}

- (void)attemptEmit {
    if (!_eventStore.count) {
        SPLogDebug(@"Database empty. Returning..", nil);  //$ empty limit not implemented?
        _isSending = NO;
        return;
    }
    
    NSArray<SPEmitterEvent *> *events = [_eventStore emittableEventsWithQueryLimit:_emitRange];
    NSArray<SPRequest *> *requests = [self buildRequestsFromEvents:events];
    NSArray<SPRequestResponse *> *sendResults = [_networkConnection sendRequests:requests];
    
    SPLogVerbose(@"Processing emitter results.");
    
    NSInteger successCount = 0;
    NSInteger failureCount = 0;
    NSMutableArray<NSNumber *> *removableEvents = [NSMutableArray new];
    
    for (SPRequestResponse *result in sendResults) {
        NSArray<NSNumber *> *resultIndexArray = [result getIndexArray];
        if ([result getSuccess]) {
            successCount += resultIndexArray.count;
            [removableEvents addObjectsFromArray:resultIndexArray];
        } else {
            failureCount += resultIndexArray.count;
        }
    }

    [self processSuccessesWithResults:removableEvents];
    
    SPLogDebug(@"Success Count: %@", [@(successCount) stringValue]);
    SPLogDebug(@"Failure Count: %@", [@(failureCount) stringValue]);
    
    if (_callback != nil) {
        if (failureCount == 0) {
            [_callback onSuccessWithCount:successCount];
        } else {
            [_callback onFailureWithCount:failureCount successCount:successCount];
        }
    }
    
    if (failureCount > 0 && successCount == 0) {
        SPLogDebug(@"Ending emitter run as all requests failed...", nil);  //$ Create a uniform approach for both Android and iOS!
        [NSThread sleepForTimeInterval:5];
        _isSending = NO;
        return;
    } else {
        [self attemptEmit];
    }
}

- (NSArray<SPRequest *> *)buildRequestsFromEvents:(NSArray<SPEmitterEvent *> *)events {
    NSMutableArray<SPRequest *> *requests = [NSMutableArray new];
    NSNumber *sendingTime = [SPUtilities getTimestamp];
    SPRequestOptions httpMethod = _networkConnection.httpMethod;
    
    if (httpMethod == SPRequestGet) {
        for (SPEmitterEvent *event in events) {
            SPPayload *payload = event.payload;
            [self addSendingTimeToPayload:payload timestamp:sendingTime];
            BOOL oversize = [self isOversize:payload];
            SPRequest *request = [[SPRequest alloc] initWithPayload:payload emitterEventId:event.storeId oversize:oversize];
            [requests addObject:request];
        }
    } else {
        int bufferOption = 1000; //$ temporary - Add bufferOption as new feature!

        for (int i = 0; i < events.count; i += bufferOption) {
            NSMutableArray<SPPayload *> *eventArray = [NSMutableArray new];
            NSMutableArray<NSNumber *> *indexArray = [NSMutableArray new];

            for (int j = i; j < (i + bufferOption) && j < events.count; j++) {
                SPEmitterEvent *event = events[j];
                
                SPPayload *payload = event.payload;
                NSNumber *emitterEventId = @(event.storeId);
                [self addSendingTimeToPayload:payload timestamp:sendingTime];

                if ([self isOversize:payload]) {
                    SPRequest *request = [[SPRequest alloc] initWithPayload:payload emitterEventId:emitterEventId.longLongValue oversize:YES];
                    [requests addObject:request];

                } else if ([self isOversize:payload previousPayloads:eventArray]) {
                    SPRequest *request = [[SPRequest alloc] initWithPayloads:eventArray emitterEventIds:indexArray];
                    [requests addObject:request];

                    // Clear collection and build a new POST
                    eventArray = [NSMutableArray new];
                    indexArray = [NSMutableArray new];
                    
                    // Build and store the request
                    [eventArray addObject:payload];
                    [indexArray addObject:emitterEventId];
                    
                } else {
                    // Add event to collections
                    [eventArray addObject:payload];
                    [indexArray addObject:emitterEventId];
                }
            }
            
            // Check if all payloads have been processed
            if (eventArray.count) {
                SPRequest *request = [[SPRequest alloc] initWithPayloads:eventArray emitterEventIds:indexArray];
                [requests addObject:request];
            }
        }
    }
    return requests;
}

- (BOOL)isOversize:(SPPayload *)payload {
    return [self isOversize:payload previousPayloads:[NSArray array]];
}

- (BOOL)isOversize:(SPPayload *)payload previousPayloads:(NSArray<SPPayload *> *)previousPayloads {
    NSUInteger byteLimit = _networkConnection.httpMethod == SPRequestGet ? _byteLimitGet : _byteLimitPost;
    return [self isOversize:payload byteLimit:byteLimit previousPayloads:previousPayloads];
}

- (BOOL)isOversize:(SPPayload *)payload byteLimit:(NSUInteger)byteLimit previousPayloads:(NSArray<SPPayload *> *)previousPayloads {
    NSUInteger totalByteSize = payload.byteSize;
    for (SPPayload *previousPayload in previousPayloads) {
        totalByteSize += previousPayload.byteSize;
    }
    NSUInteger wrapperBytes = previousPayloads.count > 0 ? (previousPayloads.count + POST_WRAPPER_BYTES) : 0;
    return totalByteSize + wrapperBytes > byteLimit;
}

- (void) processSuccessesWithResults:(NSArray *)indexArray { //$ To move in the SQLiteEventStore !?
    __weak __typeof__(self) weakSelf = self;
    [_dataOperationQueue addOperationWithBlock:^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        SPLogDebug(@"Removing event at index: %@", indexArray);
        [strongSelf->_eventStore removeEventsWithIds:indexArray];
    }];
    [_dataOperationQueue waitUntilAllOperationsAreFinished]; //$ Do we need this if the FMDatabaseQueue is serial?
}

- (void)addSendingTimeToPayload:(SPPayload *)payload timestamp:(NSNumber *)timestamp {
    [payload addValueToPayload:[NSString stringWithFormat:@"%lld", timestamp.longLongValue] forKey:kSPSentTimestamp];
}

// Extra functions

- (void) startTimerFlush {
    __weak __typeof__(self) weakSelf = self;
    
    if (_timer != nil) {
        [self stopTimerFlush];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        
        strongSelf->_timer = [NSTimer scheduledTimerWithTimeInterval:kSPDefaultBufferTimeout
                                                  target:[[SPWeakTimerTarget alloc] initWithTarget:strongSelf andSelector:@selector(flushBuffer)]
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    });
}

- (void) stopTimerFlush {
    [_timer invalidate];
    _timer = nil;
}

// Getters

- (NSURL *)urlEndpoint {
    return _networkConnection.url;
}

- (NSUInteger) getDbCount {
    return [_eventStore count];
}

- (BOOL) getSendingStatus {
    return _isSending;
}

- (void) dealloc {
    [self stopTimerFlush];
}

@end
