//
//  SPSessionState.h
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
