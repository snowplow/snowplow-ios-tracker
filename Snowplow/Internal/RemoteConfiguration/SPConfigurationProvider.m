//
//  SPConfigurationProvider.m
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

#import "SPConfigurationProvider.h"
#import "SPConfigurationCache.h"
#import "SPConfigurationFetcher.h"

@interface SPConfigurationProvider()

@property (nonatomic, nonnull) SPRemoteConfiguration *remoteConfiguration;
@property (nonatomic, nonnull) SPConfigurationCache *cache;
@property (nonatomic, nullable) SPConfigurationFetcher *fetcher;
@property (nonatomic, nullable) SPFetchedConfigurationBundle *defaultBundle;
@property (nonatomic, nonnull) SPFetchedConfigurationBundle *cacheBundle;

@end

@implementation SPConfigurationProvider

- (instancetype)initWithRemoteConfiguration:(SPRemoteConfiguration *)remoteConfiguration {
    return [self initWithRemoteConfiguration:remoteConfiguration defaultConfigurationBundles:nil];
}

- (instancetype)initWithRemoteConfiguration:(SPRemoteConfiguration *)remoteConfiguration defaultConfigurationBundles:(nullable NSArray<SPConfigurationBundle *> *)defaultBundles {
    if (self = [super init]) {
        self.remoteConfiguration = remoteConfiguration;
        self.cache = [SPConfigurationCache new];
        if (defaultBundles) {
            SPFetchedConfigurationBundle *bundle = [[SPFetchedConfigurationBundle alloc] init];
            bundle.formatVersion = @"1.0";
            bundle.configurationVersion = NSIntegerMin;
            bundle.configurationBundle = defaultBundles;
            self.defaultBundle = bundle;
        }
    }
    return self;
}

- (void)retrieveConfigurationOnlyRemote:(BOOL)onlyRemote onFetchCallback:(OnFetchCallback)onFetchCallback {
    @synchronized (self) {
        if (!onlyRemote) {
            if (!self.cacheBundle) {
                self.cacheBundle = [self.cache readCache];
            }
            SPFetchedConfigurationBundle *retrievedBundle = self.cacheBundle ?: self.defaultBundle;
            if (retrievedBundle) {
                onFetchCallback(retrievedBundle);
            }
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
