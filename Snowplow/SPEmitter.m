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
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPRequestResponse.h"
#import "SPWeakTimerTarget.h"

@interface SPEmitter ()

@property (nonatomic) enum    SPRequestOptions      httpMethod;
@property (nonatomic, retain) NSURL *               urlEndpoint;
@property (nonatomic)         NSInteger             emitRange;
@property (nonatomic)         NSInteger             emitThreadPoolSize;
@property (nonatomic, weak)   id<SPRequestCallback> callback;

@end

@implementation SPEmitter {
    SPEventStore *     _db;
    NSString *         _url;
    NSTimer *          _timer;
    BOOL               _isSending;
    NSOperationQueue * _dataOperationQueue;
    BOOL               _builderFinished;
}

const NSInteger POST_WRAPPER_BYTES = 88;
const NSInteger POST_STM_BYTES = 22;

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
        _protocol = SPHttps;
        _callback = nil;
        _emitRange = 150;
        _emitThreadPoolSize = 15;
        _byteLimitGet = 40000;
        _byteLimitPost = 40000;
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
    [self startTimerFlush];
    _builderFinished = YES;
}

- (void) setupUrlEndpoint {
    NSString * urlPrefix = _protocol == SPHttp ? @"http://" : @"https://";
    NSString * urlSuffix = _httpMethod == SPRequestGet ? kSPEndpointGet : kSPEndpointPost;
    _urlEndpoint = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", urlPrefix, _url, urlSuffix]];
    
    if (_urlEndpoint && _urlEndpoint.scheme && _urlEndpoint.host) {
        SnowplowDLog(@"SPLog: Emitter URL created successfully '%@'", _urlEndpoint);
    } else {
        [NSException raise:@"InvalidSPEmitterEndpoint" format:@"An invalid Emitter URL was found: %@", _url];
    }
}

// Required

