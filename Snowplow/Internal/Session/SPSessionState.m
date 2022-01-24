//
//  SPSessionState.m
//  Snowplow
//
//  Created by Alex Benini on 01/12/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
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

@property (nonatomic, nonnull, readwrite) NSMutableDictionary<NSString *, NSObject *> *sessionContext;

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
        
        NSMutableDictionary *sessionDictionary = [NSMutableDictionary new];
        if (previousSessionId) {
            [sessionDictionary setObject:previousSessionId forKey:kSPSessionPreviousId];
        }
        [sessionDictionary setObject:currentSessionId forKey:kSPSessionId];
        [sessionDictionary setObject:firstEventId forKey:kSPSessionFirstEventId];
        [sessionDictionary setObject:[NSNumber numberWithInteger:sessionIndex] forKey:kSPSessionIndex];
        [sessionDictionary setObject:storage forKey:kSPSessionStorage];
        [sessionDictionary setObject:userId forKey:kSPSessionUserId];
        self.sessionContext = sessionDictionary;
    }
    return self;
}

- (instancetype)initWithStoredState:(NSDictionary<NSString *,NSObject *> *)storedState {
    if (self = [super init]) {
        self.sessionContext = [storedState mutableCopy];
        
        self.firstEventId = [self.sessionContext sp_stringForKey:kSPSessionFirstEventId defaultValue:nil];
        if (!self.firstEventId) return nil;
        
        self.sessionId = [self.sessionContext sp_stringForKey:kSPSessionId defaultValue:nil];
        if (!self.sessionId) return nil;
        
        self.previousSessionId = [self.sessionContext sp_stringForKey:kSPSessionPreviousId defaultValue:nil];
        
        NSNumber *sessionIndexNumber = [self.sessionContext sp_numberForKey:kSPSessionIndex defaultValue:nil];
        if (!sessionIndexNumber) return nil;
        self.sessionIndex = sessionIndexNumber.integerValue;
        
        self.userId = [self.sessionContext sp_stringForKey:kSPSessionUserId defaultValue:nil];
        if (!self.userId) return nil;
        
        self.storage = [self.sessionContext sp_stringForKey:kSPSessionStorage defaultValue:nil];
        if (!self.storage) return nil;
    }
    return self;
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    [self.sessionContext setObject:userId forKey:kSPSessionUserId];
}

@end
