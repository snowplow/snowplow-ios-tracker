//
//  SPDefaultNetworkConnection.m
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPDefaultNetworkConnection.h"
#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPLogger.h"

@implementation SPDefaultNetworkConnection {
    SPRequestOptions _httpMethod;
    SPProtocol _protocol;
    NSString *_urlString;
    NSUInteger _emitThreadPoolSize;
    NSUInteger _byteLimitGet;
    NSUInteger _byteLimitPost;
    NSString *_customPostPath;

    NSOperationQueue *_dataOperationQueue;
    NSURL *_urlEndpoint;
    BOOL _builderFinished;
}

+ (instancetype)build:(void(^)(id<SPDefaultNetworkConnectionBuilder>builder))buildBlock {
    SPDefaultNetworkConnection* connection = [[SPDefaultNetworkConnection alloc] initWithDefaultValues];
    if (buildBlock) {
        buildBlock(connection);
    }
    [connection setup];
    return connection;
}

- (instancetype)initWithDefaultValues {
    if (self = [super init]) {
        _httpMethod = SPRequestPost;
        _protocol = SPHttps;
        _emitThreadPoolSize = 15;
        _byteLimitGet = 40000;
        _byteLimitPost = 40000;
        _customPostPath = nil;
        _dataOperationQueue = [[NSOperationQueue alloc] init];
        _builderFinished = NO;
    }
    return self;
}

- (void) setup {
    _dataOperationQueue.maxConcurrentOperationCount = _emitThreadPoolSize;
    NSString *urlPrefix = _protocol == SPHttp ? @"http://" : @"https://";
    NSString *urlSuffix = _httpMethod == SPRequestGet ? kSPEndpointGet : kSPEndpointPost;
    if (_customPostPath && _httpMethod == SPRequestPost) {
        urlSuffix = _customPostPath;
    }
    _urlEndpoint = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", urlPrefix, _urlString, urlSuffix]];
    
    if ([_urlEndpoint scheme] && [_urlEndpoint host]) {
        SPLogDebug(@"Emitter URL created successfully '%@'", _urlEndpoint);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_urlString forKey:kSPErrorTrackerUrl];
        [userDefaults setObject:urlSuffix forKey:kSPErrorTrackerProtocol];
        [userDefaults setObject:urlPrefix forKey:kSPErrorTrackerMethod];
    } else {
        SPLogDebug(@"Invalid emitter URL: '%@'", _urlEndpoint);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"acme.com" forKey:kSPErrorTrackerUrl];
        [userDefaults setObject:kSPEndpointPost forKey:kSPErrorTrackerProtocol];
        [userDefaults setObject:@"http://" forKey:kSPErrorTrackerMethod];
    }
    _builderFinished = YES;
}

// Required

- (void)setUrlEndpoint:(NSString *)urlEndpoint {
    _urlString = urlEndpoint;
    if (_builderFinished) {
        [self setup];
    }
}

- (void)setHttpMethod:(SPRequestOptions)method {
    _httpMethod = method;
    if (_builderFinished && _urlEndpoint != nil) {
        [self setup];
    }
}

- (void)setProtocol:(SPProtocol)protocol {
    _protocol = protocol;
    if (_builderFinished && _urlEndpoint != nil) {
        [self setup];
    }
}

- (void)setEmitThreadPoolSize:(NSUInteger)emitThreadPoolSize {
    _emitThreadPoolSize = emitThreadPoolSize;
    if (_dataOperationQueue.maxConcurrentOperationCount != emitThreadPoolSize) {
        _dataOperationQueue.maxConcurrentOperationCount = _emitThreadPoolSize;
    }
}

- (void)setByteLimitGet:(NSUInteger)byteLimitGet {
    _byteLimitGet = byteLimitGet;
}

- (void)setByteLimitPost:(NSUInteger)byteLimitPost {
    _byteLimitPost = byteLimitPost;
}

- (void)setCustomPostPath:(NSString *)customPath {
    _customPostPath = customPath;
}

// MARK: - Implement SPNetworkConnection protocol

- (SPRequestOptions)httpMethod {
    return _httpMethod;
}

- (NSURL *)url {
    return _urlEndpoint.copy;
}

- (NSArray<SPRequestResult *> *)sendRequests:(NSArray<SPRequest *> *)requests {
    NSMutableArray<SPRequestResult *> *results = [NSMutableArray new];
    
    for (SPRequest *request in requests) {
        NSMutableURLRequest *urlRequest = _httpMethod == SPRequestGet
        ? [self buildGetRequest:request]
        : [self buildPostRequest:request];

        [_dataOperationQueue addOperationWithBlock:^{
            //source: https://forums.developer.apple.com/thread/11519
            __block NSHTTPURLResponse *httpResponse = nil;
            __block NSError *connectionError = nil;
            dispatch_semaphore_t sem;
            
            sem = dispatch_semaphore_create(0);
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                             completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
                
                connectionError = error;
                httpResponse = (NSHTTPURLResponse*)urlResponse;
                dispatch_semaphore_signal(sem);
            }] resume];
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

            BOOL isSuccessful = [httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300;
            if (!isSuccessful) {
                SPLogError(@"Connection error: %@", connectionError);
            }
            SPRequestResult *result = [[SPRequestResult alloc] initWithSuccess:isSuccessful storeIds:request.emitterEventIds];

            @synchronized (results) {
                [results addObject:result];
            }
        }];
    }
    [_dataOperationQueue waitUntilAllOperationsAreFinished];
    return results;
}

// MARK: - Private methods

- (NSMutableURLRequest *)buildPostRequest:(SPRequest *)request {
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:[request.payload getAsDictionary] options:0 error:nil];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlEndpoint.absoluteString]];
    [urlRequest setValue:[NSString stringWithFormat:@"%@", @(requestData.length).stringValue] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:kSPAcceptContentHeader forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:kSPContentTypeHeader forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:requestData];
    return urlRequest;
}

- (NSMutableURLRequest *)buildGetRequest:(SPRequest *)request {
    NSDictionary<NSString *, NSObject *> *payload = [request.payload getAsDictionary];
    NSString *url = [NSString stringWithFormat:@"%@?%@", _urlEndpoint.absoluteString, [SPUtilities urlEncodeDictionary:payload]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlRequest setValue:kSPAcceptContentHeader forHTTPHeaderField:@"Accept"];
    [urlRequest setHTTPMethod:@"GET"];
    return urlRequest;
}

@end
