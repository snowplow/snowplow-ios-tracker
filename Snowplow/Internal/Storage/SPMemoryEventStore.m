//
//  SPMemoryEventStore.m
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

#import "SPMemoryEventStore.h"

@interface SPMemoryEventStore ()

@property (nonatomic) NSUInteger sendLimit;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSMutableOrderedSet<SPEmitterEvent *> *orderedSet;

@end

@implementation SPMemoryEventStore

- (instancetype)init {
    return [self initWithLimit:250];
}

- (instancetype)initWithLimit:(NSUInteger)limit {
    if (self = [super init]) {
        self.orderedSet = [[NSMutableOrderedSet alloc] init];
        self.sendLimit = limit;
        self.index = 0;
    }
    return self;
}

// Interface methods

- (void)addEvent:(nonnull SPPayload *)payload {
    @synchronized (self) {
        SPEmitterEvent *item = [[SPEmitterEvent alloc] initWithPayload:payload storeId:self.index++];
        [self.orderedSet addObject:item];
    }
}

- (NSUInteger)count {
    @synchronized (self) {
        return [self.orderedSet count];
    }
}

- (nonnull NSArray<SPEmitterEvent *> *)emittableEventsWithQueryLimit:(NSUInteger)queryLimit {
    @synchronized (self) {
        NSUInteger setCount = [self.orderedSet count];
        if (setCount <= 0) {
            return @[];
        }
        NSUInteger len = MIN(queryLimit, setCount);
        NSRange range = NSMakeRange(0, len);
        SPEmitterEvent * __unsafe_unretained array[len];
        [self.orderedSet getObjects:array range:range];
        NSMutableArray<SPEmitterEvent *> *result = [[NSMutableArray alloc] initWithCapacity:len];
        for (int i = 0; i < len; i++) {
            [result addObject:array[i]];
        }
        return result;
    }
}

- (BOOL)removeAllEvents {
    @synchronized (self) {
        [self.orderedSet removeAllObjects];
        return YES;
    }
}

- (BOOL)removeEventWithId:(long long)storeId {
    return [self removeEventsWithIds:@[[NSNumber numberWithLongLong:storeId]]];
}

- (BOOL)removeEventsWithIds:(nonnull NSArray<NSNumber *> *)storeIds {
    @synchronized (self) {
        NSMutableArray<SPEmitterEvent *> *itemsToRemove = [NSMutableArray new];
        for (SPEmitterEvent *item in self.orderedSet) {
            if ([storeIds containsObject:[NSNumber numberWithLongLong:item.storeId]]) {
                [itemsToRemove addObject:item];
            }
        }
        [self.orderedSet removeObjectsInArray:itemsToRemove];
        return YES;
    }
}

@end
