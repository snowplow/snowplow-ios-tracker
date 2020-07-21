//
//  SPEventBase.m
//  Snowplow
//
//  Copyright (c) 2020 Snowplow Analytics Ltd. All rights reserved.
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPEventBase.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPScreenState.h"
#import "SPTracker.h"

NSString * stringWithSPScreenType(SPScreenType screenType) {
    NSArray * arr = @[
                      @"Default",
                      @"Navigation",
                      @"TabBar",
                      @"PageView",
                      @"SplitView",
                      @"PopoverPresentation",
                      @"Modal",
                      @"Combined"
                      ];
    return (NSString *)[arr objectAtIndex:screenType];
}

// Base Event

@implementation SPEvent

- (id) init {
    self = [super init];
    if (self) {
        _contexts = [[NSMutableArray alloc] init];
    }
    return self;
}

// --- Builder Methods

- (void) setTimestamp:(NSNumber *)timestamp {
    _timestamp = timestamp;
}

- (void)setTrueTimestamp:(NSNumber *)trueTimestamp {
    long long tt = trueTimestamp.doubleValue * 1000;
    _trueTimestamp = @(tt);
}

- (void) setContexts:(NSMutableArray *)contexts {
    for (NSObject * sdj in contexts) {
        [SPUtilities checkArgument:([sdj isKindOfClass:[SPSelfDescribingJson class]])
                       withMessage:@"All contexts must be SelfDescribingJson objects."];
    }
    _contexts = contexts;
}

- (void) setEventId:(NSString *)eventId {
    _eventId = eventId;
}

// --- Public Methods

- (NSMutableArray *) getContexts {
    return [NSMutableArray arrayWithArray:_contexts];
}

- (NSNumber *) getTimestamp {
    if (!_timestamp) {
        _timestamp = [SPUtilities getTimestamp];
    }
    return _timestamp;
}

- (NSNumber *)getTrueTimestamp {
    if (!_trueTimestamp) {
        return nil;
    }
    return @(_trueTimestamp.longLongValue / (double)1000);
}

- (NSString *) getEventId {
    if (!_eventId) {
        _eventId = [SPUtilities getUUIDString];
    }
    return _eventId;
}

- (NSDictionary<NSString *,NSObject *> *)payload {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (SPPayload *) addDefaultParamsToPayload:(SPPayload *)pb {
    [pb addValueToPayload:[NSString stringWithFormat:@"%lld", _timestamp.longLongValue] forKey:kSPTimestamp];
    [pb addValueToPayload:_eventId forKey:kSPEid];
    return pb;
}

- (void) basePreconditions {
    [SPUtilities checkArgument:(_contexts != nil) withMessage:@"Contexts cannot be nil."];
    if (_eventId) {
        [SPUtilities checkArgument:([[NSUUID alloc] initWithUUIDString:_eventId] != nil) withMessage:@"EventID has to be a valid UUID."];
    }
}

- (void)beginProcessingWithTracker:(SPTracker *)tracker {}
- (void)endProcessingWithTracker:(SPTracker *)tracker {}

@end

// SelfDescribing base class

@implementation SPSelfDescribing

- (NSString *)schema {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end

// Primitive base class

@implementation SPPrimitive

- (NSString *)name {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
