//
//  SPTrackerEvent.m
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
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPTrackerEvent.h"
#import "SPSelfDescribingJson.h"
#import "SPTrackerError.h"

@implementation SPTrackerEvent

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // to ignore warnings for deprecated methods that we are forced to use until the next major version release

- (instancetype)initWithEvent:(SPEvent *)event stateCopy:(NSDictionary<NSString *,SPStateFuture *> *)stateCopy {
    if (self = [super init]) {
        self.eventId = [NSUUID UUID];
        self.timestamp = (long long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000);
        self.trueTimestamp = event.trueTimestamp;
        self.contexts = [event.contexts mutableCopy];
        self.payload = [event.payload mutableCopy];
        self.state = stateCopy;

        self.isService = [event isKindOfClass:SPTrackerError.class];
        if ([event isKindOfClass:SPPrimitiveAbstract.class]) {
            self.eventName = [(SPPrimitiveAbstract *)event name];
            self.isPrimitive = true;
        } else {
            self.schema = [(SPSelfDescribingAbstract *)event schema];
            self.isPrimitive = false;
        }
    }
    return self;
}

#pragma GCC diagnostic pop

- (BOOL)addPayloadValues:(nonnull NSDictionary<NSString *,NSObject *> *)payload {
    __block BOOL result = YES;
    [payload enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![self.payload objectForKey:key]) {
            [self.payload setObject:obj forKey:key];
        } else {
            result = NO;
        }
    }];
    return result;
}

@end
