//
//  SPEvent.m
//  Snowplow
//
//  Copyright (c) 2018 Snowplow Analytics Ltd. All rights reserved.
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
//  Copyright: Copyright (c) 2018 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "Snowplow.h"
#import "SPEvent.h"
#import "SPUtilities.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPScreenState.h"

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
        _timestamp = [SPUtilities getTimestamp];
        _contexts = [[NSMutableArray alloc] init];
        _eventId = [SPUtilities getUUIDString];
    }
    return self;
}

// --- Builder Methods

- (void) setTimestamp:(NSNumber *)timestamp {
    _timestamp = timestamp;
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
    return _timestamp;
}

- (NSString *) getEventId {
    return _eventId;
}

- (SPPayload *) addDefaultParamsToPayload:(SPPayload *)pb {
    [pb addValueToPayload:[NSString stringWithFormat:@"%lld", _timestamp.longLongValue] forKey:kSPTimestamp];
    [pb addValueToPayload:_eventId forKey:kSPEid];
    return pb;
}

- (void) basePreconditions {
    [SPUtilities checkArgument:(_contexts != nil) withMessage:@"Contexts cannot be nil."];
    [SPUtilities checkArgument:([_eventId length] != 0) withMessage:@"EventID cannot be nil or empty."];
}

@end
