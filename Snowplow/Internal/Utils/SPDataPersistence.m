//
//  SPDataPersistence.m
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

#import "SPDataPersistence.h"
#import "SPTrackerConstants.h"
#import "SPLogger.h"

@interface SPDataPersistence ()

@property (nonatomic) NSString *escapedNamespace;

#if TARGET_OS_TV || TARGET_OS_WATCH
@property (nonatomic) NSString *userDefaultsKey;
#endif

@property (nonatomic) NSURL *directoryUrl;
@property (nonatomic) NSURL *fileUrl;

@end

@implementation SPDataPersistence

static NSMutableDictionary<NSString *, SPDataPersistence *> *instances = nil;

#if TARGET_OS_TV || TARGET_OS_WATCH
NSString *const kSPSessionDictionaryPrefix = @"SPSessionDictionary";
#endif

NSString *const kFilename = @"namespace";
NSString *const kFilenameExt = @"dict";
NSString *const kSessionFilenameV1 = @"session.dict";
NSString *const kSessionFilenamePrefixV2_2 = @"session";

NSString *sessionKey = @"session";

+ (SPDataPersistence *)dataPersistenceForNamespace:(NSString *)namespace {
    NSString *escapedNamespace = [SPDataPersistence stringFromNamespace:namespace];
    if ([escapedNamespace length] <= 0) return nil;
    @synchronized (SPDataPersistence.class) {
        SPDataPersistence *instance = nil;
        if (instances) {
            instance = [instances objectForKey:escapedNamespace];
            if (instance) {
                return instance;
            }
        } else {
            instances = [NSMutableDictionary new];
        }
        instance = [[SPDataPersistence alloc] initWithNamespace:escapedNamespace];
        [instances setValue:instance forKey:escapedNamespace];
        return instance;
    }
}

+ (BOOL)removeDataPersistenceWithNamespace:(NSString *)namespace {
    SPDataPersistence *instance = [SPDataPersistence dataPersistenceForNamespace:namespace];
    if (!instance) return NO;
    @synchronized (SPDataPersistence.class) {
        [instances removeObjectForKey:instance.escapedNamespace];
    }
    [instance removeAll];
    return YES;
}

+ (NSString *)stringFromNamespace:(NSString *)namespace {
    if (!namespace) return nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+" options:0 error:nil];
    return [regex stringByReplacingMatchesInString:namespace options:0 range:NSMakeRange(0, namespace.length) withTemplate:@"-"];
}

// MARK: - Property accessor methods

- (NSDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *)data {
    @synchronized (self) {
#if TARGET_OS_TV || TARGET_OS_WATCH
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:self.userDefaultsKey];
#else
        NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *result =
        [NSMutableDictionary dictionaryWithContentsOfURL:self.fileUrl];
        
        if (!result) {
            // Initialise
            result = [NSMutableDictionary new];
            // Migrate legacy session data
            NSDictionary *sessionDict = [self sessionDictionaryFromLegacyTrackerV2_2]
                ?: [self sessionDictionaryFromLegacyTrackerV1]
                ?: [NSDictionary new];
            [result setObject:sessionDict forKey:sessionKey];
            [self storeDictionary:result];
        }
        
        return result;
#endif
    }
}

- (void)setData:(NSDictionary<NSString *,NSDictionary<NSString *, NSObject *> *> *)data {
    @synchronized (self) {
#if TARGET_OS_TV || TARGET_OS_WATCH
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:self.userDefaultsKey];
#else
        [self storeDictionary:data];
#endif
    }
}

- (NSDictionary<NSString *, NSObject *> *)session {
    return [self.data objectForKey:sessionKey];
}

- (void)setSession:(NSDictionary<NSString *, NSObject *> *)session {
    @synchronized (self) {
        NSMutableDictionary<NSString *, NSDictionary *> *data = [self.data mutableCopy];
        [data setValue:session forKey:sessionKey];
        self.data = data;
    }
}

// MARK: - Private instance methods

- (instancetype)initWithNamespace:(NSString *)escapedNamespace {
    if (self = [super init]) {
        self.escapedNamespace = escapedNamespace;
#if TARGET_OS_TV || TARGET_OS_WATCH
        self.userDefaultsKey = [NSString stringWithFormat:@"%@_%@", kSPSessionDictionaryPrefix, escapedNamespace];
#else
        self.directoryUrl = [self createDirectoryUrl];
        NSString *filename = [NSString stringWithFormat:@"%@_%@.%@", kFilename, escapedNamespace, kFilenameExt];
        self.fileUrl = [self.directoryUrl URLByAppendingPathComponent:filename];
#endif
    }
    return self;
}

- (BOOL)removeAll {
    @synchronized (self) {
#if TARGET_OS_TV || TARGET_OS_WATCH
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.userDefaultsKey];
        return YES;
#else
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:self.fileUrl error:&error];
        if (error) {
            SPLogError(@"%@", error.localizedDescription);
            return NO;
        }
        return YES;
#endif
    }
}

- (NSURL *)createDirectoryUrl {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
    url = [url URLByAppendingPathComponent:@"snowplow"];
    NSError *error = nil;
    BOOL result = [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    if (!result) {
        SPLogError(@"Unable to create directory for tracker data persistence: %@", error.localizedDescription);
        return nil;
    }
    return url;
}

- (BOOL)storeDictionary:(NSDictionary *)dictionary {
    BOOL result = NO;
    NSError *error = nil;
    if (@available(iOS 11.0, macOS 10.13, watchOS 4.0, *)) {
        result = [dictionary writeToURL:self.fileUrl error:&error];
    } else {
        result = [dictionary writeToURL:self.fileUrl atomically:YES];
    }
    if (!result) {
        SPLogError(@"Unable to write file for sessions: %@", error.localizedDescription ?: @"-");
        return NO;
    }
    return YES;
}

// Migration methods

- (NSDictionary *)sessionDictionaryFromLegacyTrackerV2_2 {
    @synchronized (self) {
        NSString *filename = [NSString stringWithFormat:@"%@_%@.%@", kSessionFilenamePrefixV2_2, self.escapedNamespace, kFilenameExt];
        NSURL *fileUrl = [self.directoryUrl URLByAppendingPathComponent:filename];
        NSDictionary *sessionDict = nil;
        sessionDict = [NSDictionary dictionaryWithContentsOfURL:fileUrl];
        if (!sessionDict) {
            return nil;
        }
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
        if (error) {
            SPLogError(@"%@", error.localizedDescription);
        }
        return sessionDict;
    }
}

- (NSDictionary *)sessionDictionaryFromLegacyTrackerV1 {
    @synchronized (SPDataPersistence.class) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        path = [path stringByAppendingPathComponent:kSessionFilenameV1];
        NSDictionary *sessionDict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!sessionDict) {
            return nil;
        }
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            SPLogError(@"%@", error.localizedDescription);
        }
        return sessionDict;
    }
}

@end
