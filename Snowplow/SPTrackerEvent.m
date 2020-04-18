//
//  SPTrackerEvent.m
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
//  Authors: Alex Benini
//  Copyright: Copyright © 2020 Snowplow Analytics.
//  License: Apache License Version 2.0
//

#import "SPTrackerEvent.h"
#import "SPSelfDescribingJson.h"

@implementation SPTrackerEvent

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // to ignore warnings for deprecated methods that we are forced to use until the next major version release

+ (instancetype)trackerEventWithPrimitive:(SPPrimitive *)event {
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    trackerEvent.eventName = event.name;
    trackerEvent.isPrimitive = true;
    return trackerEvent;
}

+ (instancetype)trackerEventWithSelfDescribing:(SPSelfDescribing *)event {
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    trackerEvent.schema = event.schema;
    trackerEvent.isPrimitive = false;
    return trackerEvent;
}

#pragma mark - private methods

- (instancetype)initWithEvent:(SPEvent *)event {
    if (self = [super init]) {
        self.eventId = [[NSUUID alloc] initWithUUIDString:event.eventId]; // it has to be set in the TrackerEvent
        self.contexts = event.contexts; // it has to be set in the TrackerEvent
        self.timestamp = event.timestamp.doubleValue / 1000; // it has to be set in the TrackerEvent
        self.payload = event.payload;
    }
    return self;
}

#pragma GCC diagnostic pop

@end
