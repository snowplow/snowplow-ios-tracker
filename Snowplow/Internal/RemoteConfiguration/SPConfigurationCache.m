//
//  SPConfigurationCache.m
//  Snowplow
//
//  Created by Alex Benini on 15/04/2021.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import "SPConfigurationCache.h"

@interface SPConfigurationCache ()

@property (nonatomic, nonnull) NSURL *cacheFileUrl;
@property (nonatomic, nullable) SPFetchedConfigurationBundle *configuration;

@end

@implementation SPConfigurationCache

- (instancetype)init {
    if (self = [super init]) {
        [self createCachePath];
    }
    return self;
}

- (nullable SPFetchedConfigurationBundle *)readCache {
    @synchronized (self) {
        if (self.configuration) {
            return self.configuration;
        }
        [self loadCache];
        return self.configuration;
    }
}

- (void)writeCache:(SPFetchedConfigurationBundle *)configuration {
    @synchronized (self) {
        self.configuration = configuration;
        [self storeCache];
    }
}

- (void)clearCache {
    @synchronized (self) {
        if (!self.cacheFileUrl) return;
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:self.cacheFileUrl error:&error];
    }
}

// Private method

- (void)loadCache {
    @synchronized (self) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:self.cacheFileUrl];
        if (!data) return;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.configuration = (SPFetchedConfigurationBundle *)[unarchiver decodeObject];
        [unarchiver finishDecoding];
    }
}

- (void)storeCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            if (!self.configuration) return;
            NSMutableData *data = [NSMutableData new];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [archiver encodeObject:self.configuration];
            [archiver finishEncoding];
            NSError *error = nil;
            [data writeToURL:self.cacheFileUrl options:NSDataWritingAtomic error:&error];
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
