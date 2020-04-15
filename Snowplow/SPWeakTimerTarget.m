//
//  SPWeakTimer.m
//  Snowplow
//
//  Copyright (c) 2013-2020 Snowplow Analytics Ltd. All rights reserved.
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

#import "SPWeakTimerTarget.h"
#import "SPEmitter.h"

@implementation SPWeakTimerTarget {
    __weak id _target;
    SEL       _selector;
}

- (id)initWithTarget:(id)target andSelector:(SEL)selector {
    self = [super init];
    if (self) {
        _target = target;
        _selector = selector;
    }
    return self;
}

- (void)timerFired:(NSTimer *)timer {
    if (_target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_selector withObject:timer];
#pragma clang diagnostic pop
    } else {
        [timer invalidate];
    }
}

@end
