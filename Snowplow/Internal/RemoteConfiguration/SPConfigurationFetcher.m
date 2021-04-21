//
//  SPConfigurationFetcher.m
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
//  Authors: Alex Benini
//  Copyright: Copyright (c) 2013-2021 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "SPConfigurationFetcher.h"

@interface SPConfigurationFetcher ()

@property (nonatomic, nonnull) SPRemoteConfiguration *remoteConfiguration;
@property (nonatomic, nonnull) OnFetchCallback onFetchCallback;

@end

@implementation SPConfigurationFetcher

- (instancetype)initWithRemoteSource:(SPRemoteConfiguration *)remoteConfiguration onFetchCallback:(OnFetchCallback)onFetchCallback {
    if (self = [super init]) {
        self.remoteConfiguration = remoteConfiguration;
        self.onFetchCallback = onFetchCallback;
        [self performRequest];
    }
    return self;
}

- (void)performRequest {
    NSURL *url = [[NSURL alloc] initWithString:self.remoteConfiguration.endpoint];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];

    __block NSHTTPURLResponse *httpResponse = nil;
    __block NSError *connectionError = nil;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                     completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
        connectionError = error;
        httpResponse = (NSHTTPURLResponse *)urlResponse;
        BOOL isSuccessful = [httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300;
        if (isSuccessful) {
            [self resolveRequestWithData:data];
        }
    }] resume];
}

- (void)resolveRequestWithData:(NSData *)data {
    NSError *jsonError = nil;
    NSObject *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    if (![jsonObject isKindOfClass:NSDictionary.class]) {
        return;
    }
    SPFetchedConfigurationBundle *fetchedConfigurationBundle = [[SPFetchedConfigurationBundle alloc] initWithDictionary:(NSDictionary *)jsonObject];
    if (fetchedConfigurationBundle) {
        self.onFetchCallback(fetchedConfigurationBundle);
    }
}

@end
