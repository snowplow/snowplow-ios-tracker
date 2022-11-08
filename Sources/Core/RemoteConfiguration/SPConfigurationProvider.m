//
//  SPConfigurationProvider.m
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
//  Authors: Alex Benini
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
        self.cache = [[SPConfigurationCache alloc] initWithRemoteConfiguration:remoteConfiguration];
        if (defaultBundles) {
            SPFetchedConfigurationBundle *bundle = [[SPFetchedConfigurationBundle alloc] init];
            bundle.schema = @"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-0-0";
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
            if (self.cacheBundle) {
                onFetchCallback(self.cacheBundle, SPConfigurationStateCached);
            } else if (self.defaultBundle) {
                onFetchCallback(self.defaultBundle, SPConfigurationStateDefault);
            }
        }
        self.fetcher = [[SPConfigurationFetcher alloc] initWithRemoteSource:self.remoteConfiguration onFetchCallback:^(SPFetchedConfigurationBundle * _Nonnull fetchedConfigurationBundle, SPConfigurationState configurationState) {
            if (![self schemaCompatibility:fetchedConfigurationBundle.schema]) {
                return;
            }
            @synchronized (self) {
                if (self.cacheBundle && self.cacheBundle.configurationVersion >= fetchedConfigurationBundle.configurationVersion) {
                    return;
                }
                [self.cache writeCache:fetchedConfigurationBundle];
                self.cacheBundle = fetchedConfigurationBundle;
                onFetchCallback(fetchedConfigurationBundle, SPConfigurationStateFetched);
            }
        }];
    }
}

// Private methods

- (BOOL)schemaCompatibility:(NSString *)schema {
    return [schema hasPrefix:@"http://iglucentral.com/schemas/com.snowplowanalytics.mobile/remote_config/jsonschema/1-"];
}

@end
