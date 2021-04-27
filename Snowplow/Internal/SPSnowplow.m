//
//  SPSnowplow.m
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

#import "SPSnowplow.h"
#import "SPServiceProvider.h"

@interface SPSnowplow ()

@property (nonatomic, nullable) SPServiceProvider *defaultServiceProvider;
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, SPServiceProvider *> *serviceProviderInstances;

@end

@implementation SPSnowplow

+ (id<SPTrackerController>)createTrackerWithNamespace:(NSString *)namespace endpoint:(NSString *)endpoint method:(SPHttpMethod)method {
    SPNetworkConfiguration *networkConfiguration = [[SPNetworkConfiguration alloc] initWithEndpoint:endpoint method:method];
    return [SPSnowplow createTrackerWithNamespace:namespace network:networkConfiguration configurations:@[]];
}

+ (id<SPTrackerController>)createTrackerWithNamespace:(NSString *)namespace network:(SPNetworkConfiguration *)networkConfiguration {
    return [SPSnowplow createTrackerWithNamespace:namespace network:networkConfiguration configurations:@[]];
}

+ (id<SPTrackerController>)createTrackerWithNamespace:(NSString *)namespace network:(SPNetworkConfiguration *)networkConfiguration configurations:(NSArray<SPConfiguration *> *)configurations {
    SPServiceProvider *serviceProvider = [[SPSnowplow sharedInstance].serviceProviderInstances objectForKey:namespace];
    if (serviceProvider) {
        [serviceProvider resetWithConfigurations:[configurations arrayByAddingObject:networkConfiguration]];
    } else {
        serviceProvider = [[SPServiceProvider alloc] initWithNamespace:namespace network:networkConfiguration configurations:configurations];
        [SPSnowplow.sharedInstance registerInstance:serviceProvider];
    }
    return serviceProvider.trackerController;
}

+ (id<SPTrackerController>)defaultTracker {
    return [[[SPSnowplow sharedInstance] defaultServiceProvider] trackerController];
}

+ (BOOL)setTrackerAsDefault:(id<SPTrackerController>)trackerController {
    SPSnowplow *shared = [SPSnowplow sharedInstance];
    @synchronized (shared) {
        SPServiceProvider *serviceProvider = [shared.serviceProviderInstances objectForKey:trackerController.namespace];
        if (serviceProvider) {
            shared.defaultServiceProvider = serviceProvider;
            return YES;
        }
        return NO;
    }
}

+ (BOOL)removeTracker:(id<SPTrackerController>)trackerController {
    SPSnowplow *shared = [SPSnowplow sharedInstance];
    @synchronized (shared) {
        NSString *namespace = trackerController.namespace;
        SPServiceProvider *serviceProvider = [shared.serviceProviderInstances objectForKey:namespace];
        if (serviceProvider) {
            [serviceProvider shutdown];
            [shared.serviceProviderInstances removeObjectForKey:namespace];
            if (serviceProvider == shared.defaultServiceProvider) {
                shared.defaultServiceProvider = nil;
            }
            return YES;
        }
        return NO;
    }
}

+ (void)removeAllTrackers {
    SPSnowplow *shared = [SPSnowplow sharedInstance];
    @synchronized (shared) {
        shared.defaultServiceProvider = nil;
        NSArray<SPServiceProvider *> *serviceProviders = [shared.serviceProviderInstances allValues];
        [shared.serviceProviderInstances removeAllObjects];
        for (SPServiceProvider *sp in serviceProviders) {
            [sp shutdown];
        }
    }
}

+ (NSArray<NSString *> *)instancedTrackerNamespaces {
    return [[SPSnowplow sharedInstance].serviceProviderInstances allKeys];
}

// MARK: - Private methods

- (BOOL)registerInstance:(SPServiceProvider *)serviceProvider {
    @synchronized (self) {
        NSString *namespace = serviceProvider.namespace;
        BOOL isOverriding = [self.serviceProviderInstances objectForKey:namespace] != nil;
        [self.serviceProviderInstances setObject:serviceProvider forKey:namespace];
        if (!self.defaultServiceProvider) {
            self.defaultServiceProvider = serviceProvider;
        }
        return isOverriding;
    }
}

// Global singleton

+ (instancetype)sharedInstance {
    static SPSnowplow *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.serviceProviderInstances = [NSMutableDictionary new];
    }
    return self;
}

@end