- (void) setUrlEndpoint:(NSString *)urlEndpoint {
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

- (void) setProtocol:(enum SPProtocol)protocol {
    _protocol = protocol;
    if (_builderFinished && _urlEndpoint != nil) {
        [self setupUrlEndpoint];
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
    }
}

- (void) setByteLimitGet:(NSInteger)byteLimitGet {
    _byteLimitGet = byteLimitGet;
}

- (void) setByteLimitPost:(NSInteger)byteLimitPost {
    _byteLimitPost = byteLimitPost;
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
    if ([SPUtilities isOnline] && !_isSending) {
        _isSending = YES;
        [self sendEvents];
    }
}

- (void) sendEvents {
    SnowplowDLog(@"SPLog: Sending events...");
    
    if ([self getDbCount] == 0) {
        SnowplowDLog(@"SPLog: Database empty. Returning..");
        _isSending = NO;
        return;
    }
    
    NSArray *listValues = [[NSArray alloc] initWithArray:[_db getAllEventsLimited:_emitRange]];
    NSMutableArray *sendResults = [[NSMutableArray alloc] init];
    
    if (_httpMethod == SPRequestPost) {
        NSMutableArray *eventArray = [[NSMutableArray alloc] init];
        NSMutableArray *indexArray = [[NSMutableArray alloc] init];
        NSInteger totalByteSize = 0;
        
        for (int i = 0; i < listValues.count; i ++) {
            
            // Get the event payload
            NSMutableDictionary *eventPayload = [[listValues[i] objectForKey:@"eventData"] mutableCopy];
            
            // Convert to NSData and check the byte size
            NSData *data = [NSJSONSerialization dataWithJSONObject:eventPayload options:0 error:nil];
            NSInteger payloadByteSize = [SPUtilities getByteSizeWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            payloadByteSize += POST_STM_BYTES;
            
            if ((payloadByteSize + POST_WRAPPER_BYTES) > _byteLimitPost) {
                // Single event exceeds the byte limit so must be sent individually.
                NSMutableArray *singleEventArray = [[NSMutableArray alloc] init];
                NSMutableArray *singleIndexArray = [[NSMutableArray alloc] init];
                
                // Build and Send the event!
                [singleEventArray addObject:eventPayload];
                [singleIndexArray addObject:[listValues[i] objectForKey:@"ID"]];
                
                // Add the STM to the event
                [self addStmToEventPayloadsWithArray:singleEventArray];
                
                SPSelfDescribingJson *payload = [[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema
                                                                                     andData:singleEventArray];
                [self sendEventWithRequest:[self getRequestPostWithData:payload] andIndex:singleIndexArray andResultArray:sendResults andOversize:YES];
            } else if ((totalByteSize + payloadByteSize + POST_WRAPPER_BYTES + (eventArray.count - 1)) > _byteLimitPost) {
                // Add the STM to each event
                [self addStmToEventPayloadsWithArray:eventArray];
                
                // Adding this event to the accumulated array would exceed the limit.
                SPSelfDescribingJson *payload = [[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema
                                                                                     andData:eventArray];
                [self sendEventWithRequest:[self getRequestPostWithData:payload] andIndex:indexArray andResultArray:sendResults andOversize:NO];
                
                // Reset collections and STM
                eventArray = [[NSMutableArray alloc] init];
                indexArray = [[NSMutableArray alloc] init];
                
                // Add event to collections
                [eventArray addObject:eventPayload];
                [indexArray addObject:[listValues[i] objectForKey:@"ID"]];
                
                // Update byte count
                totalByteSize = payloadByteSize;
            } else {
                // Add event to collections
                [eventArray addObject:eventPayload];
                [indexArray addObject:[listValues[i] objectForKey:@"ID"]];
                
                // Update byte count
                totalByteSize += payloadByteSize;
            }
        }
            
        // If we have not sent all of the events...
        if (eventArray.count > 0) {
            // Add the STM to each event
            [self addStmToEventPayloadsWithArray:eventArray];
            
            // Send the event!
            SPSelfDescribingJson *payload = [[SPSelfDescribingJson alloc] initWithSchema:kSPPayloadDataSchema
                                                                                 andData:eventArray];
            [self sendEventWithRequest:[self getRequestPostWithData:payload] andIndex:indexArray andResultArray:sendResults andOversize:NO];
        }
    } else {
        for (NSDictionary * eventWithMetaData in listValues) {
            NSArray *indexArray = [NSArray arrayWithObject:[eventWithMetaData objectForKey:@"ID"]];
            NSMutableDictionary *eventPayload = [[eventWithMetaData objectForKey:@"eventData"] mutableCopy];
            [eventPayload setValue:[NSString stringWithFormat:@"%@", [@([SPUtilities getTimestamp]) stringValue]] forKey:kSPSentTimestamp];
            
            // Make GET URL to send
            NSString *url = [NSString stringWithFormat:@"%@?%@", [_urlEndpoint absoluteString], [SPUtilities urlEncodeDictionary:eventPayload]];
            BOOL oversize = ([SPUtilities getByteSizeWithString:url] > _byteLimitGet);
            
            // Send the request
            [self sendEventWithRequest:[self getRequestGetWithString:url] andIndex:indexArray andResultArray:sendResults andOversize:oversize];
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
            [self processSuccessesWithResults:resultIndexArray];
        } else {
            failure += resultIndexArray.count;
        }
    }
    
    [_dataOperationQueue waitUntilAllOperationsAreFinished];
    
    SnowplowDLog(@"SPLog: Emitter Success Count: %@", [@(success) stringValue]);
    SnowplowDLog(@"SPLog: Emitter Failure Count: %@", [@(failure) stringValue]);
    
    if (_callback != nil) {
        if (failure == 0) {
            [_callback onSuccessWithCount:success];
        } else {
            [_callback onFailureWithCount:failure successCount:success];
        }
    }
    
    [sendResults removeAllObjects];
    
    if (success == 0 && failure > 0) {
        SnowplowDLog(@"SPLog: Ending emitter run as all requests failed...");
        [NSThread sleepForTimeInterval:5];
        _isSending = NO;
        return;
    } else {
        [self sendEvents];
    }
}

- (void) sendEventWithRequest:(NSMutableURLRequest *)request andIndex:(NSArray *)indexArray andResultArray:(NSMutableArray *)results andOversize:(BOOL)oversize {
    [_dataOperationQueue addOperationWithBlock:^{
        NSHTTPURLResponse *response = nil;
        NSError *connectionError = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        @synchronized (results) {
            if (oversize) {
                [results addObject:[[SPRequestResponse alloc] initWithBool:true withIndex:indexArray]];
            } else if ([response statusCode] >= 200 && [response statusCode] < 300) {
                [results addObject:[[SPRequestResponse alloc] initWithBool:true withIndex:indexArray]];
            } else {
                NSLog(@"SPLog: Error: %@", connectionError);
                [results addObject:[[SPRequestResponse alloc] initWithBool:false withIndex:indexArray]];
            }
        }
    }];
}

- (void) processSuccessesWithResults:(NSArray *)indexArray {
    [_dataOperationQueue addOperationWithBlock:^{
        for (int i = 0; i < indexArray.count;  i++) {
            SnowplowDLog(@"SPLog: Removing event at index: %@", [@(i) stringValue]);
            [_db removeEventWithId:[[indexArray objectAtIndex:i] longLongValue]];
        }
    }];
}

- (NSMutableURLRequest *) getRequestPostWithData:(SPSelfDescribingJson *)data {
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:[data getAsDictionary] options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_urlEndpoint absoluteString]]];
    [request setValue:[NSString stringWithFormat:@"%@", [@([requestData length]) stringValue]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:kSPAcceptContentHeader forHTTPHeaderField:@"Accept"];
    [request setValue:kSPContentTypeHeader forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    return request;
}

- (NSMutableURLRequest *) getRequestGetWithString:(NSString *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:kSPAcceptContentHeader forHTTPHeaderField:@"Accept"];
    return request;
}

- (void) addStmToEventPayloadsWithArray:(NSArray *)eventArray {
    NSInteger stm = [SPUtilities getTimestamp];
    for (NSMutableDictionary * event in eventArray) {
        [event setValue:[NSString stringWithFormat:@"%@", [@(stm) stringValue]] forKey:kSPSentTimestamp];
    }
}

// Extra functions

- (void) startTimerFlush {
    if (_timer != nil) {
        [self stopTimerFlush];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _timer = [NSTimer scheduledTimerWithTimeInterval:kSPDefaultBufferTimeout
                                                  target:[[SPWeakTimerTarget alloc] initWithTarget:self andSelector:@selector(flushBuffer)]
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

- (NSUInteger) getDbCount {
    return [_db count];
}

- (BOOL) getSendingStatus {
    return _isSending;
}

- (void) dealloc {
    [self stopTimerFlush];
}

@end
