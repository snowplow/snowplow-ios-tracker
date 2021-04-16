//
//  SPConfigurationProvider.m
//  Snowplow
//
//  Created by Alex Benini on 03/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPConfigurationProvider.h"
#import "SPConfigurationCache.h"
#import "SPConfigurationFetcher.h"

@interface SPConfigurationProvider()

@property (nonatomic, nonnull) SPRemoteConfiguration *remoteConfiguration;
@property (nonatomic, nonnull) SPConfigurationCache *cache;
@property (nonatomic, nullable) SPConfigurationFetcher *fetcher;
@property (nonatomic, nonnull) SPFetchedConfigurationBundle *cacheBundle;

@end

@implementation SPConfigurationProvider

- (instancetype)initWithRemoteConfiguration:(SPRemoteConfiguration *)remoteConfiguration {
    if (self = [super init]) {
        self.remoteConfiguration = remoteConfiguration;
        self.cache = [SPConfigurationCache new];
    }
    return self;
}

- (void)retrieveConfiguration:(OnFetchCallback)onFetchCallback {
    @synchronized (self) {
        self.cacheBundle = [self.cache readCache];
        if (self.cacheBundle) {
            onFetchCallback(self.cacheBundle);
        }
        self.fetcher = [[SPConfigurationFetcher alloc] initWithRemoteSource:self.remoteConfiguration onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle) {
            if (![self versionCompatibility:fetchedConfigurationBundle.formatVersion]) {
                return;
            }
            @synchronized (self) {
                if (self.cacheBundle && self.cacheBundle.configurationVersion >= fetchedConfigurationBundle.configurationVersion) {
                    return;
                }
                [self.cache writeCache:fetchedConfigurationBundle];
                self.cacheBundle = fetchedConfigurationBundle;
                onFetchCallback(fetchedConfigurationBundle);
            }
        }];
    }
}

// Private methods

- (BOOL)versionCompatibility:(NSString *)version {
    return [version hasPrefix:@"1."];
}

@end
