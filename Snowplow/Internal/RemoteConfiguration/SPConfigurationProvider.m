//
//  SPConfigurationProvider.m
//  Snowplow
//
//  Created by Alex Benini on 03/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPConfigurationProvider.h"

@interface SPConfigurationProvider()

@property (nonatomic, nonnull) NSMutableDictionary<NSString *, SPRemoteConfiguration *> *remoteSourceMap;
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, OnFetchCallback> *onFetchMap;
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, NSArray<SPConfiguration *> *> *cachedMap;

@end

@implementation SPConfigurationProvider

- (void)registerRemoteSource:(SPRemoteConfiguration *)remoteConfig namespace:(NSString *)namespace onFetchCallback:(OnFetchCallback)onFetchCallback {
    if (![self.remoteSourceMap objectForKey:namespace]) {
        [self.remoteSourceMap setObject:remoteConfig forKey:namespace];
        [self.onFetchMap setObject:onFetchCallback forKey:namespace];
    }
}

- (NSArray<SPConfiguration *> *)configurationsForNamespace:(NSString *)namespace {
    return [self.cachedMap objectForKey:namespace];
}

@end
