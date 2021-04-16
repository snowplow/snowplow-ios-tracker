//
//  SPConfigurationFetcher.m
//  Snowplow
//
//  Created by Alex Benini on 04/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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
