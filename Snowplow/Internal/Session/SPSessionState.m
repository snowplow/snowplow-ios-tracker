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
@property (nonatomic, nullable, readwrite) NSString *firstEventTimestamp;
@property (nonatomic, nullable, readwrite) NSString *previousSessionId;
@property (nonatomic, nonnull, readwrite) NSString *sessionId;
@property (nonatomic, readwrite) NSInteger sessionIndex;
@property (nonatomic, nonnull, readwrite) NSString *storage;

@property (nonatomic, nonnull) NSMutableDictionary<NSString *, NSObject *> *sessionDictionary;

@end

@implementation SPSessionState

+ (NSMutableDictionary<NSString *, NSObject *> *)buildSessionDictionaryWithFirstEventId:(NSString *)firstEventId firstEventTimestamp:(NSString *)firstEventTimestamp currentSessionId:(NSString *)currentSessionId previousSessionId:(NSString *)previousSessionId sessionIndex:(NSInteger)sessionIndex userId:(NSString *)userId storage:(NSString *)storage
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:previousSessionId ?: [NSNull null] forKey:kSPSessionPreviousId];
    [dictionary setObject:currentSessionId forKey:kSPSessionId];
    [dictionary setObject:firstEventId forKey:kSPSessionFirstEventId];
    [dictionary setObject:firstEventTimestamp ?: [NSNull null] forKey:kSPSessionFirstEventTimestamp];
    [dictionary setObject:[NSNumber numberWithInteger:sessionIndex] forKey:kSPSessionIndex];
    [dictionary setObject:storage forKey:kSPSessionStorage];
    [dictionary setObject:userId forKey:kSPSessionUserId];
    return dictionary;
}

- (instancetype)initWithFirstEventId:(NSString *)firstEventId firstEventTimestamp:(NSString *)firstEventTimestamp currentSessionId:(NSString *)currentSessionId previousSessionId:(NSString *)previousSessionId sessionIndex:(NSInteger)sessionIndex userId:(NSString *)userId storage:(NSString *)storage {
    if (self = [super init]) {
        self.firstEventId = firstEventId;
        self.firstEventTimestamp = firstEventTimestamp;
        self.sessionId = currentSessionId;
        self.previousSessionId = previousSessionId;
        self.sessionIndex = sessionIndex;
        self.userId = userId;
        self.storage = storage;
        
        self.sessionDictionary = [SPSessionState buildSessionDictionaryWithFirstEventId:firstEventId
                                                                    firstEventTimestamp:firstEventTimestamp
                                                                       currentSessionId:currentSessionId
                                                                      previousSessionId:previousSessionId
                                                                           sessionIndex:sessionIndex
                                                                                 userId:userId
                                                                                storage:storage];
    }
    return self;
}

- (instancetype)initWithStoredState:(NSDictionary<NSString *,NSObject *> *)storedState {
    if (self = [super init]) {
        self.sessionId = [storedState sp_stringForKey:kSPSessionId defaultValue:nil];
        if (!self.sessionId) return nil;
        
        NSNumber *sessionIndexNumber = [storedState sp_numberForKey:kSPSessionIndex defaultValue:nil];
        if (!sessionIndexNumber) return nil;
        self.sessionIndex = sessionIndexNumber.integerValue;
        
        self.userId = [storedState sp_stringForKey:kSPSessionUserId defaultValue:nil];
        if (!self.userId) return nil;
        
        self.previousSessionId = [storedState sp_stringForKey:kSPSessionPreviousId defaultValue:nil];

        // The FirstEventId should be stored in legacy persisted sessions even
        // if it wasn't used. Anyway we provide a default value in order to be
        // defensive and exclude any possible issue with a missing value.
        self.firstEventId = [storedState sp_stringForKey:kSPSessionFirstEventId
                                                       defaultValue:@"00000000-0000-0000-0000-000000000000"];
        self.firstEventTimestamp = [storedState sp_stringForKey:kSPSessionFirstEventTimestamp defaultValue:nil];
                
        self.storage = [storedState sp_stringForKey:kSPSessionStorage defaultValue:@"LOCAL_STORAGE"];
        
        self.sessionDictionary = [SPSessionState buildSessionDictionaryWithFirstEventId:self.firstEventId
                                                                    firstEventTimestamp:self.firstEventTimestamp
                                                                       currentSessionId:self.sessionId
                                                                      previousSessionId:self.previousSessionId
                                                                           sessionIndex:self.sessionIndex
                                                                                 userId:self.userId
                                                                                storage:self.storage];
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)sessionContext {
    return [self.sessionDictionary mutableCopy];
}

@end
