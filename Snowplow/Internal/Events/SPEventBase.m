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

// --- Public Methods

- (NSMutableArray *) getContexts {
    return [NSMutableArray arrayWithArray:_contexts];
}

- (NSNumber *)getTrueTimestamp {
    if (!_trueTimestamp) {
        return nil;
    }
    return @(_trueTimestamp.longLongValue / (double)1000);
}

- (NSDictionary<NSString *,NSObject *> *)payload {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void) basePreconditions {
    [SPUtilities checkArgument:(_contexts != nil) withMessage:@"Contexts cannot be nil."];
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
