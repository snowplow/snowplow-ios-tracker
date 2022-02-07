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

@property (nonatomic) NSString *userDefaultsKey;
@property (nonatomic) NSURL *directoryUrl;
@property (nonatomic) NSURL *fileUrl;

@end

@implementation SPDataPersistence

static NSMutableDictionary<NSString *, SPDataPersistence *> *instances = nil;

NSString *const kSPSessionDictionaryPrefix = @"SPSessionDictionary";
NSString *const kFilename = @"namespace";
NSString *const kFilenameExt = @"dict";
NSString *const kSessionFilenameV1 = @"session.dict";
NSString *const kSessionFilenamePrefixV2_2 = @"session";

NSString *sessionKey = @"session";

+ (SPDataPersistence *)dataPersistenceForNamespace:(NSString *)namespace {
    return [SPDataPersistence dataPersistenceForNamespace:namespace storedOnFile:YES];
}

+ (SPDataPersistence *)dataPersistenceForNamespace:(NSString *)namespace storedOnFile:(BOOL)isStoredOnFile {
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
        instance = [[SPDataPersistence alloc] initWithNamespace:escapedNamespace storedOnFile:isStoredOnFile];
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
        if (!self.isStoredOnFile) {
            return [[NSUserDefaults standardUserDefaults] dictionaryForKey:self.userDefaultsKey] ?: @{};
        }
        NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *result =
        [NSMutableDictionary dictionaryWithContentsOfURL:self.fileUrl];
        
        if (!result) {
            // Initialise
            result = [NSMutableDictionary new];
            // Migrate legacy session data
            NSMutableDictionary *sessionDict = [self sessionDictionaryFromLegacyTrackerV2_2].mutableCopy
                ?: [self sessionDictionaryFromLegacyTrackerV1].mutableCopy
                ?: [NSMutableDictionary new];
            // Add missing fields
            [sessionDict setObject:@"" forKey:kSPSessionFirstEventId];
            [sessionDict setObject:@"LOCAL_STORAGE" forKey:kSPSessionStorage];
            // Wrap up
            [result setObject:sessionDict forKey:sessionKey];
            [self storeDictionary:result fileURL:self.fileUrl];
        }
        
        return result;
    }
}

- (void)setData:(NSDictionary<NSString *,NSDictionary<NSString *, NSObject *> *> *)data {
    @synchronized (self) {
        if (self.fileUrl) {
            [self storeDictionary:data fileURL:self.fileUrl];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:self.userDefaultsKey];
        }
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

- (BOOL)isStoredOnFile {
    return self.fileUrl != nil;
}

// MARK: - Private instance methods

- (instancetype)initWithNamespace:(NSString *)escapedNamespace storedOnFile:(BOOL)isStoredOnFile {
    if (self = [super init]) {
        self.escapedNamespace = escapedNamespace;
        self.userDefaultsKey = [NSString stringWithFormat:@"%@_%@", kSPSessionDictionaryPrefix, escapedNamespace];
#if !(TARGET_OS_TV || TARGET_OS_WATCH)
        if (isStoredOnFile) {
            self.directoryUrl = [self createDirectoryUrl];
            if (self.directoryUrl) {
                NSString *filename = [NSString stringWithFormat:@"%@_%@.%@", kFilename, escapedNamespace, kFilenameExt];
                self.fileUrl = [self.directoryUrl URLByAppendingPathComponent:filename];
            }
        }
#endif
    }
    return self;
}

- (BOOL)removeAll {
    @synchronized (self) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.userDefaultsKey];
        NSError *error = nil;
        if (self.fileUrl && ![[NSFileManager defaultManager] removeItemAtURL:self.fileUrl error:&error]) {
            SPLogError(@"%@", error.localizedDescription);
            return NO;
        }
        return YES;
    }
}

- (NSURL *)createDirectoryUrl {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
    url = [url URLByAppendingPathComponent:@"snowplow" isDirectory:YES];
    NSError *error = nil;
    if ([url checkResourceIsReachableAndReturnError:&error]) {
        return url;
    }
    if ([fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error]) {
        return url;
    }
    SPLogError(@"Unable to create directory for tracker data persistence: %@", error.localizedDescription);
    return nil;
}

- (BOOL)storeDictionary:(NSDictionary *)dictionary fileURL:(NSURL *)fileUrl {
    BOOL result = NO;
    NSError *error = nil;
    if (@available(iOS 11.0, macOS 10.13, watchOS 4.0, *)) {
        result = [dictionary writeToURL:fileUrl error:&error];
    } else {
        result = [dictionary writeToURL:fileUrl atomically:YES];
    }
    if (result) {
        return YES;
    }
    SPLogError(@"Unable to write file for sessions: %@", error.localizedDescription ?: @"-");
    return NO;
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
