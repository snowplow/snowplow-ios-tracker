//
//  SPTrackerEvent.m
//  Snowplow
//
//  Created by Alex Benini on 13/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPTrackerEvent.h"
#import "SPUnstructured.h"
#import "SPSelfDescribingJson.h"

@implementation SPTrackerEvent

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // to ignore warnings for deprecated methods that we are forced to use until the next major version release

+ (instancetype)trackerEventWithBuiltIn:(SPBuiltIn *)event {
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    trackerEvent.eventName = event.name;
    trackerEvent.isBuiltIn = true;
    return trackerEvent;
}

+ (instancetype)trackerEventWithSelfDescribing:(SPSelfDescribing *)event {
    SPTrackerEvent *trackerEvent = [[SPTrackerEvent alloc] initWithEvent:event];
    trackerEvent.schema = event.schema;
    trackerEvent.isBuiltIn = false;
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
