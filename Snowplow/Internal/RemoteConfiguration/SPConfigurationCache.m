//
//  SPConfigurationCache.m
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

#import "SPConfigurationCache.h"
#import "SPLogger.h"

@interface SPConfigurationCache ()

@property (nonatomic, nonnull) NSURL *cacheFileUrl;
@property (nonatomic, nullable) SPFetchedConfigurationBundle *configuration;

@end

@implementation SPConfigurationCache

- (instancetype)init {
    if (self = [super init]) {
#if !(TARGET_OS_TV) && !(TARGET_OS_WATCH)
        [self createCachePath];
#endif
    }
    return self;
}

- (nullable SPFetchedConfigurationBundle *)readCache {
    @synchronized (self) {
#if !(TARGET_OS_TV) && !(TARGET_OS_WATCH)
        if (self.configuration) {
            return self.configuration;
        }
        [self loadCache];
#endif
        return self.configuration;
    }
}

- (void)writeCache:(SPFetchedConfigurationBundle *)configuration {
    @synchronized (self) {
        self.configuration = configuration;
#if !(TARGET_OS_TV) && !(TARGET_OS_WATCH)
        [self storeCache];
#endif
    }
}

- (void)clearCache {
    NSError *error = nil;
    @synchronized (self) {
        self.configuration = nil;
#if !(TARGET_OS_TV) && !(TARGET_OS_WATCH)
        if (!self.cacheFileUrl) return;
        [[NSFileManager defaultManager] removeItemAtURL:self.cacheFileUrl error:&error];
#endif
    }
    if (error) {
        SPLogError(@"Error on clearing configuration from cache: %@", error.localizedDescription);
    }
}

// Private method

- (void)loadCache {
    @synchronized (self) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:self.cacheFileUrl];
        if (!data) return;
        @try {
            if (@available(iOS 12, tvOS 12, watchOS 5, macOS 10.14, *)) {
                NSError *error = nil;
                self.configuration = (SPFetchedConfigurationBundle *)[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:&error];
                if (error) {
                    SPLogError(@"Error on getting configuration from cache: %@", error.localizedDescription);
                    self.configuration = nil;
                    return;
                }
            } else {
                NSKeyedUnarchiver *unarchiver = nil;
                unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                self.configuration = (SPFetchedConfigurationBundle *)[unarchiver decodeObject];
                [unarchiver finishDecoding];
            }
        } @catch (NSException *exception) {
            SPLogError(@"Exception on getting configuration from cache: %@", exception.reason);
            self.configuration = nil;
        }
    }
}

- (void)storeCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            if (!self.configuration) return;
            @try {
                NSMutableData *data = [NSMutableData new];
                NSKeyedArchiver *archiver;
                if (@available(iOS 12, tvOS 12, watchOS 5, macOS 10.14, *)) {
                    archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
                    [archiver encodeObject:self.configuration forKey:@"root"];
                    [data setData:archiver.encodedData];
                } else {
                    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                    [archiver encodeObject:self.configuration];
                    [archiver finishEncoding];
                }
                NSError *error = nil;
                [data writeToURL:self.cacheFileUrl options:NSDataWritingAtomic error:&error];
                if (error) {
                    SPLogError(@"Error on caching configuration: %@", error.localizedDescription);
                }
            } @catch (NSException *exception) {
                SPLogError(@"Exception on caching configuration: %@", exception.reason);
            }
        }
    });
}

- (void)createCachePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
    url = [url URLByAppendingPathComponent:@"snowplow-cache"];
    NSError *error = nil;
    [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    url = [url URLByAppendingPathComponent:@"remoteConfig.data" isDirectory:NO];
    self.cacheFileUrl = url;
}

@end
