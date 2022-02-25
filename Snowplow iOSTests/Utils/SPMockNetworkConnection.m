//
//  SPMockNetworkConnection.m
//  Snowplow
//
//  Copyright (c) 2013-2021 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2022 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPMockNetworkConnection.h"
#import "SPLogger.h"

@implementation SPMockNetworkConnection

- initWithRequestOption:(SPHttpMethod)httpMethod successfulConnection:(BOOL)successfulConnection {
    if (self = [super init]) {
        self.httpMethod = httpMethod;
        self.successfulConnection = successfulConnection;
        self.previousResults = [NSMutableArray new];
    }
    return self;
}

- (nonnull NSArray<SPRequestResult *> *)sendRequests:(nonnull NSArray<SPRequest *> *)requests {
    NSMutableArray<SPRequestResult *> *requestResults = [NSMutableArray new];
    for (SPRequest *request in requests) {
        BOOL isSuccessful = request.oversize || self.successfulConnection;
        SPRequestResult *result = [[SPRequestResult alloc] initWithSuccess:isSuccessful storeIds:request.emitterEventIds];
        SPLogVerbose(@"Sent %@ with success %@", request.emitterEventIds, isSuccessful ? @"YES" : @"NO");
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
