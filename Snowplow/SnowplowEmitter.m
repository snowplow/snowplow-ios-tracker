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

@interface SnowplowEmitter()
@property BOOL isSending;
@end

@implementation SnowplowEmitter {
    NSURL *                     _urlEndpoint;
    NSString *                  _httpMethod;
    enum SnowplowBufferOptions  _bufferOption;
    NSTimer *                   _timer;
    SnowplowEventStore *        _db;
}

static int       const kDefaultBufferTimeout = 60;
static NSString *const kPayloadDataSchema    = @"iglu:com.snowplowanalytics.snowplow/payload_data/jsonschema/1-0-0";

+ (NSURLSession *)snowplowURLSession
{
    static NSURLSession *sharedSession = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^()
    {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.allowsCellularAccess = YES;
        sessionConfig.HTTPShouldUsePipelining = YES;
        sessionConfig.HTTPShouldSetCookies = YES;

        sharedSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                      delegate:nil
                                                 delegateQueue:nil];
    });
    
    return sharedSession;
}

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
    if (self) {
        _urlEndpoint = url;
        _httpMethod = method;
        _isSending = false;
        _bufferOption = option;
        _db = [[SnowplowEventStore alloc] init];
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
        [self sendEvents];
    }
}

- (void) sendEvents {
    DLog(@"Sending events...");
    
    // Get a limited range of events to send
    // TODO: Convert range into an emitter argument
    NSArray *listValues = [_db getAllNonPendingEventsLimited:150];
    
    // Exit if there is nothing to send and reset
    // isSending to false
    if ([listValues count] == 0) {
        DLog(@"Database empty. Returning..");
        _isSending = false;
        return;
    }
    
    // Empties the buffer and sends the contents to the collector
    if ([_httpMethod isEqual:@"POST"]) {
        
        // Create POSTs with the correct amount of events
        for (int i = 0; i < listValues.count; i += _bufferOption) {
            NSMutableArray *eventArray = [[NSMutableArray alloc] init];
            NSMutableArray *indexArray = [[NSMutableArray alloc] init];
            
            for (int j = i; j < (i + _bufferOption) && j < listValues.count; j++) {
                [_db setPendingWithId:(long long int)[listValues[j] objectForKey:@"ID"]];
                [eventArray addObject:[listValues[j] objectForKey:@"eventData"]];
                [indexArray addObject:[listValues[j] objectForKey:@"ID"]];
            }
            
            NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
            [payload setValue:kPayloadDataSchema forKey:@"schema"];
            [payload setValue:eventArray forKey:@"data"];
            [self sendPostData:payload withDbIndexArray:indexArray];
        }
    } else if ([_httpMethod isEqual:@"GET"]) {
        NSMutableArray *indexArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary * eventWithMetaData in listValues) {
            [_db setPendingWithId:(long long int)[eventWithMetaData objectForKey:@"ID"]];
            [indexArray addObject:[eventWithMetaData objectForKey:@"ID"]];
            [self sendGetData:[eventWithMetaData objectForKey:@"eventData"] withDbIndexArray:indexArray];
        }
    } else {
        NSLog(@"Invalid httpMethod provided. Use \"POST\" or \"GET\".");
    }
    
    // Queue sending to occur again after 5 seconds
    // TODO: Convert timeout into an emitter argument
    [NSThread sleepForTimeInterval:5];
    [self sendEvents];
}

- (void) sendPostData:(NSDictionary *)postData withDbIndexArray:(NSMutableArray *)dbIndexArray {
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:postData options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_urlEndpoint absoluteString]]];
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[self acceptContentTypeHeader] forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    
    NSURLSessionDataTask *dataTask = [[[self class] snowplowURLSession]
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data,
                                                          NSURLResponse *response,
                                                          NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            for (int i=0; i < dbIndexArray.count;  i++) {
                [_db removePendingWithId:(long long int)dbIndexArray[i]];
            }
        } else {
            DLog(@"JSON: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSMutableArray *removedIDs = [NSMutableArray arrayWithArray:dbIndexArray];
            for (int i=0; i < dbIndexArray.count; i++) {
                DLog(@"Removing event at index: %@", dbIndexArray[i]);
                [_db removeEventWithId:[[dbIndexArray objectAtIndex:i] longLongValue]];
                [removedIDs addObject:dbIndexArray[i]];
            }
            [dbIndexArray removeObjectsInArray:removedIDs];
        }
    }];
    [dataTask resume];
}

- (void) sendGetData:(NSDictionary *)getData withDbIndexArray:(NSMutableArray *)dbIndexArray {
    NSString *url = [NSString stringWithFormat:@"%@?%@", [_urlEndpoint absoluteString], [SnowplowUtils urlEncodeDictionary:getData]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    [request setValue:[self acceptContentTypeHeader] forHTTPHeaderField:@"Accept"];
    
    NSURLSessionDataTask *dataTask = [[[self class] snowplowURLSession]
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data,
                                                          NSURLResponse *response,
                                                          NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            for (int i=0; i < dbIndexArray.count;  i++) {
                [_db removePendingWithId:(long long int)dbIndexArray[i]];
            }
        } else {
            DLog(@"JSON: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSMutableArray *removedIDs = [NSMutableArray arrayWithArray:dbIndexArray];
            for (int i=0; i < dbIndexArray.count; i++) {
                DLog(@"Removing event at index: %@", dbIndexArray[i]);
                [_db removeEventWithId:[[dbIndexArray objectAtIndex:i] longLongValue]];
                [removedIDs addObject:dbIndexArray[i]];
            }
            [dbIndexArray removeObjectsInArray:removedIDs];
        }
    }];
    [dataTask resume];
}

- (NSString *)acceptContentTypeHeader
{
    return @"text/html, application/x-www-form-urlencoded, text/plain, image/gif";
}
                       

@end
