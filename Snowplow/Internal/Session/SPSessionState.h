//
//  SPSessionState.h
//  Snowplow
//
//  Created by Alex Benini on 01/12/21.
//  Copyright © 2021 Snowplow Analytics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPState.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPSessionState : NSObject <SPState>

@property (nonatomic, nonnull, readonly) NSString *firstEventId;
@property (nonatomic, nullable, readonly) NSString *previousSessionId;
@property (nonatomic, nonnull, readonly) NSString *sessionId;
@property (nonatomic, readonly) NSInteger sessionIndex;
@property (nonatomic, nonnull, readonly) NSString *storage;
@property (nonatomic, nonnull) NSString *userId;

@property (nonatomic, nonnull, readonly) NSMutableDictionary<NSString *, NSObject *> *sessionContext;

- (instancetype)initWithFirstEventId:(NSString *)firstEventId currentSessionId:(NSString *)currentSessionId previousSessionId:(nullable NSString *)previousSessionId sessionIndex:(NSInteger)sessionIndex userId:(NSString *)userId storage:(NSString *)storage;

- (instancetype)initWithStoredState:(NSDictionary<NSString *, NSObject *> *)storedState;

@end

NS_ASSUME_NONNULL_END
