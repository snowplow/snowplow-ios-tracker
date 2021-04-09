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
    }
    return self;
}

@end
