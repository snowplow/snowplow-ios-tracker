//
//  SPMockEventStore.m
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

#import "SPMockEventStore.h"
#import "SPLogger.h"

@implementation SPMockEventStore

- (instancetype)init {
    if (self = [super init]) {
        self.db = [NSMutableDictionary new];
        self.lastInsertedRow = -1;
    }
    return self;
}

- (void)addEvent:(nonnull SPPayload *)payload {
    @synchronized (self) {
        self.lastInsertedRow++;
        SPLogVerbose(@"Add %@", payload);
        [self.db setObject:payload forKey:@(self.lastInsertedRow)];
    }
}

- (BOOL)removeEventWithId:(long long)storeId {
    @synchronized (self) {
        SPLogVerbose(@"Remove %lld", storeId);
        BOOL exist = [self.db objectForKey:@(storeId)];
        [self.db removeObjectForKey:@(storeId)];
        return exist;
    }
}

- (BOOL)removeEventsWithIds:(nonnull NSArray<NSNumber *> *)storeIds {
    BOOL result = YES;
    for (NSNumber *storeId in storeIds) {
        result = [self.db objectForKey:storeId];
        [self.db removeObjectForKey:storeId];
    }
    return result;
}

- (BOOL)removeAllEvents {
    @synchronized (self) {
        [self.db removeAllObjects];
        self.lastInsertedRow = -1;
    }
    return YES;
}

- (NSUInteger)count {
    @synchronized (self) {
        return self.db.count;
    }
}

- (nonnull NSArray<SPEmitterEvent *> *)emittableEventsWithQueryLimit:(NSUInteger)queryLimit {
    @synchronized (self) {
        NSMutableArray<NSNumber *> *eventIds = [NSMutableArray new];
        NSMutableArray<SPEmitterEvent *> *events = [NSMutableArray new];
        [self.db enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, SPPayload *obj, BOOL *stop) {
            SPPayload *payloadCopy = [[SPPayload alloc] initWithNSDictionary:[obj getAsDictionary]];
            SPEmitterEvent *event = [[SPEmitterEvent alloc] initWithPayload:payloadCopy storeId:key.longLongValue];
            [events addObject:event];
            [eventIds addObject:@(event.storeId)];
        }];
        if (queryLimit < events.count) {
            events = [events subarrayWithRange:NSMakeRange(0, queryLimit)].mutableCopy;
        }
        SPLogVerbose(@"emittableEventsWithQueryLimit: %@", eventIds);
        return events;
    }
}

@end

