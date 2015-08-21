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

@interface SnowplowEmitter()
@property BOOL isSending;
@property (nonatomic, weak) id<RequestCallback> callback;
@end

@implementation SnowplowEmitter {
    NSURL *                     _urlEndpoint;
    NSString *                  _httpMethod;
    enum SnowplowBufferOptions  _bufferOption;
    NSTimer *                   _timer;
    SnowplowEventStore *        _db;
    NSOperationQueue *          _dataOperationQueue;
}

static int       const kDefaultBufferTimeout = 60;
static NSString *const kPayloadDataSchema    = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0";

- (id) init {
    return [self initWithURLRequest:nil httpMethod:@"POST" bufferOption:SnowplowBufferDefault emitterCallback:nil];
}

- (id) initWithURLRequest:(NSURL *)url {
    return [self initWithURLRequest:url httpMethod:@"POST" bufferOption:SnowplowBufferDefault emitterCallback:nil];
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method {
    return [self initWithURLRequest:url httpMethod:method bufferOption:SnowplowBufferDefault emitterCallback:nil];
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString* )method bufferOption:(enum SnowplowBufferOptions)option {
    return [self initWithURLRequest:url httpMethod:method bufferOption:option emitterCallback:nil];
}

- (id) initWithURLRequest:(NSURL *)url httpMethod:(NSString *)method bufferOption:(enum SnowplowBufferOptions)option emitterCallback:(id<RequestCallback>)callback {
    self = [super init];
    if (self) {
        _urlEndpoint = url;
        _httpMethod = method;
        _isSending = false;
        _bufferOption = option;
        _db = [[SnowplowEventStore alloc] init];
        _dataOperationQueue = [[NSOperationQueue alloc] init];
        _callback = callback;
        
        // TODO: Make Thread Count configurable
        _dataOperationQueue.maxConcurrentOperationCount = 15;
        
        if ([method isEqual: @"GET"]) {
            _urlEndpoint = [url URLByAppendingPathComponent:@"/i"];
        } else {
            _urlEndpoint = [url URLByAppendingPathComponent:@"/com.snowplowanalytics.snowplow/tp2"];
        }
        
        [self setBufferTime:kDefaultBufferTimeout];
    }
    return self;
}

- (void) addPayloadToBuffer:(SnowplowPayload *)spPayload {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_db insertEvent:spPayload];
        [self flushBuffer];
    });
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

- (void) setUrlEndpoint:(NSURL *) url {
    _urlEndpoint = [url URLByAppendingPathComponent:@"/i"];
}

- (void) setBufferTime:(int) userTime {
    int time = kDefaultBufferTimeout;
    if (userTime <= 300) {
        time = userTime; // 5 minute intervals
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(flushBuffer) userInfo:nil repeats:YES];
}

- (void) flushBuffer {
    if (_isSending == false) {
        _isSending = true;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendEvents];
        });
    }
}

- (void) sendEvents {
    SnowplowDLog(@"Sending events...");
    
    if ([self getDbCount] == 0) {
        SnowplowDLog(@"Database empty. Returning..");
        _isSending = false;
        return;
    }
    
    // TODO: Convert range into an emitter argument
    NSArray *listValues = [NSArray arrayWithArray:[_db getAllEventsLimited:150]];
    
    NSMutableArray *sendResults = [[NSMutableArray alloc] init];
    
    if ([_httpMethod isEqual:@"POST"]) {
        for (int i = 0; i < listValues.count; i += _bufferOption) {
            NSMutableArray *eventArray = [[NSMutableArray alloc] init];
            NSMutableArray *indexArray = [[NSMutableArray alloc] init];
            
            for (int j = i; j < (i + _bufferOption) && j < listValues.count; j++) {
                [eventArray addObject:[listValues[j] objectForKey:@"eventData"]];
                [indexArray addObject:[listValues[j] objectForKey:@"ID"]];
            }
            
            NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
            [payload setValue:kPayloadDataSchema forKey:@"schema"];
            [payload setValue:eventArray forKey:@"data"];
            [self sendSyncRequest:[self getRequestPostWithData:payload] withIndex:indexArray withResultPointer:sendResults];
        }
    } else if ([_httpMethod isEqual:@"GET"]) {
        for (NSDictionary * eventWithMetaData in listValues) {
            NSMutableArray *indexArray = [[NSMutableArray alloc] init];
            [indexArray addObject:[eventWithMetaData objectForKey:@"ID"]];
            [self sendSyncRequest:[self getRequestGetWithData:[eventWithMetaData objectForKey:@"eventData"]] withIndex:indexArray withResultPointer:sendResults];
        }
    } else {
        NSLog(@"Invalid httpMethod provided. Use \"POST\" or \"GET\".");
    }
    
    [_dataOperationQueue waitUntilAllOperationsAreFinished];
    
    NSInteger success = 0;
    NSInteger failure = 0;
    
    for (int i = 0; i < sendResults.count; i++) {
        RequestResponse * result = [sendResults objectAtIndex:i];
        NSMutableArray * resultIndexArray = [result getIndexArray];
        
        if ([result getSuccess]) {
            [self processSuccessResult:resultIndexArray];
            success += resultIndexArray.count;
        } else {
            failure += resultIndexArray.count;
        }
    }
    
    [_dataOperationQueue waitUntilAllOperationsAreFinished];
    
    SnowplowDLog(@"Success Count: %@", success);
    SnowplowDLog(@"Failure Count: %@", failure);
    
    if (_callback != nil) {
        if (failure == 0) {
            [self.callback onSuccess:success];
        } else {
            [self.callback onFailure:success failure:failure];
        }
    }
    
    listValues = nil;
    sendResults = nil;
    
    if (success == 0 && failure > 0) {
        SnowplowDLog(@"Ending emitter run as all requests failed...");
        _isSending = false;
    } else {
        [self sendEvents];
    }
}

- (void) sendSyncRequest:(NSMutableURLRequest *)request withIndex:(NSMutableArray *)indexArray withResultPointer:(NSMutableArray *)results {
    [_dataOperationQueue addOperationWithBlock:^{
        NSError *connectionError;
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        if ([response statusCode] >= 200 && [response statusCode] < 300) {
            [results addObject:[[RequestResponse alloc] initWithBool:true withIndex:indexArray]];
        } else {
            NSLog(@"Error: %@", connectionError);
            [results addObject:[[RequestResponse alloc] initWithBool:false withIndex:indexArray]];
        }
    }];
}

- (void) processSuccessResult:(NSMutableArray *)indexArray {
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
    [request setValue:[self acceptContentTypeHeader] forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    return request;
}

- (NSMutableURLRequest *) getRequestGetWithData:(NSDictionary *)data {
    NSString *url = [NSString stringWithFormat:@"%@?%@", [_urlEndpoint absoluteString], [SnowplowUtils urlEncodeDictionary:data]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:[self acceptContentTypeHeader] forHTTPHeaderField:@"Accept"];
    return request;
}

- (NSString *) acceptContentTypeHeader {
    return @"text/html, application/x-www-form-urlencoded, text/plain, image/gif";
}

- (NSUInteger) getDbCount {
    return [_db count];
}

- (BOOL) getSendingStatus {
    return _isSending;
}

@end
