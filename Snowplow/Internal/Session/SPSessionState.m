//
//  SPSessionState.m
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

#import "SPSessionState.h"
#import "SPTrackerConstants.h"
#import "NSDictionary+SP_TypeMethods.h"

@interface SPSessionState ()

@property (nonatomic, nonnull, readwrite) NSString *firstEventId;
@property (nonatomic, nullable, readwrite) NSString *previousSessionId;
@property (nonatomic, nonnull, readwrite) NSString *sessionId;
@property (nonatomic, readwrite) NSInteger sessionIndex;
@property (nonatomic, nonnull, readwrite) NSString *storage;

@property (nonatomic, nonnull) NSMutableDictionary<NSString *, NSObject *> *sessionDictionary;

@end

@implementation SPSessionState

- (instancetype)initWithFirstEventId:(NSString *)firstEventId currentSessionId:(NSString *)currentSessionId previousSessionId:(NSString *)previousSessionId sessionIndex:(NSInteger)sessionIndex userId:(NSString *)userId storage:(NSString *)storage {
    if (self = [super init]) {
        self.firstEventId = firstEventId;
        self.sessionId = currentSessionId;
        self.previousSessionId = previousSessionId;
        self.sessionIndex = sessionIndex;
        self.userId = userId;
        self.storage = storage;
        
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        [dictionary setObject:previousSessionId ?: [NSNull null] forKey:kSPSessionPreviousId];
        [dictionary setObject:currentSessionId forKey:kSPSessionId];
        [dictionary setObject:firstEventId forKey:kSPSessionFirstEventId];
        [dictionary setObject:[NSNumber numberWithInteger:sessionIndex] forKey:kSPSessionIndex];
        [dictionary setObject:storage forKey:kSPSessionStorage];
        [dictionary setObject:userId forKey:kSPSessionUserId];
        self.sessionDictionary = dictionary;
    }
    return self;
}

- (instancetype)initWithStoredState:(NSDictionary<NSString *,NSObject *> *)storedState {
    if (self = [super init]) {
        self.sessionDictionary = [storedState mutableCopy];
        
        self.firstEventId = [self.sessionDictionary sp_stringForKey:kSPSessionFirstEventId defaultValue:nil];
        if (!self.firstEventId) return nil;
        
        self.sessionId = [self.sessionDictionary sp_stringForKey:kSPSessionId defaultValue:nil];
        if (!self.sessionId) return nil;
        
        self.previousSessionId = [self.sessionDictionary sp_stringForKey:kSPSessionPreviousId defaultValue:nil];
        
        NSNumber *sessionIndexNumber = [self.sessionDictionary sp_numberForKey:kSPSessionIndex defaultValue:nil];
        if (!sessionIndexNumber) return nil;
        self.sessionIndex = sessionIndexNumber.integerValue;
        
        self.userId = [self.sessionDictionary sp_stringForKey:kSPSessionUserId defaultValue:nil];
        if (!self.userId) return nil;
        
        self.storage = [self.sessionDictionary sp_stringForKey:kSPSessionStorage defaultValue:nil];
        if (!self.storage) return nil;
    }
    return self;
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    [self.sessionDictionary setObject:userId forKey:kSPSessionUserId];
}

- (NSDictionary<NSString *,NSObject *> *)sessionContext {
    return [self.sessionDictionary mutableCopy];
}

@end
