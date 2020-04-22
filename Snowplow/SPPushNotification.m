//
//  SPPushNotification.m
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

#import "SPPushNotification.h"

#import "Snowplow.h"
#import "SPUtilities.h"

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

- (NSString *)schema {
    return kSPPushNotificationSchema;
}

- (NSDictionary<NSString *, NSObject *> *)payload {
    return @{
        kSPPushNotification: _notification.payload,
        kSPPushTrigger: _trigger,
        kSPPushAction: _action,
        kSPPushDeliveryDate: _date,
        kSPPushCategoryId: _category,
        kSPPushThreadId: _thread,
    };
}

- (SPSelfDescribingJson *) getPayload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_notification.payload forKey:kSPPushNotification];
    [event setObject:_trigger forKey:kSPPushTrigger];
    [event setObject:_action forKey:kSPPushAction];
    [event setObject:_date forKey:kSPPushDeliveryDate];
    [event setObject:_category forKey:kSPPushCategoryId];
    [event setObject:_thread forKey:kSPPushThreadId];
    return [[SPSelfDescribingJson alloc] initWithSchema:kSPPushNotificationSchema andData:event];
}

@end

// MARK:- SPNotificationContent

@implementation SPNotificationContent {
    NSString * _title;
    NSString * _subtitle;
    NSString * _body;
    NSNumber * _badge;
    NSString * _sound;
    NSString * _launchImageName;
    NSDictionary * _userInfo;
    NSArray * _attachments;
}

+ (instancetype) build:(void(^)(id<SPNotificationContentBuilder>builder))buildBlock {
    SPNotificationContent* event = [SPNotificationContent new];
    if (buildBlock) { buildBlock(event); }
    [event preconditions];
    return event;
}

- (id) init {
    self = [super init];
    return self;
}

- (void) preconditions {
    [SPUtilities checkArgument:([_title length] != 0) withMessage:@"Title cannot be nil or empty."];
    [SPUtilities checkArgument:([_body length] != 0) withMessage:@"Body cannot be nil or empty."];
    [SPUtilities checkArgument:(_badge != nil) withMessage:@"Badge cannot be nil."];
}

// --- Builder Methods

- (void) setTitle:(NSString *)title {
    _title = title;
}

- (void) setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
}

- (void) setBody:(NSString *)body {
    _body = body;
}

- (void) setBadge:(NSNumber *)badge {
    _badge = badge;
}

- (void) setSound:(NSString *)sound {
    _sound = sound;
}

- (void) setLaunchImageName:(NSString *)name {
    _launchImageName = name;
}

- (void) setUserInfo:(NSDictionary *)userInfo {
    _userInfo = [SPUtilities replaceHyphenatedKeysWithCamelcase:userInfo];
}

- (void) setAttachments:(NSArray *)attachments {
    _attachments = attachments;
}

// --- Public Methods

- (NSDictionary *) payload {
    NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
    [event setObject:_title forKey:kSPPnTitle];
    [event setObject:_body forKey:kSPPnBody];
    [event setValue:_badge forKey:kSPPnBadge];
    if (_subtitle != nil) {
        [event setObject:_subtitle forKey:kSPPnSubtitle];
    }
    if (_subtitle != nil) {
        [event setObject:_subtitle forKey:kSPPnSubtitle];
    }
    if (_sound != nil) {
        [event setObject:_sound forKey:kSPPnSound];
    }
    if (_launchImageName != nil) {
        [event setObject:_launchImageName forKey:kSPPnLaunchImageName];
    }
    if (_userInfo != nil) {
        NSMutableDictionary * aps = nil;
        NSMutableDictionary * newUserInfo = nil;

        // modify contentAvailable value "1" and "0" to @YES and @NO to comply with schema
        if (![[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:nil] &&
            [[_userInfo objectForKey:@"aps"] isKindOfClass:[NSDictionary class]]) {
            aps = [[NSMutableDictionary alloc] initWithDictionary:_userInfo[@"aps"]];

            if ([[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:@1]) {
                [aps setObject:@YES forKey:@"contentAvailable"];
            } else if ([[_userInfo valueForKeyPath:@"aps.contentAvailable"] isEqual:@0]) {
                [aps setObject:@NO forKey:@"contentAvailable"];
            }
            newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:_userInfo];
            [newUserInfo setObject:aps forKey:@"aps"];
        }
        [event setObject:[[NSDictionary alloc] initWithDictionary:newUserInfo] forKey:kSPPnUserInfo];
    }
    if (_attachments != nil) {
        [event setObject:_attachments forKey:kSPPnAttachments];
    }

    return [[NSDictionary alloc] initWithDictionary:event copyItems:YES];
}

- (NSDictionary *) getPayload {
    return self.payload;
}

@end
