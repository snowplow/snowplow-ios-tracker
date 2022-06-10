//
//  SPMockNetworkConnection.m
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
//  Authors: Alex Benini, Matus Tomlein
//  License: Apache License Version 2.0
//

#import "SPMockNetworkConnection.h"
#import "SPLogger.h"

@implementation SPMockNetworkConnection

- initWithRequestOption:(SPHttpMethod)httpMethod statusCode:(NSInteger)statusCode {
    if (self = [super init]) {
        self.httpMethod = httpMethod;
        self.statusCode = statusCode;
        self.previousResults = [NSMutableArray new];
    }
    return self;
}

- (nonnull NSArray<SPRequestResult *> *)sendRequests:(nonnull NSArray<SPRequest *> *)requests {
    NSMutableArray<SPRequestResult *> *requestResults = [NSMutableArray new];
    for (SPRequest *request in requests) {
        SPRequestResult *result = [[SPRequestResult alloc] initWithStatusCode:_statusCode oversize:request.oversize storeIds:request.emitterEventIds];
        SPLogVerbose(@"Sent %@ with success %@", request.emitterEventIds, [result isSuccessful] ? @"YES" : @"NO");
        [requestResults addObject:result];
    }
    [self.previousResults addObject:requestResults];
    return requestResults;
}

- (SPHttpMethod)httpMethod {
    return _httpMethod;
}

- (nonnull NSURL *)url {
    return [NSURL URLWithString:@"http://fake-url.com"];
}

- (NSUInteger)sendingCount {
    return self.previousResults.count;
}

@end
