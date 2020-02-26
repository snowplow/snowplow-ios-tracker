//
//  SPPushNotification.m
//  Snowplow
//
//  Created by Alex Benini on 14/02/2020.
//  Copyright © 2020 Snowplow Analytics. All rights reserved.
//

#import "SPPushNotification.h"

#import "Snowplow.h"
#import "SPUtilities.h"
#import "SPSelfDescribingJson.h"
#import "SPNotificationContent.h"

@implementation SPPushNotification {
    NSString * _action;
    NSString * _trigger;
    NSString * _date;
    NSString * _category;
    NSString * _thread;
    SPNotificationContent * _notification;
}

+ (instancetype) build:(void(^)(id<SPPushNotificationBuilder>builder))buildBlock {
    SPPushNotification* event = [SPPushNotification new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_date length] != 0) withMessage:@"Delivery date cannot be nil or empty."];
    [SPUtilities checkArgument:([_action length] != 0) withMessage:@"Action cannot be nil or empty."];
    [SPUtilities checkArgument:([_trigger length] != 0) withMessage:@"Trigger cannot be nil or empty."];
    [SPUtilities checkArgument:([_category length] != 0) withMessage:@"Category identifier cannot be nil or empty."];
    [SPUtilities checkArgument:([_thread length] != 0) withMessage:@"Thread identifier cannot be nil or empty."];
    [SPUtilities checkArgument:(_notification != nil) withMessage:@"Notification cannot be nil."];
    [self basePreconditions];
}

// --- Builder Methods

- (void) setAction:(NSString *)action {
    _action = action;
}

- (void) setDeliveryDate:(NSString *)date {
    _date = date;
}

- (void) setTrigger:(NSString *)trigger {
    _trigger = trigger;
}

- (void) setCategoryIdentifier:(NSString *)category {
    _category = category;
}

- (void) setThreadIdentifier:(NSString *)thread {
    _thread = thread;
}

- (void) setNotification:(SPNotificationContent *)content {
    _notification = content;
}

// --- Public Methods

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];

    [event setObject:[_notification getPayload] forKey:kSPPushNotification];
    [event setObject:_trigger forKey:kSPPushTrigger];
    [event setObject:_action forKey:kSPPushAction];
    [event setObject:_date forKey:kSPPushDeliveryDate];
    [event setObject:_category forKey:kSPPushCategoryId];
    [event setObject:_thread forKey:kSPPushThreadId];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPPushNotificationSchema andData:event];
}

@end
